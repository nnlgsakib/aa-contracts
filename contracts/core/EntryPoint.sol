// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IEntryPoint.sol";
import "../interfaces/IWallet.sol";
import "../interfaces/IPaymaster.sol";
import "../interfaces/IAggregator.sol";
import "../libraries/UserOperationLib.sol";
import "../libraries/TransactionTypeDetector.sol";
import "../libraries/BlockchainConfig.sol";
import "../utils/NonceManager.sol";

contract EntryPoint is IEntryPoint {
    mapping(address => uint256) private balances;

    event UserOperationExecuted(address indexed sender, uint256 nonce, bool success);
    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    function handleOps(UserOperation[] calldata ops, address payable beneficiary) external override {
        _handleOps(ops, address(0), beneficiary);
    }

    function handleAggregatedOps(
        UserOperation[] calldata ops,
        address aggregator,
        address payable beneficiary
    ) external override {
        require(aggregator != address(0), "Invalid aggregator");
        _handleOps(ops, aggregator, beneficiary);
    }

    function _handleOps(
        UserOperation[] calldata ops,
        address aggregator,
        address payable beneficiary
    ) internal {
        uint256 totalGasCost = 0;

        // Extract all signatures when using an aggregator
        bytes[] memory signatures = new bytes[](ops.length);
        if (aggregator != address(0)) {
            for (uint256 i = 0; i < ops.length; i++) {
                signatures[i] = ops[i].signature;
            }
        }

        for (uint256 i = 0; i < ops.length; i++) {
            UserOperation calldata op = ops[i];
            uint256 preGas = gasleft();

            // Deploy wallet if initCode exists
            if (op.initCode.length > 0) {
                _deployWallet(op.initCode, op.sender);
            }
            require(op.sender.code.length > 0, "Wallet not deployed");

            bytes32 userOpHash = UserOperationLib.getUserOpHash(
                op,
                address(this),
                BlockchainConfig.getChainId()
            );
            bytes memory signature = aggregator == address(0)
                ? op.signature
                : IAggregator(aggregator).aggregateSignatures(ops, signatures);

            // Validate paymaster if present
            address paymaster = _extractPaymaster(op.paymasterAndData);
            if (paymaster != address(0)) {
                (bytes memory context, uint256 validationData) = IPaymaster(paymaster).validatePaymasterUserOp(
                    op,
                    userOpHash,
                    0
                );
                require(validationData == 0, "Paymaster validation failed");
            }

            // Validate UserOperation
            (bool success, bytes memory ret) = op.sender.call{gas: op.verificationGasLimit}(
                abi.encodeWithSelector(IWallet.validateUserOp.selector, op, userOpHash, 0)
            );
            require(success, "Validation failed");

            // Execute callData
            (success, ) = op.sender.call{gas: op.callGasLimit}(op.callData);
            emit UserOperationExecuted(op.sender, op.nonce, success);

            // Calculate gas cost
            uint256 gasUsed = preGas - gasleft() + op.preVerificationGas;
            uint256 gasCost = _calculateGasCost(gasUsed, op);

            if (paymaster != address(0)) {
                IPaymaster(paymaster).postOp{gas: 100_000}(new bytes(0), gasCost);
            } else {
                require(balances[op.sender] >= gasCost, "Insufficient balance");
                balances[op.sender] -= gasCost;
            }
            totalGasCost += gasCost;

            NonceManager.incrementNonce(op.sender);
        }

        if (totalGasCost > 0) {
            beneficiary.transfer(totalGasCost);
        }
    }

    function _calculateGasCost(uint256 gasUsed, UserOperation calldata op) internal view returns (uint256) {
        if (TransactionTypeDetector.supportsEIP1559()) {
            uint256 feePerGas = block.basefee + op.maxPriorityFeePerGas;
            if (feePerGas > op.maxFeePerGas) feePerGas = op.maxFeePerGas;
            return gasUsed * feePerGas;
        } else {
            return gasUsed * op.maxFeePerGas;
        }
    }

    function _deployWallet(bytes memory initCode, address expectedSender) internal {
        address deployed;
        if (BlockchainConfig.supportsCreate2()) {
            assembly {
                deployed := create2(0, add(initCode, 0x20), mload(initCode), 0)
            }
        } else {
            assembly {
                deployed := create(0, add(initCode, 0x20), mload(initCode))
            }
        }
        require(deployed == expectedSender, "Deployment failed");
    }

    function _extractPaymaster(bytes memory paymasterAndData) internal pure returns (address) {
        if (paymasterAndData.length < 20) return address(0);
        return address(uint160(bytes20(paymasterAndData)));
    }

    function depositTo(address account) external payable override {
        balances[account] += msg.value;
        emit Deposited(account, msg.value);
    }

    function withdrawTo(address payable account, uint256 amount) external override {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        account.transfer(amount);
        emit Withdrawn(account, amount);
    }

    function getNonce(address account) external view override returns (uint256) {
        return NonceManager.getNonce(account);
    }
}
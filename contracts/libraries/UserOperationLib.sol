// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IEntryPoint.sol";

library UserOperationLib {
    function getUserOpHash(
        IEntryPoint.UserOperation calldata op,
        address entryPoint,
        uint256 chainId
    ) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                op.sender,
                op.nonce,
                keccak256(op.initCode),
                keccak256(op.callData),
                op.callGasLimit,
                op.verificationGasLimit,
                op.preVerificationGas,
                op.maxFeePerGas,
                op.maxPriorityFeePerGas,
                keccak256(op.paymasterAndData),
                chainId,
                entryPoint
            )
        );
    }
}
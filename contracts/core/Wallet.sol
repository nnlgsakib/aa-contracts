// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../interfaces/IEntryPoint.sol";
import "../interfaces/IWallet.sol";

contract Wallet is IWallet, Initializable, UUPSUpgradeable {
    address public owner;
    address public entryPoint;

    modifier onlyEntryPoint() {
        require(msg.sender == entryPoint, "Only EntryPoint");
        _;
    }

    function initialize(address _owner, address _entryPoint) external override initializer {
        owner = _owner;
        entryPoint = _entryPoint;
    }

    function validateUserOp(
        IEntryPoint.UserOperation calldata op,
        bytes32 userOpHash,
        uint256 /* missingAccountFunds */
    ) external override onlyEntryPoint returns (uint256) {
        address signer = ECDSA.recover(userOpHash, op.signature);
        require(signer == owner, "Invalid signature");
        return 0;
    }

    function execute(address dest, uint256 value, bytes calldata data) external override onlyEntryPoint {
        (bool success, ) = dest.call{value: value}(data);
        require(success, "Execution failed");
    }

    function _authorizeUpgrade(address) internal override onlyEntryPoint {}
}
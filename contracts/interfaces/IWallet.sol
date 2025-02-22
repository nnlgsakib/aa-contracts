// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEntryPoint.sol";

interface IWallet {
    function initialize(address _owner, address _entryPoint) external;
    function validateUserOp(
        IEntryPoint.UserOperation calldata op,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256);
    function execute(address dest, uint256 value, bytes calldata data) external;
}
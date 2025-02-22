// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEntryPoint.sol";

interface IPaymaster {
    function validatePaymasterUserOp(
        IEntryPoint.UserOperation calldata op,
        bytes32 userOpHash,
        uint256 maxCost
    ) external returns (bytes memory context, uint256 validationData);
    function postOp(bytes calldata context, uint256 actualGasCost) external;
}
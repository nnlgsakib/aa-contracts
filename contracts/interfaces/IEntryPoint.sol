// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEntryPoint {
    struct UserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes paymasterAndData;
        bytes signature;
    }

    function handleOps(UserOperation[] calldata ops, address payable beneficiary) external;
    function handleAggregatedOps(UserOperation[] calldata ops, address aggregator, address payable beneficiary) external;
    function depositTo(address account) external payable;
    function withdrawTo(address payable account, uint256 amount) external;
    function getNonce(address account) external view returns (uint256);
}
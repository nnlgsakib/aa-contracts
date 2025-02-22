// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IEntryPoint.sol";

interface IAggregator {
    function aggregateSignatures(
        IEntryPoint.UserOperation[] calldata ops,
        bytes[] calldata signatures
    ) external view returns (bytes memory aggregatedSignature);
    function validateAggregatedSignature(
        IEntryPoint.UserOperation[] calldata ops,
        bytes memory aggregatedSignature
    ) external view returns (bool);
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IAggregator.sol";
import "../libraries/UserOperationLib.sol";

contract Aggregator is IAggregator {
    function aggregateSignatures(
        IEntryPoint.UserOperation[] calldata ops,
        bytes[] calldata signatures
    ) external view override returns (bytes memory aggregatedSignature) {
        require(ops.length == signatures.length, "Mismatched lengths");
        bytes memory aggregated;
        for (uint256 i = 0; i < ops.length; i++) {
            bytes32 userOpHash = UserOperationLib.getUserOpHash(ops[i], msg.sender, block.chainid);
            aggregated = abi.encodePacked(aggregated, userOpHash, signatures[i]);
        }
        return aggregated;
    }

    function validateAggregatedSignature(
        IEntryPoint.UserOperation[] calldata ops,
        bytes memory /* aggregatedSignature */
    ) external view override returns (bool) {
        // Implement specific validation logic here
        return true;
    }
}
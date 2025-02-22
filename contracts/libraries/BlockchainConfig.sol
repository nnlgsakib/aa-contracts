// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library BlockchainConfig {
    function getChainId() internal view returns (uint256) {
        return block.chainid;
    }

    function supportsCreate2() internal pure returns (bool) {
        // For simplicity, assume CREATE2 is supported on all EVM-compatible chains
        return true;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library NonceManager {
    // Define a storage mapping to track nonces for each address
    struct NonceStorage {
        mapping(address => uint256) nonces;
    }

    // Storage slot identifier for the nonce mapping
    bytes32 private constant NONCE_STORAGE_POSITION = keccak256("NonceManager.storage");

    // Helper function to access the storage slot
    function _nonceStorage() internal pure returns (NonceStorage storage ns) {
        bytes32 position = NONCE_STORAGE_POSITION;
        assembly {
            ns.slot := position
        }
    }

    // Get the nonce for a given account
    function getNonce(address account) internal view returns (uint256) {
        return _nonceStorage().nonces[account];
    }

    // Increment the nonce for a given account
    function incrementNonce(address account) internal {
        _nonceStorage().nonces[account]++;
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library NonceManager {
    struct Nonces {
        uint256 value;
    }

    function getNonce(address account) internal view returns (uint256) {
        return Nonces(account).value;
    }

    function incrementNonce(address account) internal {
        Nonces storage nonces = Nonces(account);
        nonces.value++;
    }
}
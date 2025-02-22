// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TransactionTypeDetector {
    function supportsEIP1559() internal view returns (bool) {
        return block.basefee > 0;
    }
}
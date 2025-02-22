// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWalletFactory {
    function createWallet(address owner, address entryPoint, bytes32 salt) external returns (address wallet);
    function getWalletAddress(address owner, address entryPoint, bytes32 salt) external view returns (address);
}
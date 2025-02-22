// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IWalletFactory.sol";
import "../proxies/ERC1967Proxy.sol";
import "./Wallet.sol";

contract WalletFactory is IWalletFactory {
    address public immutable walletImplementation;

    constructor(address _walletImplementation) {
        walletImplementation = _walletImplementation;
    }

    function createWallet(
        address owner,
        address entryPoint,
        bytes32 salt
    ) external override returns (address wallet) {
        bytes memory initData = abi.encodeWithSelector(Wallet.initialize.selector, owner, entryPoint);
        wallet = address(new ERC1967Proxy{salt: salt}(walletImplementation, initData));
    }

    function getWalletAddress(
        address owner,
        address entryPoint,
        bytes32 salt
    ) external view override returns (address) {
        bytes memory initData = abi.encodeWithSelector(Wallet.initialize.selector, owner, entryPoint);
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(abi.encodePacked(type(ERC1967Proxy).creationCode, abi.encode(walletImplementation, initData)))
            )
        );
        return address(uint160(uint256(hash)));
    }
}
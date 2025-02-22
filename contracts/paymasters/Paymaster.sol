// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interfaces/IPaymaster.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Paymaster is IPaymaster, Ownable {
    IERC20 public immutable token;
    uint256 public tokenPrice;
    mapping(address => uint256) private lastOperationTime;
    uint256 public rateLimitPeriod = 1 hours;
    bool public whitelistEnabled = false;
    mapping(address => bool) private whitelist;

    constructor(address _token, uint256 _tokenPrice) {
        token = IERC20(_token);
        tokenPrice = _tokenPrice;
    }

    function setTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Invalid price");
        tokenPrice = _newPrice;
    }

    function setRateLimitPeriod(uint256 _period) external onlyOwner {
        rateLimitPeriod = _period;
    }

    function setWhitelistEnabled(bool _enabled) external onlyOwner {
        whitelistEnabled = _enabled;
    }

    function addToWhitelist(address _wallet) external onlyOwner {
        whitelist[_wallet] = true;
    }

    function validatePaymasterUserOp(
        IEntryPoint.UserOperation calldata op,
        bytes32 userOpHash,
        uint256 maxCost
    ) external override returns (bytes memory context, uint256 validationData) {
        require(!whitelistEnabled || whitelist[op.sender], "Wallet not whitelisted");
        require(block.timestamp >= lastOperationTime[op.sender] + rateLimitPeriod, "Rate limit exceeded");

        uint256 requiredTokens = (maxCost * 1e18) / tokenPrice;
        require(token.transferFrom(op.sender, address(this), requiredTokens), "Token transfer failed");

        lastOperationTime[op.sender] = block.timestamp;
        return (abi.encode(op.sender, requiredTokens), 0);
    }

    function postOp(bytes calldata context, uint256 actualGasCost) external override {
        // Optional refund logic can be implemented here
    }
}
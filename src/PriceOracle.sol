// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract PriceOracle is Ownable {
    mapping(address => uint256) public tokenPrices;

    event PriceUpdated(address indexed token, uint256 priceInUSD);

    constructor() Ownable(msg.sender) {}

    function setPrice(address token, uint256 priceInUSD) external onlyOwner {
        require(priceInUSD > 0, "Price must be greater than zero");
        tokenPrices[token] = priceInUSD;
        emit PriceUpdated(token, priceInUSD);
    }

    function getPrice(address token) external view returns (uint256) {
        return tokenPrices[token];
    }
}

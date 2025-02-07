// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MinimalistDEX.sol";
import "../src/PriceOracle.sol";
import "../src/MockToken.sol";

contract DeployDEX is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Price Oracle
        PriceOracle priceOracle = new PriceOracle();
        console.log("PriceOracle deployed at:", address(priceOracle));

        // Deploy MinimalistDEX
        MinimalistDEX dex = new MinimalistDEX(address(priceOracle));
        console.log("MinimalistDEX deployed at:", address(dex));

        // Deploy Mock Tokens
        MockToken tokenA = new MockToken("TokenA", "TKA", 18, 1e24);
        MockToken tokenB = new MockToken("TokenB", "TKB", 6, 1e12);
        MockToken stableA = new MockToken("StableA", "STA", 18, 1e24);
        MockToken stableB = new MockToken("StableB", "STB", 6, 1e12);
        console.log("TokenA deployed at:", address(tokenA));
        console.log("TokenB deployed at:", address(tokenB));
        console.log("StableA deployed at:", address(stableA));
        console.log("StableB deployed at:", address(stableB));

        // Set prices for tokens
        priceOracle.setPrice(address(tokenA), 2e18);
        priceOracle.setPrice(address(tokenB), 4e18);
        priceOracle.setPrice(address(stableA), 1e18);
        priceOracle.setPrice(address(stableB), 1e18);

        // Add liquidity to dex
        tokenA.approve(address(dex), 4e18);
        tokenB.approve(address(dex), 2e6);
        stableA.approve(address(dex), 8e18);
        stableB.approve(address(dex), 8e6);
        dex.addLiquidity(address(tokenA), address(tokenB), 2e18, 1e6);
        dex.addLiquidity(address(stableA), address(stableB), 4e18, 4e6);
        dex.addLiquidity(address(tokenA), address(stableB), 2e18, 4e6);
        dex.addLiquidity(address(tokenB), address(stableA), 1e6, 4e18);

        vm.stopBroadcast();
    }
}

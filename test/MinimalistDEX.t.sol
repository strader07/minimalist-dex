// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MinimalistDEX.sol";
import "../src/PriceOracle.sol";
import "../src/MockToken.sol";

contract MinimalistDEXTest is Test {
    MinimalistDEX dex;
    PriceOracle oracle;
    MockToken tokenA;
    MockToken tokenB;
    MockToken stable1;
    MockToken stable2;
    address user = address(0x123);

    function setUp() public {
        oracle = new PriceOracle();
        dex = new MinimalistDEX(address(oracle));
        tokenA = new MockToken("TokenA", "TKA", 18, 1e24);
        tokenB = new MockToken("TokenB", "TKB", 6, 1e12);
        stable1 = new MockToken("Stable1", "STB1", 18, 1e24);
        stable2 = new MockToken("Stable2", "STB2", 6, 1e12);

        tokenA.transfer(user, 1e21);
        tokenB.transfer(user, 1e9);
        stable1.transfer(user, 1e21);
        stable2.transfer(user, 1e9);

        oracle.setPrice(address(tokenA), 2e18);
        oracle.setPrice(address(tokenB), 1e18);
        oracle.setPrice(address(stable1), 1e18);
        oracle.setPrice(address(stable2), 1e18);
    }

    function testGetPoolKey() public view {
        bytes32 poolKey = dex.getPoolKey(address(tokenA), address(tokenB));
        bytes32 poolKeyReverse = dex.getPoolKey(
            address(tokenB),
            address(tokenA)
        );
        assertEq(poolKey, poolKeyReverse);
    }

    function testAddLiquidity() public {
        vm.startPrank(user);
        tokenA.approve(address(dex), 1e18);
        tokenB.approve(address(dex), 5e6);
        dex.addLiquidity(address(tokenA), address(tokenB), 1e18, 5e6);
        vm.stopPrank();

        (uint256 reserveA, uint256 reserveB, ) = dex.getLiquidityPool(
            address(tokenA),
            address(tokenB)
        );
        assertEq(reserveA, 1e18);
        assertEq(reserveB, 5e6);
    }

    function testSwapSamePriceDifferentDecimals() public {
        vm.startPrank(user);
        stable1.approve(address(dex), 1e18);
        stable2.approve(address(dex), 5e6);
        dex.addLiquidity(address(stable1), address(stable2), 1e18, 5e6);
        stable1.approve(address(dex), 1e18);
        uint256 userPrevBalanceStable1 = stable1.balanceOf(user);
        uint256 userPrevBalanceStable2 = stable2.balanceOf(user);
        dex.swap(address(stable1), address(stable2), 1e18);
        vm.stopPrank();

        uint256 userNewBalanceStable2 = stable2.balanceOf(user);
        assertEq(userNewBalanceStable2, userPrevBalanceStable2 + 1e6);
        uint256 userNewBalanceStable1 = stable1.balanceOf(user);
        assertEq(userNewBalanceStable1, userPrevBalanceStable1 - 1e18);
    }

    function testSwapDifferentPriceSameDecimals() public {
        vm.startPrank(user);
        tokenA.approve(address(dex), 1e18);
        stable1.approve(address(dex), 2e18);
        dex.addLiquidity(address(tokenA), address(stable1), 1e18, 2e18);
        tokenA.approve(address(dex), 1e18);
        uint256 userPrevBalanceTokenA = tokenA.balanceOf(user);
        uint256 userPrevBalanceStable1 = stable1.balanceOf(user);
        dex.swap(address(tokenA), address(stable1), 1e18);
        vm.stopPrank();

        uint256 userNewBalanceStable1 = stable1.balanceOf(user);
        // consider price difference
        uint256 tokenAPrice = oracle.getPrice(address(tokenA));
        uint256 stable1Price = oracle.getPrice(address(stable1));
        assertEq(
            userNewBalanceStable1,
            userPrevBalanceStable1 + (1e18 * tokenAPrice) / stable1Price
        );
        uint256 userNewBalanceTokenA = tokenA.balanceOf(user);
        assertEq(userNewBalanceTokenA, userPrevBalanceTokenA - 1e18);
    }

    function testSwapDifferentPriceDifferentDecimals() public {
        vm.startPrank(user);
        tokenA.approve(address(dex), 1e18);
        stable2.approve(address(dex), 2e6);
        dex.addLiquidity(address(tokenA), address(stable2), 1e18, 2e6);
        tokenA.approve(address(dex), 1e18);
        uint256 userPrevBalanceTokenA = tokenA.balanceOf(user);
        uint256 userPrevBalanceStable2 = stable2.balanceOf(user);
        dex.swap(address(tokenA), address(stable2), 1e18);
        vm.stopPrank();

        uint256 userNewBalanceStable2 = stable2.balanceOf(user);
        // consider price difference
        uint256 tokenAPrice = oracle.getPrice(address(tokenA));
        uint256 stable2Price = oracle.getPrice(address(stable2));
        // consider decimal difference
        uint256 stable2Decimals = stable2.decimals();
        uint256 tokenADecimals = tokenA.decimals();
        uint256 convertedStable2Amount = (1e18 * tokenAPrice) / stable2Price;
        uint256 convertedStable2AmountWithDecimals = convertedStable2Amount /
            (10 ** (tokenADecimals - stable2Decimals));
        assertEq(
            userNewBalanceStable2,
            userPrevBalanceStable2 + convertedStable2AmountWithDecimals
        );
        uint256 userNewBalanceTokenA = tokenA.balanceOf(user);
        assertEq(userNewBalanceTokenA, userPrevBalanceTokenA - 1e18);
    }

    function testRemoveLiquidity() public {
        vm.startPrank(user);
        tokenA.approve(address(dex), 1e18);
        tokenB.approve(address(dex), 5e6);
        dex.addLiquidity(address(tokenA), address(tokenB), 1e18, 5e6);
        dex.removeLiquidity(address(tokenA), address(tokenB), 50);
        vm.stopPrank();

        (uint256 reserveA, uint256 reserveB, ) = dex.getLiquidityPool(
            address(tokenA),
            address(tokenB)
        );
        assertEq(reserveA, (1e18 * (100 - 50)) / 100);
        assertEq(reserveB, (5e6 * (100 - 50)) / 100);
    }

    // reverts
    function test_RevertIf_AddLiquidity_SameToken() public {
        vm.expectRevert("Tokens must be different");
        dex.addLiquidity(address(tokenA), address(tokenA), 1e18, 5e6);
    }

    function test_RevertIf_AddLiquidity_ZeroAmount() public {
        vm.expectRevert("Invalid liquidity amount");
        dex.addLiquidity(address(tokenA), address(tokenB), 0, 5e6);
    }

    function test_RevertIf_RemoveLiquidity_ZeroPercent() public {
        vm.expectRevert("Invalid percent");
        dex.removeLiquidity(address(tokenA), address(tokenB), 0);
    }

    function test_RevertIf_RemoveLiquidity_Exceeds100Percent() public {
        vm.expectRevert("Invalid percent");
        dex.removeLiquidity(address(tokenA), address(tokenB), 101);
    }

    function test_RevertIf_RemoveLiquidity_NonExistentPool() public {
        vm.expectRevert("Liquidity pool does not exist");
        dex.removeLiquidity(address(tokenA), address(tokenB), 50);
    }

    function test_RevertIf_RemoveLiquidity_NoLiquidity() public {
        vm.startPrank(user);
        tokenA.approve(address(dex), 1e18);
        tokenB.approve(address(dex), 5e6);
        dex.addLiquidity(address(tokenA), address(tokenB), 1e18, 5e6);
        tokenA.approve(address(dex), 1e18);
        dex.swap(address(tokenA), address(tokenB), 1e18);
        vm.stopPrank();

        vm.expectRevert("No liquidity to remove");
        dex.removeLiquidity(address(tokenA), address(tokenB), 50);
    }

    function test_RevertIf_Swap_IdenticalTokens() public {
        vm.expectRevert("Invalid swap pair");
        dex.swap(address(tokenA), address(tokenA), 1e18);
    }

    function test_RevertIf_Swap_ZeroAmount() public {
        vm.expectRevert("Invalid swap amount");
        dex.swap(address(tokenA), address(tokenB), 0);
    }

    function test_RevertIf_Swap_InvalidPricePair() public {
        MockToken unknownToken = new MockToken("Unknown", "UNK", 18, 1e24);
        vm.expectRevert("Invalid pair price");
        dex.swap(address(tokenA), address(unknownToken), 1e18);
    }

    function test_RevertIf_Swap_NotEnoughLiquidity() public {
        vm.startPrank(user);
        tokenA.approve(address(dex), 1e18);
        stable1.approve(address(dex), 2e18);
        dex.addLiquidity(address(tokenA), address(stable1), 1e18, 2e18);
        vm.stopPrank();

        vm.expectRevert("Not enough liquidity");
        dex.swap(address(stable1), address(tokenA), 3e18);
    }
}

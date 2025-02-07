// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MockToken.sol";

contract MockTokenTest is Test {
    MockToken token;
    address user = address(0x123);

    function setUp() public {
        token = new MockToken("Mock Token", "MOCK", 18, 1e24);
        token.transfer(user, 1e21);
    }

    function testDecimals() public view {
        assertEq(token.decimals(), 18);
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1e24);
    }

    function testTransfer() public {
        vm.startPrank(user);
        token.transfer(address(0x456), 1e20);
        vm.stopPrank();

        assertEq(token.balanceOf(address(0x456)), 1e20);
        assertEq(token.balanceOf(user), 9e20);
    }
}

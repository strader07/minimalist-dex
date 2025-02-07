// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PriceOracle.sol";

contract PriceOracleTest is Test {
    PriceOracle private priceOracle;
    address private owner;
    address private nonOwner;
    address private token;

    event PriceUpdated(address indexed token, uint256 priceInUSD);

    function setUp() public {
        owner = address(this); // The test contract itself is the owner
        nonOwner = address(0x1234);
        token = address(0x5678);
        priceOracle = new PriceOracle();
    }

    function testSetAndGetPrice() public {
        uint256 price = 100e18;
        priceOracle.setPrice(token, price);
        assertEq(priceOracle.getPrice(token), price);
    }

    function test_RevertWhen_NonOwnerSetsPrice() public {
        vm.prank(nonOwner);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                nonOwner
            )
        );
        priceOracle.setPrice(token, 100e18);
    }

    function testSetPriceEmitsEvent() public {
        uint256 price = 150e18;
        vm.expectEmit(true, true, false, true);
        emit PriceUpdated(token, price);
        priceOracle.setPrice(token, price);
    }

    function testSetZeroPrice() public {
        vm.expectRevert("Price must be greater than zero");
        priceOracle.setPrice(token, 0);
    }

    function testGetPriceBeforeSet() public view {
        assertEq(priceOracle.getPrice(token), 0);
    }
}

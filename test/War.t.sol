// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {War} from "../src/War.sol";

contract WarTest is Test {
    War public war;
    address owner = address(123);

    function setUp() public {
        vm.prank(owner);
        war = new War();
    }

    function testFail_Mint() public {
        war.mint(address(this), 100);
    }

    function testMintOwner() public {
        assertEq(war.balanceOf(owner), 1e20);
        assertEq(war.owner(), owner);
        vm.prank(owner);
        war.mint(address(this), 100);
        assertEq(war.balanceOf(address(this)), 100);
    }
}

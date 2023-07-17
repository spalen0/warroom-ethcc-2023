// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {DasProxy} from "../src/proxy/DasProxy.sol";
import {Impl} from "../src/proxy/Impl.sol";

contract ProxyScript is Script {

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Impl impl = new Impl();
        console.log("Impl address: %s", address(impl));
        DasProxy proxy = new DasProxy(address(impl), "");
        console.log("Proxy address: %s", address(proxy));
        
        // (bool validResponse, bytes memory returnedData) = address(proxy).call(
        //     abi.encodeWithSignature("initialize()")
        // );
        // assertTrue(validResponse);
        // (validResponse, returnedData) = address(proxy).call(
        //     abi.encodeWithSignature("owner()")
        // );
        // assertTrue(validResponse);
        // address owner = abi.decode(returnedData, (address));
        // assertEq(owner, vm.addr(deployerPrivateKey));

        vm.stopBroadcast();
    }
}

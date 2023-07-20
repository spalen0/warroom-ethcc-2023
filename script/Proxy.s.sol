// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {Constants} from "./Constants.sol";
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
        console.log("Proxy address: %s",address(proxy));
        
        vm.stopBroadcast();
    }
}

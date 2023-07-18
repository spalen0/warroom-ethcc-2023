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

        for (uint256 i; i < Constants.NUMBER_OF_TEAMS; i++) {
            Impl impl = new Impl();
            console.log("Impl address x%d: %s", i, address(impl));
            DasProxy proxy = new DasProxy(address(impl), "");
            console.log("Proxy address x%d: %s", i, address(proxy));
        }

        vm.stopBroadcast();
    }
}

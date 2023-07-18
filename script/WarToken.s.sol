// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {War} from "../src/War.sol";

contract WarScript is Script {

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        War war = new War();
        console.log("War address: %s", address(war));
        vm.stopBroadcast();
    }
}

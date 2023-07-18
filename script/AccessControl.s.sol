// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {Constants} from "./Constants.sol";
import {AccessControl} from "../src/accesscontrol/AccessControl.sol";
import {RewardsBox} from "../src/accesscontrol/RewardsBox.sol";

contract AccessControlScript is Script {

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        for (uint256 i; i < Constants.NUMBER_OF_TEAMS; i++) {
            AccessControl accessControl = new AccessControl();
            console.log("AccessControl address x%d: %s", i, address(accessControl));
            RewardsBox rewardsBox = new RewardsBox(Constants.WAR_TOKEN, address(accessControl));
            console.log("RewardsBox address x%d: %s", i, address(rewardsBox));
            IERC20(Constants.WAR_TOKEN).transfer(address(rewardsBox), Constants.TASK_4);
        }

        vm.stopBroadcast();
    }
}

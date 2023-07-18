// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {AccessControl} from "../src/accesscontrol/AccessControl.sol";
import {RewardsBox} from "../src/accesscontrol/RewardsBox.sol";

contract AccessControlScript is Script {
    // @todo set reward token address for all tasks
    address public rewardToken = 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa;
    // @todo define amount we want to send
    uint256 public rewardAmount = 35 * 1e18;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AccessControl accessControl = new AccessControl();
        console.log("AccessControl address: %s", address(accessControl));
        RewardsBox rewardsBox = new RewardsBox(rewardToken, address(accessControl));
        console.log("RewardsBox address: %s", address(rewardsBox));

        // @note define flow and amount
        IERC20(rewardToken).transfer(address(rewardsBox), rewardAmount);

        vm.stopBroadcast();
    }
}

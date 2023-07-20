// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Constants} from "./Constants.sol";
import {WhitelistedRewards} from "../src/signature/WhitelistedRewards.sol";

contract SignatureScript is Script {

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address signer = vm.addr(deployerPrivateKey);
        address[] memory whitelisted = new address[](1);
        whitelisted[0] = signer;

        for (uint256 i = 0; i < Constants.NUMBER_OF_TEAMS; i++) {
            WhitelistedRewards rewardsContract = new WhitelistedRewards(Constants.WAR_TOKEN, whitelisted);
            console.log("Rewards address x%d: %s", i, address(rewardsContract));
            // @note multiply by 3 because 1/3 will go to attacker, 1/3 is left to trick the attacker to change the amount
            IERC20(Constants.WAR_TOKEN).transfer(address(rewardsContract), Constants.TASK_3 * 3);

            // claim only 1/3 because 1/3 will go to attacker, 1/3 is left to trick the attacker to change the amount
            uint256 claimAmount = Constants.TASK_3;
            bytes32 digest = keccak256(abi.encodePacked(claimAmount));
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployerPrivateKey, digest);
            rewardsContract.claim(signer, claimAmount, v, r, s);
        }

        vm.stopBroadcast();
    }
}

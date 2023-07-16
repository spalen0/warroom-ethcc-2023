// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {WhitelistedRewards} from "../src/signature/WhitelistedRewards.sol";

contract SignatureScript is Script {
    // @todo set reward token address for all tasks
    address public rewardToken = 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa;
    // @todo define amount we want to send, only 1/3 will be claimed
    uint256 public rewardAmount = 1e20;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address signer = vm.addr(deployerPrivateKey);
        address[] memory whitelisted = new address[](1);
        whitelisted[0] = signer;
        WhitelistedRewards rewardsContract = new WhitelistedRewards(rewardToken, whitelisted);
        console.log("Rewards address: %s", address(rewardsContract));

        // or mint if it is easeir
        IERC20(rewardToken).transfer(address(rewardsContract), rewardAmount);
        // ERC20(rewardToken).mint(address(rewardsContract), rewardAmount);

        // claim only 1/3 because 1/3 will go to attacker, 1/3 is left to trick the attacker to change the amount
        uint256 claimAmount = rewardAmount / 3;
        bytes32 digest = keccak256(abi.encodePacked(claimAmount));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(deployerPrivateKey, digest);
        rewardsContract.claim(signer, claimAmount, v, r, s);
        vm.stopBroadcast();
    }
}

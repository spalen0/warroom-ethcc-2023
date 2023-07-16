// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Loan} from "../src/flashloan/Loan.sol";

contract LoanScript is Script {
    // @todo set reward token address for all tasks
    address public rewardToken = 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa;
    // @todo define amount we want to send, only 1/3 will be claimed
    uint256 public rewardAmount = 1e20;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Loan loan = new Loan(rewardToken);
        console.log("Loan address: %s", address(loan));

        // @note define flow and amount
        IERC20(rewardToken).transfer(address(loan), rewardAmount);

        vm.stopBroadcast();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {Constants} from "./Constants.sol";
import {Loan} from "../src/flashloan/Loan.sol";

contract LoanScript is Script {

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        for (uint256 i; i < Constants.NUMBER_OF_TEAMS; i++) {
            Loan loan = new Loan(Constants.WAR_TOKEN);
            console.log("Loan address #%d: %s", i, address(loan));
            IERC20(Constants.WAR_TOKEN).transfer(address(loan), Constants.TASK_2);
        }

        vm.stopBroadcast();
    }
}

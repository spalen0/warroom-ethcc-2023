// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Constants} from "./Constants.sol";
import {Factory} from "../src/metamorphic/Factory.sol";
import {Destroy} from "../src/metamorphic/Destroy.sol";
import {Multiplier} from "../src/metamorphic/Multiplier.sol";
import {Multiplier2} from "../src/metamorphic/Multiplier2.sol";

contract MetamorphicScript is Script {

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        for (uint256 i; i < Constants.NUMBER_OF_TEAMS; i++) {
            Factory factoryContract = new Factory();
            console.log("Factory address #%d: %s", i, address(factoryContract));

            bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier.sol"));
            address multiplierAddr = factoryContract.deploy(1, bytecode);
            console.log("Multiplier address #%d: %s", i, multiplierAddr);

            Multiplier(multiplierAddr).init(Constants.WAR_TOKEN, 2);

            IERC20(Constants.WAR_TOKEN).transfer(multiplierAddr, Constants.TASK_BOUNS);
        }

        vm.stopBroadcast();
    }
}

contract MetamorphicDestroy is Script {
    // @note we can use the same address for all
    address public destroyAddr = 0x9813563D8f813400E535A5a3c3C9BF2e35858D9a;
    address public multiplierAddr = 0xfAD015E4130D545856dC287A30b47488a06d740b;
    // @todo fill with all addresses that have claimed
    address[1] public multiplierAddrs = [multiplierAddr];

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // @todo destroy only for the teams that have claimed
        for (uint256 i; i < multiplierAddrs.length; i++) {
            Multiplier(multiplierAddrs[i]).sweep(destroyAddr); // Calls selfdestruct
        }

        vm.stopBroadcast();
    }
}

contract MetamorphicDeployNew is Script {
    address public factoryAddr = 0x41176aF82F07deaa5B0ec35906Fddd636bA873c7;
    // @todo define all factory addresses that have claimed
    address[1] public factoryAddrs = [factoryAddr];

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        for (uint256 i; i < factoryAddrs.length; i++) {
            Factory factoryContract = Factory(factoryAddrs[i]);

            bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier2.sol"));
            address newMultiplierAddr = factoryContract.deploy(1, bytecode);
            console.log("Multiplier address: %s", newMultiplierAddr);

            Multiplier2(newMultiplierAddr).init(Constants.WAR_TOKEN, 2);
        }

        vm.stopBroadcast();
    }
}

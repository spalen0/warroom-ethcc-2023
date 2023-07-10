// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import {MetamorphicFactory} from "../src/metamorphic/MetamorphicFactory.sol";
import {Destroy} from "../src/metamorphic/Destroy.sol";
import {Multiplier} from "../src/metamorphic/Multiplier.sol";
import {Multiplier2} from "../src/metamorphic/Multiplier2.sol";

contract MetamorphicScript is Script {
    address public weth = 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MetamorphicFactory factoryContract = new MetamorphicFactory();
        console.log("Factory address: %s", address(factoryContract));

        bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier.sol"));
        address multiplierAddr = factoryContract.deploy(1, bytecode);
        console.log("Multiplier address: %s", multiplierAddr);

        Multiplier(multiplierAddr).init(weth, 2);

        vm.stopBroadcast();
    }
}

contract MetamorphicDestroy is Script {
    // @todo change factory and multipler address
    address public factoryAddr = 0x41176aF82F07deaa5B0ec35906Fddd636bA873c7;
    address public multiplierAddr = 0xfAD015E4130D545856dC287A30b47488a06d740b;

    address public destroyAddr = 0x9813563D8f813400E535A5a3c3C9BF2e35858D9a;
    address public weth = 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Multiplier(multiplierAddr).sweep(destroyAddr); // Calls selfdestruct

        vm.stopBroadcast();
    }
}

contract MetamorphicDeployNew is Script {
    // @todo change factory and multipler address
    address public factoryAddr = 0x41176aF82F07deaa5B0ec35906Fddd636bA873c7;
    address public multiplierAddr = 0xfAD015E4130D545856dC287A30b47488a06d740b;

    address public destroyAddr = 0x9813563D8f813400E535A5a3c3C9BF2e35858D9a;
    address public weth = 0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MetamorphicFactory factoryContract = MetamorphicFactory(factoryAddr);

        bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier2.sol"));
        address newMultiplierAddr = factoryContract.deploy(1, bytecode);
        console.log("Multiplier address: %s", newMultiplierAddr);

        Multiplier2(newMultiplierAddr).init(weth, 2);

        vm.stopBroadcast();
    }
}

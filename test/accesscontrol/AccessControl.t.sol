pragma solidity 0.8.20;

import "forge-std/Test.sol";

import {AccessControl} from "../../src/accesscontrol/AccessControl.sol";
import {RewardsBox} from "../../src/accesscontrol/RewardsBox.sol";
import {Attack} from "./Attack.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract AccessControlTest is Test {
    ERC20 public reward;
    RewardsBox public rewardsBox;
    uint256 public rewardAmount = 1e18;

    function setUp() public {
        reward = new ERC20("Wrapped Ether", "WETH");
        rewardsBox = new RewardsBox(address(reward), address(new AccessControl()));
        deal(address(reward), address(rewardsBox), rewardAmount);
    }

    function testFail_claim() public {
        AccessControl accessController = new AccessControl();
        rewardsBox.claim(address(accessController), 1);
    }

    function test_codeHash() public {
        AccessControl accessController = new AccessControl();
        require(address(accessController).codehash == rewardsBox.accessControlHash());
    }

    function test_attackSuccess() public {
        Attack attack = new Attack();
        attack.pwn(address(rewardsBox), address(reward));
        require(reward.balanceOf(address(this)) == 1e18);
    }
}

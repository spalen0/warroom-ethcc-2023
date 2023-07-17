// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "./AccessControl.sol";

contract RewardsBox {
    bytes32 public accessControlHash = 0x1b39c3e30ac0e9fe9cda3e9315480ff6bff1fdba94ea0302844a726fa1d62c03;
    IERC20 public immutable rewardToken;

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    function claim(address accessController, uint256 amount) public {
        require(accessController.codehash == accessControlHash);
        require(AccessControl(accessController).claim(msg.sender));
        rewardToken.transfer(msg.sender, amount);
    }
}
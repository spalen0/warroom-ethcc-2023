// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "./AccessControl.sol";

contract RewardsBox {
    bytes32 public accessControlHash;
    IERC20 public immutable rewardToken;

    constructor(address _rewardToken, address accessControl) {
        rewardToken = IERC20(_rewardToken);
        accessControlHash = accessControl.codehash;
    }

    function claim(address accessController, uint256 amount) public {
        require(accessController.codehash == accessControlHash);
        require(AccessControl(accessController).claim(msg.sender));
        rewardToken.transfer(msg.sender, amount);
    }
}
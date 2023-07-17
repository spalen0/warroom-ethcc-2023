// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "./AccessControl.sol";

contract RewardsBox {
    bytes32 public accessControlHash = 0x52275cb721a97dd9407ac8636da0bbf09e03406462dc83a0065f9a7e374d013f;
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
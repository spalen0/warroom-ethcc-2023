// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Multiplier {
    address public rewardToken;
    uint256 public multiplier;
    address public owner;
    mapping(address => bool) public claimed;

    function init(address _rewardToken, uint256 _multiplier) public {
        require(owner == address(0), "Multiplier: Already initialized");
        rewardToken = _rewardToken;
        multiplier = _multiplier;
        owner = msg.sender;
    }

    function setClaimed(address user, bool status) external {
        require(msg.sender == owner, "Multiplier: Only owner");
        claimed[user] = status;
    }

    function multiply(uint256 amount) external returns (uint256 result) {
        result = amount * multiplier;
        require(IERC20(rewardToken).balanceOf(address(this)) >= result, "Unwrapper: Not enough balance");
        require(IERC20(rewardToken).allowance(msg.sender, address(this)) > result, "Unwrapper: Not approved");
        require(!claimed[msg.sender], "Multiplier: Already claimed");
        claimed[msg.sender] = true;
        IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        IERC20(rewardToken).transfer(msg.sender, result);
    }

    function sweep(address token) external {
        require(msg.sender == owner, "Unwrapper: Only owner");
        (bool status, ) = token.delegatecall(
            abi.encodeWithSignature("sweep()")
        );
        if (!status) revert();        
    }
}

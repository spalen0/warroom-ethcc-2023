// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Multiplier {
    address public weth;
    uint256 public multiplier;
    address public owner;
    
    // constructor(address _weth, uint256 _multiplier) {
    function init(address _weth, uint256 _multiplier) public {
        require(owner == address(0), "Multiplier: Already initialized");
        weth = _weth;
        multiplier = _multiplier;
        owner = msg.sender;
    }

    function multiply(uint256 amount) external returns (uint256 result) {
        result = amount * multiplier;
        require(IERC20(weth).balanceOf(address(this)) >= result, "Unwrapper: Not enough balance");
        require(IERC20(weth).allowance(msg.sender, address(this)) > result, "Unwrapper: Not approved");
        IERC20(weth).transferFrom(msg.sender, address(this), amount);
        IERC20(weth).transfer(msg.sender, result);
    }

    function sweep(address token) external {
        require(msg.sender == owner, "Unwrapper: Only owner");
        (bool status, ) = token.delegatecall(
            abi.encodeWithSignature("sweep()")
        );
        if (!status) revert();        
    }
}

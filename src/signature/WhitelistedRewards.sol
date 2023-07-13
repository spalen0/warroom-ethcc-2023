// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract WhitelistedRewards {
    IERC20 public immutable rewardToken;
    mapping(address => bool) public whitelisted;
    mapping(bytes => bool) public used;

    constructor(address _rewardToken, address[] memory _whitelisted) {
        rewardToken = IERC20(_rewardToken);
        for (uint256 i = 0; i < _whitelisted.length; i++) {
            whitelisted[_whitelisted[i]] = true;
        }
    }

    function whitelist(address _whitelist) external {
        require(whitelisted[msg.sender], "!whitelisted");
        whitelisted[_whitelist] = true;
    }

    function claim(address receiver, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 hash = keccak256(abi.encodePacked(amount));
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "!signature");
        require(whitelisted[signer], "!whitelisted");
        bytes memory signature = abi.encodePacked(v, r, s);
        require(!used[signature], "used");
        used[signature] = true;

        rewardToken.transfer(receiver, amount);
    }
}

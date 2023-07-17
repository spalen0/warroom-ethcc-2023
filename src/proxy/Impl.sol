// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract Impl is UUPSUpgradeable, Ownable {

    function initialize() public {
        _transferOwnership(msg.sender);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}

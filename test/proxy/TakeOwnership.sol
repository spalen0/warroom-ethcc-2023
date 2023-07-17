// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/proxy/utils/UUPSUpgradeable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract TakeOwnership is UUPSUpgradeable, Ownable {

    function _authorizeUpgrade(address) internal override onlyOwner {}

}

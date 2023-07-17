// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CodeHashGetter {
    function gh(address c) public view returns (bytes32) {
        return c.codehash;
    }
}
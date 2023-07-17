// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract AccessControl {
    // in the event that an owner is not available,
    // we rely on social consensus and set BACKUP_ADMIN to vitalik.eth
    address public immutable BACKUP_ADMIN = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    mapping(address => bool) public owners;
    bool private claimed;

    modifier onlyOwner() {
        require(owners[msg.sender]);
        _;
    }

    constructor() {
        claimed = false;
        // set primary owner
        owners[0xFd66594cB460DA87c30CD38A4b96f54Ce811Dd7e] = true;
    }

    function setOwner(address newOwner) public onlyOwner {
        owners[newOwner] = true;
    }

    function removeOwner(address oldOwner) public onlyOwner {
        owners[oldOwner] = false;
    }

    function checkAccess(address user) public view returns (bool) {
        return owners[user] || user == BACKUP_ADMIN;
    }

    function claim(address claimant) public returns (bool) {
        require(checkAccess(claimant));
        require(!claimed);
        claimed = true;
        return claimed;
    }
}
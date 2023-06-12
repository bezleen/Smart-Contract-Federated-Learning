// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TrainerManagerment {
    mapping(address => bool) private _blocklist;
    mapping(address => bool) private _allowlist;
    // event
    event trainerAddedToBlocklist(address indexed trainer);
    event trainerAddedToAllowlist(address indexed trainer);
    event trainerRemovedFromBlocklist(address indexed trainer);
    event trainerRemovedFromAllowlist(address indexed trainer);

    constructor() {}

    function addToBlocklist(address trainer) external {
        // TODO: add a modifer to check if the msg.sender is admin or not
        require(!_blocklist[trainer], "trainer is already in blocklist");
        _blocklist[trainer] = true;
        emit trainerAddedToBlocklist(trainer);
    }

    function removeFromBlocklist(address trainer) external {
        // TODO: add a modifer to check if the msg.sender is admin or not
        require(_blocklist[trainer], "trainer is not blocked");
        _blocklist[trainer] = false;
        emit trainerRemovedFromBlocklist(trainer);
    }

    function addToAllowlist(address trainer) external {
        // TODO: add a modifer to check if the msg.sender is admin or not
        require(!_allowlist[trainer], "trainer is already in allowlist");
        _allowlist[trainer] = true;
        emit trainerAddedToAllowlist(trainer);
    }

    function removeFromAllowlist(address candidate) external {
        // TODO: add a modifer to check if the msg.sender is admin or not
        require(_allowlist[candidate], "candidate is not allowed in allowlist");
        _allowlist[candidate] = false;
        emit trainerRemovedFromAllowlist(candidate);
    }

    function isAllowed(address trainer) external view returns (bool) {
        return _allowlist[trainer];
    }

    function isBlocked(address trainer) external view returns (bool) {
        return _blocklist[trainer];
    }
}

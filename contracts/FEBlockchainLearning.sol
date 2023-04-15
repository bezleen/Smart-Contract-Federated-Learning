// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Aggregator.sol";
import "./Trainer.sol";

contract FEBlockchainLearning is AccessControl, Aggregator, Trainer {
    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;

    // AccessControl
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CLIENT_ROLE = keccak256("CLIENT_ROLE");
    bytes32 public constant TRAINER_ROLE = keccak256("TRAINER_ROLE");
    bytes32 public constant AGGREGATOR_ROLE = keccak256("AGGREGATOR_ROLE");

    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender) == true, "Required role");
        _;
    }

    constructor() Aggregator() Trainer() {
        admin = payable(msg.sender);
        _setupRole(ADMIN_ROLE, admin);
    }

    function addTrainer(address trainerAddress) external onlyRole(ADMIN_ROLE) {}

    function addAggregator(
        address trainerAddress
    ) external onlyRole(ADMIN_ROLE) {}
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITrainer {
    function getRandomTrainer(
        uint256 seed
    ) external view returns (uint256 nextSeed, address trainerAddress);
    // TODO: define more function signatures
}

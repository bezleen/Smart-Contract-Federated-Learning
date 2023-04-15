// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAggregator {
    function getRandomAggregator(
        uint256 seed
    ) external view returns (uint256 nextSeed, address aggregatorAddress);
    // TODO: define more function signatures
}

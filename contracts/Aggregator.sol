// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Base.sol";
import "../interfaces/IAggregator.sol";
import "./Utils.sol";
import "./AggregatorDetails.sol";

abstract contract Aggregator is Base, IAggregator {
    using AggregatorDetails for AggregatorDetails.ItemDetail;

    AggregatorDetails.ItemDetail private aggregatorDetail;

    address[] private trainers;

    constructor() Base() {}

    // TODO: handle logic here

    function exampleRandom1() external view {
        uint256 targetBlock = block.number + 5;
        uint256 seed = uint256(blockhash(targetBlock));
        uint256 randomNumber;
        (seed, randomNumber) = Utils.randomRange(seed, 1, 10);
    }
}

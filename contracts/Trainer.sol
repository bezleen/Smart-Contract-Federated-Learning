// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Base.sol";
import "../interfaces/ITrainer.sol";
import "./Utils.sol";
import "./TrainerDetails.sol";

abstract contract Trainer is Base, ITrainer {
    using TrainerDetails for TrainerDetails.ItemDetail;

    TrainerDetails.ItemDetail private TrainerDetail;

    address[] private trainers;

    constructor() Base() {}

    // TODO: handle logic here

    function exampleRandom() external view {
        uint256 targetBlock = block.number + 5;
        uint256 seed = uint256(blockhash(targetBlock));
        uint256 randomNumber;
        (seed, randomNumber) = Utils.randomRange(seed, 1, 10);
    }
}

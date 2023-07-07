// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../interfaces/IFEBlockchainLearning.sol";

abstract contract AFEBlockchainLearning is IFEBlockchainLearning {
    function MIN_TRAINER_IN_ROUND() public view virtual returns (uint256);

    function countScores(
        uint256 sessionId,
        uint256 round
    ) public view virtual returns (uint256[] memory);
}

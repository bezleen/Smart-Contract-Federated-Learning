// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "../interfaces/IPerformanceRewardDistribution.sol";

abstract contract APerformanceRewardDistribution is
    IPerformanceRewardDistribution
{
    function isClaim(
        address trainer,
        uint256 sessionId,
        uint256 round
    ) public view virtual returns (bool);
}

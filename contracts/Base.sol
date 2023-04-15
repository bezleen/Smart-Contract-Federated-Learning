// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Base {
    enum RoundStatus {
        Training,
        Scoring,
        Aggregating
    }
}

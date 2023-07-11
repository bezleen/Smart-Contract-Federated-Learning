// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract FEBlockchainLearning {
    enum RoundStatus {
        Ready,
        Training,
        TrainingFailed,
        Checking,
        Checked,
        Aggregating,
        Testing,
        End,
        ChoseAggregator
    }
    struct BaseReward {
        uint256 trainingReward;
        uint256 checkingReward;
        uint256 aggregatingReward;
        uint256 testingReward;
    }
    struct Info {
        uint256 sessionId;
        address owner;
        uint256 performanceReward;
        BaseReward baseReward;
        uint256 maxRound;
        uint256 currentRound;
        uint256 maxTrainerInOneRound;
        RoundStatus status;
    }

    struct Detail {
        Info info;
        uint256 globalModelId;
        uint256 latestGlobalModelParamId;
        uint256 indexAggregator;
        uint256 countSubmitted;
        uint256 numberOfErrorTrainerUpdateId;
    }
    Detail private _sessions;
    uint256 private _countTrainer;
    mapping(uint256 => address) private _trainers;

    // submit round 1
    uint256 private _countSubmit1;
    uint256 private _countCheck1;
    uint256 private _aggregatorIndex1;
    uint256 private _countScore1;
    mapping(address => uint256) private _trainersToSubmit1;
    // submit round 2
    uint256 private _countSubmit2;
    uint256 private _countCheck2;
    uint256 private _aggregatorIndex2;
    uint256 private _countScore2;
    mapping(address => uint256) private _trainersToSubmit2;
    // submit round 3
    uint256 private _countSubmit3;
    uint256 private _countCheck3;
    uint256 private _aggregatorIndex3;
    uint256 private _countScore3;
    mapping(address => uint256) private _trainersToSubmit3;

    constructor() {}

    function createSession(
        uint256 sessionId,
        uint256 valueRandomClientSide,
        uint256 maxRound,
        uint256 maxTrainerInOneRound,
        uint256 globalModelId,
        uint256 latestGlobalModelParamId,
        uint256 expirationTimeOfTrainingRound,
        uint256 expirationTimeOfCheckingRound,
        uint256 expirationTimeOfAggregatingRound,
        uint256 expirationTimeOfTestingRound
    ) external payable {
        Detail memory sDetail;
        sDetail.info.sessionId = sessionId;
        sDetail.info.owner = msg.sender;
        sDetail.info.status = RoundStatus.Ready;
        sDetail.info.performanceReward = (msg.value * 80) / 100 / maxRound;
        sDetail.info.baseReward.trainingReward =
            (msg.value * 5) /
            100 /
            maxRound /
            maxTrainerInOneRound;
        sDetail.info.baseReward.checkingReward =
            (msg.value * 5) /
            100 /
            maxRound /
            maxTrainerInOneRound;
        sDetail.info.baseReward.aggregatingReward =
            (msg.value * 5) /
            100 /
            maxRound;
        sDetail.info.baseReward.testingReward =
            (msg.value * 5) /
            100 /
            maxRound /
            maxTrainerInOneRound;
        sDetail.info.maxRound = maxRound;
        sDetail.info.maxTrainerInOneRound = maxTrainerInOneRound;
        sDetail.globalModelId = globalModelId;
        sDetail.latestGlobalModelParamId = latestGlobalModelParamId;
        sDetail.indexAggregator = 5 + 1;
        _sessions = sDetail;
    }

    function allSession() external view returns (Info[] memory) {
        Info[] memory sessionInfo = new Info[](1);
        sessionInfo[0] = _sessions.info;
        return sessionInfo;
    }

    function sessionById(
        uint256 sessionId
    ) external view returns (Info memory session) {
        return _sessions.info;
    }

    function applySession(uint256 sessionId) external payable {
        _trainers[_countTrainer] = msg.sender;
        _countTrainer += 1;
        if (_countTrainer == 5) {
            _sessions.info.status = RoundStatus.Training;
        }
    }

    function getDataDoTraining(
        uint256 sessionId
    ) external view returns (uint256, uint256) {
        return (_sessions.globalModelId, _sessions.latestGlobalModelParamId);
    }

    function submitUpdate(
        uint256 sessionId,
        uint256 updateId
    ) external payable {
        if (_sessions.info.currentRound == 0) {
            _trainersToSubmit1[msg.sender] = updateId;
            _countSubmit1 += 1;
            if (_countSubmit1 == 5) {
                _sessions.info.status = RoundStatus.Checking;
            }
        }
        if (_sessions.info.currentRound == 1) {
            _trainersToSubmit2[msg.sender] = updateId;
            _countSubmit2 += 1;
            if (_countSubmit2 == 5) {
                _sessions.info.status = RoundStatus.Checking;
            }
        }
        if (_sessions.info.currentRound == 2) {
            _trainersToSubmit3[msg.sender] = updateId;
            _countSubmit3 += 1;
            if (_countSubmit3 == 5) {
                _sessions.info.status = RoundStatus.Checking;
            }
        }
    }

    function getDataDoChecking(
        uint256 sessionId,
        address sender_
    ) external view returns (uint256[] memory) {
        uint256 indexResp = 0;
        uint256[] memory submisIds = new uint256[](4);
        if (_sessions.info.currentRound == 0) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                if (trainerByIndex == sender_) {
                    continue;
                }
                submisIds[indexResp] = _trainersToSubmit1[trainerByIndex];
                indexResp += 1;
            }
        }
        if (_sessions.info.currentRound == 1) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                if (trainerByIndex == sender_) {
                    continue;
                }
                submisIds[indexResp] = _trainersToSubmit2[trainerByIndex];
                indexResp += 1;
            }
        }
        if (_sessions.info.currentRound == 2) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                if (trainerByIndex == sender_) {
                    continue;
                }
                submisIds[indexResp] = _trainersToSubmit3[trainerByIndex];
                indexResp += 1;
            }
        }
        return submisIds;
    }

    function submitCheckingResult(
        uint256 sessionId,
        bool[] memory result
    ) external payable {
        if (_sessions.info.currentRound == 0) {
            _countCheck1 += 1;
            if (_countCheck1 == 5) {
                _sessions.info.status = RoundStatus.Checked;
            }
        }
        if (_sessions.info.currentRound == 1) {
            _countCheck2 += 1;
            if (_countCheck2 == 5) {
                _sessions.info.status = RoundStatus.Checked;
            }
        }
        if (_sessions.info.currentRound == 2) {
            _countCheck3 += 1;
            if (_countCheck3 == 5) {
                _sessions.info.status = RoundStatus.Checked;
            }
        }
    }

    function selectCandidateAggregator(
        uint256 sessionId
    ) external view returns (uint256 candidatesEncode) {
        candidatesEncode = 1;
    }

    function submitIndexCandidateAggregator(
        uint256 sessionId,
        uint256 candidatesEncode
    ) external {
        _sessions.indexAggregator = candidatesEncode;
        _sessions.info.status = RoundStatus.ChoseAggregator;
    }

    function checkOpportunityAggregate(
        uint256 sessionId,
        address candidate
    ) external view returns (bool) {
        if (_trainers[_sessions.indexAggregator] == candidate) {
            return true;
        }
        return false;
    }

    function getDataDoAggregate(
        uint256 sessionId
    ) external view returns (uint256[] memory) {
        uint256[] memory submisIds = new uint256[](5);
        if (_sessions.info.currentRound == 0) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                submisIds[i] = _trainersToSubmit1[trainerByIndex];
            }
        }
        if (_sessions.info.currentRound == 1) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                submisIds[i] = _trainersToSubmit2[trainerByIndex];
            }
        }
        if (_sessions.info.currentRound == 2) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                submisIds[i] = _trainersToSubmit3[trainerByIndex];
            }
        }
        return submisIds;
    }

    function submitAggregate(
        uint256 sessionId,
        uint256 updateId,
        uint256[] memory indexOfTrainerHasBadUpdateId
    ) external {
        _sessions.latestGlobalModelParamId = updateId;
        _sessions.info.status = RoundStatus.Testing;
    }

    function getDataDoTesting(
        uint256 sessionId,
        address sender_
    ) external view returns (uint256, uint256[] memory) {
        uint256 indexResp = 0;
        uint256[] memory submisIds = new uint256[](4);
        if (_sessions.info.currentRound == 0) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                if (trainerByIndex == sender_) {
                    continue;
                }
                submisIds[indexResp] = _trainersToSubmit1[trainerByIndex];
                indexResp += 1;
            }
        }
        if (_sessions.info.currentRound == 1) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                if (trainerByIndex == sender_) {
                    continue;
                }
                submisIds[indexResp] = _trainersToSubmit2[trainerByIndex];
                indexResp += 1;
            }
        }
        if (_sessions.info.currentRound == 2) {
            for (uint256 i = 0; i < 5; i++) {
                address trainerByIndex = _trainers[i];
                if (trainerByIndex == sender_) {
                    continue;
                }
                submisIds[indexResp] = _trainersToSubmit3[trainerByIndex];
                indexResp += 1;
            }
        }
        return (_sessions.latestGlobalModelParamId, submisIds);
    }

    function submitScores(uint256 sessionId, bool[] memory scores) external {
        if (_sessions.info.currentRound == 0) {
            _countScore1 += 1;
            if (_countScore1 == 5) {
                _sessions.info.status = RoundStatus.Training;
                _sessions.info.currentRound += 1;
            }
        }
        if (_sessions.info.currentRound == 1) {
            _countScore2 += 1;
            if (_countScore2 == 5) {
                _sessions.info.status = RoundStatus.Training;
                _sessions.info.currentRound += 1;
            }
        }
        if (_sessions.info.currentRound == 2) {
            _countScore3 += 1;
            if (_countScore3 == 5) {
                _sessions.info.status = RoundStatus.End;
            }
        }
    }

    function claimPerformanceReward(uint256 sessionId, uint256 round) external {
        payable(msg.sender).transfer(_sessions.info.performanceReward / 5);
    }
}

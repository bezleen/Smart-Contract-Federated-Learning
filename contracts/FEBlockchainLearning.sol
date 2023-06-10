// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Aggregator.sol";
import "./Trainer.sol";

contract FEBlockchainLearning is AccessControl {
    // this is admin, the ones who deploy this contract, we use this to recognize him when some call a function that only admin can call
    address payable admin;

    // AccessControl
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant CLIENT_ROLE = keccak256("CLIENT_ROLE");
    bytes32 public constant TRAINER_ROLE = keccak256("TRAINER_ROLE");
    bytes32 public constant AGGREGATOR_ROLE = keccak256("AGGREGATOR_ROLE");

    // Sessions
    enum RoundStatus {
        Ready,
        Training,
        Scoring,
        Aggregating,
        End
    }
    struct trainUpdate {
        address trainerAddress;
        uint256 updateId;
    }

    struct scoreObject {
        address candidateAddress;
        // trueValue = x.10^-5
        uint256 accuracy;
        uint256 loss;
        uint256 precision;
        uint256 recall;
        uint256 f1;
        // False Positive Rate (FPR)
        // uint256 fpr;
    }

    struct scoreUpdate {
        address scorerAddress;
        scoreObject[] scoreObj;
    }
    struct aggregateUpdate {
        address aggregatorAddress;
        uint256 updateId;
    }

    struct sessionDetail {
        uint256 sessionId;
        uint256 round;
        uint256 currentRound;
        uint256 globalModelId;
        uint256 latestGlobalModelParamId;
        RoundStatus status;
        address[] trainerAddresses;
        mapping(uint256 => aggregateUpdate) roundToAggregatorAddress;
        mapping(uint256 => scoreUpdate[]) roundToScoreUpdate;
        mapping(uint256 => trainUpdate[]) roundToUpdateObject;
    }

    // Management System
    mapping(uint256 => sessionDetail) sessionIdToSessionDetail;
    // Access Controll

    modifier onlyRole(bytes32 role) {
        require(hasRole(role, msg.sender) == true, "Required role");
        _;
    }

    constructor() {
        admin = payable(msg.sender);
        _setupRole(ADMIN_ROLE, admin);
    }

    // Utils
    function _isATrainerOfTheSession(
        address submiter,
        uint256 sessionId
    ) private view returns (bool) {
        address[] memory thisTrainerAddresses = sessionIdToSessionDetail[
            sessionId
        ].trainerAddresses;
        for (uint256 i = 0; i < thisTrainerAddresses.length; i++) {
            if (thisTrainerAddresses[i] == submiter) {
                return true;
            }
        }
        return false;
    }

    function _checkTrainerSubmitted(
        address submiter,
        uint256 sessionId
    ) private view returns (bool) {
        uint256 currentRound = sessionIdToSessionDetail[sessionId].currentRound;
        trainUpdate[] memory allUpdateThisRound = sessionIdToSessionDetail[
            sessionId
        ].roundToUpdateObject[currentRound];
        for (uint256 i = 0; i < allUpdateThisRound.length; i++) {
            if (
                allUpdateThisRound[i].trainerAddress == submiter &&
                allUpdateThisRound[i].updateId != 0
            ) {
                return true;
            }
        }
        return false;
    }

    function _checkAllTrainerSubmitted(
        uint256 sessionId
    ) private view returns (bool) {
        uint256 currentRound = sessionIdToSessionDetail[sessionId].currentRound;
        trainUpdate[] memory allUpdateThisRound = sessionIdToSessionDetail[
            sessionId
        ].roundToUpdateObject[currentRound];
        if (
            allUpdateThisRound.length ==
            sessionIdToSessionDetail[sessionId].trainerAddresses.length
        ) {
            return true;
        }
        return false;
    }

    function _checkScorerSubmitted(
        uint256 sessionId,
        address candidate
    ) private view returns (bool) {
        // TODO: handle logic here
    }

    // Management System

    function registerTrainer(
        address trainerAddress
    ) external onlyRole(ADMIN_ROLE) {
        // TODO: handle logic here
    }

    function initializeSession(
        uint256 sessionId,
        uint256 round,
        uint256 globalModelId,
        uint256 latestGlobalModelParamId,
        address[] memory trainerAddresses
    ) external onlyRole(ADMIN_ROLE) {
        sessionDetail storage sDetail = sessionIdToSessionDetail[sessionId];
        sDetail.sessionId = sessionId;
        sDetail.round = round;
        sDetail.currentRound = 0;
        sDetail.globalModelId = globalModelId;
        sDetail.latestGlobalModelParamId = latestGlobalModelParamId;
        sDetail.status = RoundStatus.Ready;
        sDetail.trainerAddresses = trainerAddresses;
    }

    // Session Implement
    function startRound(uint256 sessionId) external {
        RoundStatus currentStatus = sessionIdToSessionDetail[sessionId].status;
        require(
            currentStatus == RoundStatus.Ready,
            "Session is not ready to start"
        );
        sessionIdToSessionDetail[sessionId].currentRound++;
        sessionIdToSessionDetail[sessionId].status = RoundStatus.Training;
        // emit event
    }

    function submitUpdate(uint256 sessionId, uint256 update_id) external {
        require(
            sessionIdToSessionDetail[sessionId].status == RoundStatus.Training,
            "Cannot submit update when session is not in state training"
        );
        require(
            _isATrainerOfTheSession(msg.sender, sessionId),
            "You are not a trainer of this session"
        );
        require(
            _checkTrainerSubmitted(msg.sender, sessionId),
            "You submitted before"
        );
        trainUpdate memory newUpdate = trainUpdate(msg.sender, update_id);
        uint256 currentRound = sessionIdToSessionDetail[sessionId].currentRound;
        sessionIdToSessionDetail[sessionId]
            .roundToUpdateObject[currentRound]
            .push(newUpdate);
        if (_checkAllTrainerSubmitted(sessionId)) {
            _startScoring(sessionId);
        }
        // emit event
    }

    function _startScoring(uint256 sessionId) private {
        RoundStatus currentStatus = sessionIdToSessionDetail[sessionId].status;
        require(
            currentStatus == RoundStatus.Training,
            "Session is not ready to score"
        );
        sessionIdToSessionDetail[sessionId].status = RoundStatus.Scoring;
        // emit event
    }

    function submitScore(
        uint256 sessionId,
        uint256[] memory scores,
        address candidateAddress
    ) external {
        require(
            sessionIdToSessionDetail[sessionId].status == RoundStatus.Scoring,
            "Cannot submit update when session is not in state Scoring"
        );
        require(
            _isATrainerOfTheSession(msg.sender, sessionId),
            "You are not a trainer of this session"
        );
        require(
            _isATrainerOfTheSession(candidateAddress, sessionId),
            "This candidate is not a trainer of this session"
        );
        // FIXME check Scorer Submitted
        require(
            _checkTrainerSubmitted(msg.sender, sessionId),
            "You submitted before"
        );
        require(scores.length == 6, "Missing scores");
        uint256 currentRound = sessionIdToSessionDetail[sessionId].currentRound;
        scoreObject memory scoreObj = scoreObject(
            candidateAddress,
            scores[0],
            scores[1],
            scores[2],
            scores[3],
            scores[4]
            // scores[5]
        );
        scoreUpdate[] memory allScoreUpdate = sessionIdToSessionDetail[
            sessionId
        ].roundToScoreUpdate[currentRound];
        for (uint256 i = 0; i < allScoreUpdate.length; i++) {
            if (allScoreUpdate[i].scorerAddress == msg.sender) {
                sessionIdToSessionDetail[sessionId]
                    .roundToScoreUpdate[currentRound][i]
                    .scoreObj
                    .push(scoreObj);
                break;
            }
        }
        // TODO: check all submitted scores
    }

    function fetchRoundData(uint256 sessionId, uint256 round) external view {
        // TODO: handle logic here
    }

    function fetchSessionData(uint256 sessionId) external view {
        // TODO: handle logic here
    }

    function startAggregate(uint256 sessionId) external view {
        // TODO: handle logic here
    }

    function submitAggregate(uint256 sessionId) external view {
        // TODO: handle logic here
    }

    function endSession(uint256 sessionId) external view {
        // TODO: handle logic here
    }
}

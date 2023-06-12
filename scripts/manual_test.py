from utils.fe_blockchain_learning import FEBlockchainLearning

from scripts.helper import get_account
import pydash as py_
import time
import utils.constants as Consts
from bson.objectid import ObjectId


def full_flow():
    owner_account = get_account()
    fe_blockchain_learning = FEBlockchainLearning(Consts.FE_BLOCKCHAIN_LEARNING_CONTRACT_PATH)
    session_id = str(ObjectId())
    round = 3
    global_model_id = str(ObjectId())
    latest_global_model_param_id = str(ObjectId())
    trainers = [get_account(index=3), get_account(index=4), get_account(index=5)]
    trainer_addresses = list(map(lambda x: x.address, trainers))
    fe_blockchain_learning.initialize_session(owner_account, session_id, round, global_model_id, latest_global_model_param_id, trainer_addresses)
    time.sleep(5)
    current_status = fe_blockchain_learning.get_current_status(session_id)
    current_round = fe_blockchain_learning.get_current_round(session_id)
    print(f"Session: {session_id}, Current status: {current_status}, Current round: {current_round}")
    # start round
    fe_blockchain_learning.start_round(owner_account, session_id)
    time.sleep(5)
    current_status = fe_blockchain_learning.get_current_status(session_id)
    current_round = fe_blockchain_learning.get_current_round(session_id)
    print(f"Session: {session_id}, Current status: {current_status}, Current round: {current_round}")
    # submit train
    for _ in range(round):
        print(f"Training... ")
        time.sleep(5)
        for index, trainer in enumerate(trainers):
            update_id = str(ObjectId())
            print(f"{index +1}. Submit train, Trainer {trainer.address}, Train update id: {update_id}")
            fe_blockchain_learning.submit_update(trainer, session_id, update_id)
            time.sleep(5)

        current_status = fe_blockchain_learning.get_current_status(session_id)
        current_round = fe_blockchain_learning.get_current_round(session_id)
        print(f"Session: {session_id}, Current status: {current_status}, Current round: {current_round}")
        # submit score
        print(f"Scoring... ")
        time.sleep(5)
        for index, scorer in enumerate(trainers):
            print(f"{index +1}. Submit score, Scorer {scorer.address}")
            for candidate in trainers:
                if scorer.address == candidate.address:
                    continue
                # accuracy,loss,precision,recall,f1
                scores = [0.9, 0.8, 0.87, 0.69, 0.98]
                print(f"Candidate: {candidate.address}")
                fe_blockchain_learning.submit_score(scorer, session_id, scores, candidate.address)
                time.sleep(5)
        current_status = fe_blockchain_learning.get_current_status(session_id)
        current_round = fe_blockchain_learning.get_current_round(session_id)
        print(f"Session: {session_id}, Current status: {current_status}, Current round: {current_round}")
        # submit aggregate
        print(f"Aggregating... ")
        time.sleep(5)
        aggregator_address = fe_blockchain_learning.get_aggregator(session_id)
        aggregator = py_.find(trainers, lambda x: x.address == aggregator_address)
        aggregate_id = str(ObjectId())
        print(f"Submit aggregate, Session: {session_id}, aggregate_id: {aggregate_id}")
        fe_blockchain_learning.submit_aggregate(aggregator, session_id, aggregate_id)
        time.sleep(5)
        current_status = fe_blockchain_learning.get_current_status(session_id)
        current_round = fe_blockchain_learning.get_current_round(session_id)
        print(f"Session: {session_id}, Current status: {current_status}, Current round: {current_round}")
    return


def main():
    full_flow()

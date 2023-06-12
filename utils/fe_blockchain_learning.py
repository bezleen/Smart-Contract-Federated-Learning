import json
import pydash as py_
from brownie import Contract
from bson.objectid import ObjectId

STATUS_MAPPING = {
    0: "Ready",
    1: "Training",
    2: "Scoring",
    3: "Aggregating",
    4: "End"
}


class FEBlockchainLearning(object):

    def __init__(self, _path, proxy_path=None):
        self.contract = self.__import_from_json(_path, proxy_path=proxy_path)
        self.score_decimals = self.get_score_decimals()

    def __import_from_json(self, _path, proxy_path=None):
        with open(_path, "r") as f:
            data = json.load(f)
            self.address = py_.get(data, "address")
            name = py_.get(data, "name")
            abi = py_.get(data, "abi")
        if proxy_path:
            with open(proxy_path, "r") as f:
                data = json.load(f)
                self.address = py_.get(data, "address")
        contract = Contract.from_abi(name, self.address, abi)
        return contract

    def __call__(self):
        return self.contract

    def encode_id(self, object_id: str):
        # from str to int
        integer_id = int(str(object_id), 16)
        return integer_id

    def decode_id(self, integer_id: int):
        # from int to str
        object_id = hex(integer_id)[2:]
        return object_id

    def encode_score(self, score):
        # Note: from display_amount -> contract_amount
        encoded = int(score * (10**self.score_decimals))
        return encoded

    def decode_amount(self, score):
        # Note: from contract_amount -> display_amount
        decoded = int(score / (10**self.score_decimals))
        return decoded

    def initialize_session(self, executor: object, session_id: str, round: int, global_model_id: str, latest_global_model_param_id: str, trainer_addresses: list):
        session_id = self.encode_id(session_id)
        global_model_id = self.encode_id(global_model_id)
        latest_global_model_param_id = self.encode_id(latest_global_model_param_id)
        self.contract.initializeSession(session_id, round, global_model_id, latest_global_model_param_id, trainer_addresses, {"from": executor, "gas_limit": 1000000})
        return

    def start_round(self, executor: object, session_id: str):
        session_id = self.encode_id(session_id)
        self.contract.startRound(session_id, {"from": executor, "gas_limit": 1000000})
        return

    def submit_update(self, executor: object, session_id: str, update_id: str):
        session_id = self.encode_id(session_id)
        update_id = self.encode_id(update_id)
        self.contract.submitUpdate(session_id, update_id, {"from": executor, "gas_limit": 1000000})
        return

    def submit_score(self, executor: object, session_id: str, scores: list, candidate_address: str):
        session_id = self.encode_id(session_id)
        print(f"session_id: {session_id}")
        scores = list(map(lambda x: self.encode_score(x), scores))
        print(f"scores: {scores}")
        print(f"candidate_address: {candidate_address}")
        self.contract.submitScore(session_id, scores, candidate_address, {"from": executor, "gas_limit": 1000000})
        return

    def submit_aggregate(self, executor: object, session_id: str, update_id: str):
        session_id = self.encode_id(session_id)
        update_id = self.encode_id(update_id)
        self.contract.submitAggregate(session_id, update_id, {"from": executor, "gas_limit": 1000000})

    def get_current_status(self, session_id: str):
        session_id = self.encode_id(session_id)
        current_status = self.contract.getCurrentStatus(session_id)
        return STATUS_MAPPING[int(current_status)]

    def get_current_round(self, session_id: str):
        session_id = self.encode_id(session_id)
        current_round = self.contract.getCurrentRound(session_id)
        return current_round

    def get_score_decimals(self):
        score_decimals = self.contract.scoreDecimals()
        return score_decimals

    def get_aggregator(self, session_id: str):
        session_id = self.encode_id(session_id)
        aggregator_addr = self.contract.getAggregator(session_id)
        return aggregator_addr

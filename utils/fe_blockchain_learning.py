import json
import pydash as py_
from brownie import Contract
from bson.objectid import ObjectId


class FEBlockchainLearning(object):

    def __init__(self, _path, proxy_path=None):
        self.contract = self.__import_from_json(_path, proxy_path=proxy_path)

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
        self.contract.submitScore(session_id, scores, candidate_address, {"from": executor, "gas_limit": 1000000})
        return

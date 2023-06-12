from brownie import Contract
from web3 import Web3
import json
import pydash as py_


class TrainerManagement(object):
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

    def is_allow(self, candidate: str):
        return self.contract.isAllowed(candidate)

    def is_block(self, candidate: str):
        return self.contract.isBlocked(candidate)

    def add_to_allowlist(self, executor: object, candidate: str):
        self.contract.addToAllowlist(candidate, {"from": executor, "gas_limit": 1000000})
        return

    def remove_from_allowlist(self, executor: object, candidate: str):
        self.contract.removeFromAllowlist(candidate, {"from": executor, "gas_limit": 1000000})
        return

    def add_to_blocklist(self, executor: object, candidate: str):
        self.contract.addToBlocklist(candidate, {"from": executor, "gas_limit": 1000000})
        return

    def remove_from_blocklist(self, executor: object, candidate: str):
        self.contract.removeFromBlocklist(candidate, {"from": executor, "gas_limit": 1000000})
        return

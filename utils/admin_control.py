from brownie import Contract
from web3 import Web3
import json
import pydash as py_


class AdminControl(object):
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

    def set_minter(self, executor: object, account: str):
        self.contract.setMinter(account, {"from": executor, "gas_limit": 1000000})

    def set_burner(self, executor: object, account: str):
        self.contract.setBurner(account, {"from": executor, "gas_limit": 1000000})

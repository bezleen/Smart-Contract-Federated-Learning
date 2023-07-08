from brownie import FEBlockchainLearning
import utils.constants as Consts
from scripts.helper import get_account
from scripts.manual_test import allow_trainer
import json
import pydash as py_
from utils.admin_control import AdminControl


def deploy_fe_blockchain_learning(export_path=Consts.FE_BLOCKCHAIN_LEARNING_CONTRACT_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()

    contract = FEBlockchainLearning.deploy({"from": owner_account})
    print(f"Contract FEBlockchainLearning address: {contract.address}")
    abi_path = "build/contracts/FEBlockchainLearning.json"
    with open(abi_path, "r") as f:
        data = json.load(f)
        abi = py_.get(data, "abi")
    data = {
        "address": contract.address,
        "abi": abi,
        "name": "FEBlockchainLearning"
    }
    with open(export_path, "w") as f:
        f.write(json.dumps(data))


def deploy_staging():
    # Deploy FEBlockchainLearning
    deploy_fe_blockchain_learning()
    return


def main():
    deploy_staging()

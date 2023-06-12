from brownie import FEBlockchainLearning, TrainerManagement, AdminControl
import utils.constants as Consts
from scripts.helper import get_account
from scripts.manual_test import allow_trainer
import json
import pydash as py_


def deploy_fe_blockchain_learing(export_path=Consts.FE_BLOCKCHAIN_LEARNING_CONTRACT_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()

    # get trainer management address
    with open(Consts.TRAINER_MANAGEMENT_PATH, "r") as f:
        data = json.load(f)
        trainer_management_address = py_.get(data, "address")
    # get admin control address
    with open(Consts.ADMIN_CONTROL_PATH, "r") as f:
        data = json.load(f)
        admin_control_address = py_.get(data, "address")

    contract = FEBlockchainLearning.deploy(trainer_management_address, admin_control_address, {"from": owner_account})
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


def deploy_trainer_management(export_path=Consts.TRAINER_MANAGEMENT_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()

    # get admin control address
    with open(Consts.ADMIN_CONTROL_PATH, "r") as f:
        data = json.load(f)
        admin_control_address = py_.get(data, "address")

    contract = TrainerManagement.deploy(admin_control_address, {"from": owner_account})
    print(f"Contract TrainerManagement address: {contract.address}")
    abi_path = "build/contracts/TrainerManagement.json"
    with open(abi_path, "r") as f:
        data = json.load(f)
        abi = py_.get(data, "abi")
    data = {
        "address": contract.address,
        "abi": abi,
        "name": "TrainerManagement"
    }
    with open(export_path, "w") as f:
        f.write(json.dumps(data))


def deploy_admin_control(export_path=Consts.ADMIN_CONTROL_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()
    contract = AdminControl.deploy({"from": owner_account})
    print(f"Contract AdminControl address: {contract.address}")
    abi_path = "build/contracts/AdminControl.json"
    with open(abi_path, "r") as f:
        data = json.load(f)
        abi = py_.get(data, "abi")
    data = {
        "address": contract.address,
        "abi": abi,
        "name": "AdminControl"
    }
    with open(export_path, "w") as f:
        f.write(json.dumps(data))


def main():
    deploy_admin_control()
    deploy_trainer_management()
    deploy_fe_blockchain_learing()
    allow_trainer()

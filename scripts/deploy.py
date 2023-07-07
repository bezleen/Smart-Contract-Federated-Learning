from brownie import AdminControl, TrainerManagement, FEToken, FEBlockchainLearning, TimeLock, PerformanceRewardDistribution
import utils.constants as Consts
from scripts.helper import get_account
from scripts.manual_test import allow_trainer
import json
import pydash as py_
from utils.admin_control import AdminControl


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


def deploy_time_lock(export_path=Consts.TIME_LOCK_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()

    # get admin control address
    with open(Consts.ADMIN_CONTROL_PATH, "r") as f:
        data = json.load(f)
        admin_control_address = py_.get(data, "address")

    contract = TimeLock.deploy(admin_control_address, {"from": owner_account})
    print(f"Contract TimeLock address: {contract.address}")
    abi_path = "build/contracts/TimeLock.json"
    with open(abi_path, "r") as f:
        data = json.load(f)
        abi = py_.get(data, "abi")
    data = {
        "address": contract.address,
        "abi": abi,
        "name": "TimeLock"
    }
    with open(export_path, "w") as f:
        f.write(json.dumps(data))


def deploy_fe_token(export_path=Consts.FE_TOKEN_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()

    # get admin control address
    with open(Consts.ADMIN_CONTROL_PATH, "r") as f:
        data = json.load(f)
        admin_control_address = py_.get(data, "address")

    contract = FEToken.deploy(admin_control_address, "FeLearn", "FET", {"from": owner_account})
    print(f"Contract FEToken address: {contract.address}")
    abi_path = "build/contracts/FEToken.json"
    with open(abi_path, "r") as f:
        data = json.load(f)
        abi = py_.get(data, "abi")
    data = {
        "address": contract.address,
        "abi": abi,
        "name": "FEToken"
    }
    with open(export_path, "w") as f:
        f.write(json.dumps(data))


def deploy_frd(export_path=Consts.PRD_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()

    # get admin control address
    with open(Consts.ADMIN_CONTROL_PATH, "r") as f:
        data = json.load(f)
        admin_control_address = py_.get(data, "address")

    # get fet address
    with open(Consts.FE_TOKEN_PATH, "r") as f:
        data = json.load(f)
        fet_address = py_.get(data, "address")

    contract = PerformanceRewardDistribution.deploy(admin_control_address, fet_address, {"from": owner_account})
    print(f"Contract PerformanceRewardDistribution address: {contract.address}")
    abi_path = "build/contracts/PerformanceRewardDistribution.json"
    with open(abi_path, "r") as f:
        data = json.load(f)
        abi = py_.get(data, "abi")
    data = {
        "address": contract.address,
        "abi": abi,
        "name": "PerformanceRewardDistribution"
    }
    with open(export_path, "w") as f:
        f.write(json.dumps(data))


def deploy_fe_blockchain_learing(export_path=Consts.FE_BLOCKCHAIN_LEARNING_CONTRACT_PATH, owner_account=None):
    if not owner_account:
        owner_account = get_account()

    # get admin control address
    with open(Consts.ADMIN_CONTROL_PATH, "r") as f:
        data = json.load(f)
        admin_control_address = py_.get(data, "address")

    # get trainer management address
    with open(Consts.TRAINER_MANAGEMENT_PATH, "r") as f:
        data = json.load(f)
        trainer_management_address = py_.get(data, "address")

    # get time lock address
    with open(Consts.TIME_LOCK_PATH, "r") as f:
        data = json.load(f)
        time_lock_address = py_.get(data, "address")

    # get prd address
    with open(Consts.PRD_PATH, "r") as f:
        data = json.load(f)
        prd_address = py_.get(data, "address")

    # get fet address
    with open(Consts.FE_TOKEN_PATH, "r") as f:
        data = json.load(f)
        fet_address = py_.get(data, "address")

    secret_value_random = 1

    contract = FEBlockchainLearning.deploy(admin_control_address, trainer_management_address, time_lock_address, prd_address, fet_address, secret_value_random, {"from": owner_account})
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


def set_minter():
    owner_account = get_account()
    # get FEBlockchainLearning address
    with open(Consts.FE_BLOCKCHAIN_LEARNING_CONTRACT_PATH, "r") as f:
        data = json.load(f)
        fl_address = py_.get(data, "address")
    contract = AdminControl(Consts.ADMIN_CONTROL_PATH)
    contract.set_minter(owner_account, fl_address)


def set_burner():
    owner_account = get_account()
    # get FEBlockchainLearning address
    with open(Consts.FE_BLOCKCHAIN_LEARNING_CONTRACT_PATH, "r") as f:
        data = json.load(f)
        fl_address = py_.get(data, "address")
    contract = AdminControl(Consts.ADMIN_CONTROL_PATH)
    contract.set_burner(owner_account, fl_address)


def deploy_staging():
    # Deploy AdminControl
    deploy_admin_control()
    # Deploy TrainerManager
    deploy_trainer_management()
    # Deploy Timelock
    deploy_time_lock()
    # Deploy FEToken
    deploy_fe_token()
    # Deploy PerformanceRewardDistribution
    deploy_frd()
    # Deploy FEBlockchainLearning
    deploy_fe_blockchain_learing()
    # setMinter
    set_minter()
    # setBurn
    set_burner()
    return

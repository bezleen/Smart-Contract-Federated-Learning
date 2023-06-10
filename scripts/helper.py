from brownie import accounts, config, network, Contract
from web3 import Web3


def get_account_by_key():
    return accounts.add(config['wallets']['from_key'])


def get_account_ganache(index=0):
    return accounts[index]


def get_account(index=0):
    if network.show_active() in ["development", "ganache-local"]:
        return get_account_ganache(index=index)
    return get_account_by_key()


def show_account():
    environment = network.show_active()
    print(f"Current network: {environment}")
    account_obj = get_account()
    account_address = account_obj.address
    print(f"Address: {account_address}")
    account_balance = Web3.fromWei(account_obj.balance(), "ether")
    print(f"Balance: {round(account_balance,5)} eth")


def import_contract(contract_name, contract_address, contract_abi):
    contract_obj = Contract.from_abi(contract_name, contract_address, contract_abi)
    return contract_obj

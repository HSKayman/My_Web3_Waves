from eth_account import Account
import json 
import secrets
from web3 import Web3, HTTPProvider

def load_config():
    with open('config2.json') as f:
        return json.load(f)

WalletPriv=[]
WalletAddress=[]
for key in range(300):
    private_key = secrets.token_hex(32)
    acct = Account.from_key(private_key)
    WalletPriv.append(private_key)
    WalletAddress.append(acct.address)


config=load_config()
web3 = Web3(HTTPProvider(config['bscNode']))
with open('Wallet.bin','w') as f:
    json.dump({'WalletPriv':WalletPriv,'WalletAddress':WalletAddress},f)
    
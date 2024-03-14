# -*- coding: utf-8 -*-
"""
Created on Sat Apr  9 03:43:43 2022

@author: suca
"""
import json 
from web3 import Web3

def load_config():
    with open('config.json') as f:
        return json.load(f)

config= load_config()   

web3 = Web3(Web3.HTTPProvider(config['bscNode']))
print("Connect:",web3.isConnected())
walletA = config['WalletMain']

wallets=[]    
with open('wallets.txt') as f:
    for key in f:
        key = key.strip()
        wallets.append(key)


balance = web3.eth.get_balance(walletA)   
humanReadable = web3.fromWei(balance, 'ether')
print(humanReadable)
nonce = web3.eth.getTransactionCount(walletA)

for i in wallets:
    tx = {
        'nonce': nonce,
        'to': i,
        'value': web3.toWei(int(balance/(len(wallets)+1)),'wei'),
        'gas': 3000000,
        'gasPrice': web3.toWei('15', 'gwei')
    }
    
    signed_tx = web3.eth.account.signTransaction(tx, config["WalletMainPK"] )
    tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
    trans = web3.toHex(tx_hash)
    nonce+=1
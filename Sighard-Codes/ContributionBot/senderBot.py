import json 
from web3 import Web3

def load_config():
    with open('config.json') as f:
        return json.load(f)
    
def multiSender():
    config= load_config()   
    
    web3 = Web3(Web3.HTTPProvider(config['bscNode']))
    print("Connect:",web3.isConnected())
    walletA = config['WalletMain']
    
    wallets=[]    
    with open('addresses.txt') as f:
        for key in f:
            key = key.strip()
            wallets.append(key)
    
    
    balance = web3.eth.get_balance(walletA)   
    humanReadable = web3.fromWei(balance, 'ether')
    print(humanReadable)
    nonce = web3.eth.getTransactionCount(walletA)
    transactions=[]
    for i in wallets:
        tx = {
            'nonce': nonce,
            'to': i,
            'value': web3.toWei(0.01,'ether'),
            'gas': 3000000,
            'gasPrice': web3.toWei('12', 'gwei')
        }
        
        signed_tx = web3.eth.account.signTransaction(tx, config["WalletMainPK"] )
        tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
        trans = web3.toHex(tx_hash)
        transactions.append(trans)
        nonce+=1
        
    f = open("transactions.txt", 'w')
    for trs in transactions:
       f.write(str(trs)+'\n')
    f.close()
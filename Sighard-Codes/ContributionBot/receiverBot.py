import json 
from web3 import Web3

def load_config():
    with open('config.json') as f:
        return json.load(f)
    
def multiGatherer():
    config= load_config()   
    
    web3 = Web3(Web3.HTTPProvider(config['bscNode']))
    print("Connect:",web3.isConnected())
    walletA = config['WalletMain']
    
    keys=[]    
    with open('priv_keys.txt') as f:
        for key in f:
            key = key.strip()
            keys.append(key)
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
    for (key,wallet) in zip(keys,wallets):
        print(wallet)
        print(web3.eth.getBalance(wallet))
        print(key)
        tx = {
            'nonce': 0,
            'to': config["WalletMain"],
            'value': web3.eth.getBalance(wallet) - (web3.eth.gasPrice * 21000),
            'gas': 21000,
            'gasPrice': web3.eth.gasPrice
        }
        
        signed_tx = web3.eth.account.signTransaction(tx, key)
        tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
        trans = web3.toHex(tx_hash)
        transactions.append(trans)
        nonce+=1
        
    f = open("transactions_gather.txt", 'w')
    for trs in transactions:
       f.write(str(trs)+'\n')
    f.close()
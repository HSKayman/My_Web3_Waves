from eth_account import Account
import json 
import secrets


WalletPriv=[]
WalletAddress=[]
for key in range(300):
    private_key = secrets.token_hex(32)
    acct = Account.from_key(private_key)
    WalletPriv.append(private_key)
    WalletAddress.append(acct.address)


with open('Wallet.bin','w') as f:
    json.dump({'WalletPriv':WalletPriv,'WalletAddress':WalletAddress},f)
    
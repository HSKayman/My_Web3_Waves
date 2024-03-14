import json
from requests import get as getRequest
from web3 import Web3,HTTPProvider
from datetime import datetime
import os
from dotenv import load_dotenv

with open('Addlog.json') as f:
    InformationList=json.load(f) 

load_dotenv()



def timestampToHumanReadble(timestamp):
    date_time = datetime.fromtimestamp(timestamp)
    return date_time.strftime("%H:%M:%S %d/%m/%Y")

class Token():
    def __init__(self,tokenAddress,chainName,saleAddressOrDex) -> None:
        self.tokenAddress=tokenAddress
        self.dexName=saleAddressOrDex
        self.chainName=chainName
        self.sellTrack=True
        self.information=InformationList[self.chainName]
        self.wethAddress= self.information["CoinAddress"]
        self.weth_symbol= self.information["Symbol"]

        self.provider = HTTPProvider(self.information["Provider"]+os.getenv(chainName+"APIKEY"))
        self.web3 = Web3(self.provider)

        #Factory
        self.factory_contract = self.web3.eth.contract(address= self.information["SupportedRouter"][self.dexName]["FactoryAddress"], abi=json.load(open('factory_abi.json')))

        #Token
        self.tokenContract = self.web3.eth.contract(address=self.tokenAddress, abi=json.load(open('token_abi.json')))
        self.symbol = self.tokenContract.functions.symbol().call()
        self.decimal = self.tokenContract.functions.decimals().call()

        #Pair
        wbnbAddress=Web3.toChecksumAddress(str(self.wethAddress))
        tokenAddress= Web3.toChecksumAddress(str(self.tokenAddress))
 
        self.pairAddress = self.factory_contract.functions.getPair(wbnbAddress,tokenAddress).call()
        self.pairContract = self.web3.eth.contract(address=str(self.pairAddress), abi=json.load(open('pair_abi.json')))
        self.fromBlock = self.web3.eth.blockNumber
        self.position = (self.wethAddress == self.pairContract.functions.token0().call())
    
    def processTx(self):
        try:
            price = getRequest(self.pairAddress).json()['price']
            txs = getRequest(self.getLink()).json()['result']
        except Exception as e:
            print("Error", e)
          
        
        transactions=[]
        for tx in txs:
            transaction = {"amount0In": 0, 
                            "amount1In":0,
                            "amount0Out": 0,
                            "amount1Out": 0,
                            "txHash": 0,
                            "timestamp": 0,
                            "address": 0,
                            "process": (),
                            "token_price": 0,
                            "token_amount": 0,
                            "wbnb_amount": 0
                            }
            transaction["amount0In"]=int(tx["data"][2:66],16)
            transaction["amount1In"]=int(tx["data"][66:130],16)
            transaction["amount0Out"]=int(tx["data"][130:194],16)
            transaction["amount1Out"]=int(tx["data"][194:258],16)
            transaction["process"]=self.isSell(transaction["amount0In"],transaction["amount1In"],transaction["amount0Out"],transaction["amount1Out"])
            transaction["txHash"]=tx["transactionHash"]
            transaction["timestamp"]= int(tx["timeStamp"][2:],16)
            transaction["address"]="0x"+tx["topics"][-1][-40:]

            transaction["wbnb_price"]=float(price)
            transaction["token_price"]=self.getPrice()*float(price)
            transaction["wbnb_price_all"]= transaction["process"][2]*float(price)
            transaction["token_price_all"]= transaction["process"][1]* transaction["token_price"]
            transactions.append(transaction)
        return transactions

    def getLink(self): 
        link = self.information["getTxUrl"][0]+self.fromBlock + self.information["getTxUrl"][1]+ self.pairAddress +self.pairAddress+self.information["getTxUrl"][2]+os.getenv(self.chainName+"APIKEY")
        return link

    def getTexts(self,Txs):
        transactions = self.processTx(Txs)
        textList=[]
        if transactions:
            transactions = sorted(transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                if (self.sellTrack and transaction['process'][0]== 0) or (not self.sellTrack and transaction['process'][0]==1):
                    text = self.getText(transaction["address"],transaction["process"][1],transaction["process"][2],transaction["wbnb_price_all"],transaction["token_price"],transaction["timestamp"],transaction["txHash"])
                    textList.append([text,transaction["timestamp"]])
        return textList

    def getText(self, address,token_amount, wbnb_amount, usd_amount, token_price,timestamp,txHash):
        token_amount=round(token_amount,4)
        wbnb_amount=round(wbnb_amount,4)
        usd_amount=round(usd_amount,4)
        token_price=round(token_price,4)

        text = "\n 🟢🟢🟢🟢🟢🟢<b>BUY</b>🟢🟢🟢🟢🟢🟢🟢" #DONTFORGET
        text += "\n <b><a href= 'https://{}.com/address/{}'>👤 Buyer Position</a> New </b>".format(self.chainName,address)
        text += "\n <b>🤑 Got:</b> {} {} \n <b>💵 Spent:</b> {} {} (${}) \n <b>💲 Price/Token:</b> ${}".format(token_amount, self.symbol, wbnb_amount, self.wbnb_symbol, usd_amount, token_price)
        text += f"\n <b>🚨DEX:</b> {self.dexName}"
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        link= ""
        for index,i in enumerate(self.dexLink):
            link+=i+ str(self.creating[index])
        text += f"\n<a href='https://{self.chainName}.com/tx/{txHash}'>👁‍🗨 TX</a> | <a href= 'https://charts.bogged.finance/?c=bsc&t={self.tokenAddress}'>📊 Chart</a> | <a href= '{link}'>💱 Buy</a>"
        return text

    def isSell(self,amount0In, amount1In, amount0Out, amount1Out):
        if self.position:
            if amount1In > 0 and amount0Out > 0 and amount0In==0 and amount1Out==0:
                return (0,float(amount1In)/10**self.decimal,float(amount0Out)/10**18) #Buy
            elif amount1In ==0 and amount0Out == 0 and amount0In>0 and amount1Out>0:
                return (1,float(amount1Out)/10**self.decimal,float(amount0In)/10**18) #Sell
            else:
                return (2,0,0) #DontKnow
        else:
            if amount1In > 0 and amount0Out > 0 and amount0In==0 and amount1Out==0:
                return (1,float(amount0Out)/10**self.decimal,float(amount1In)/10**18) #Sell
            elif amount1In ==0 and amount0Out == 0 and amount0In>0 and amount1Out>0:
                return (0,float(amount0In)/10**self.decimal,float(amount1Out)/10**18) #Buy
            else:
                return (2,0,0) #DontKnow

    def getPrice(self):
        reserves = self.pairContract.functions.getReserves().call()
        if self.position:
            return (float(reserves[0])/10**self.decimal)/(float(reserves[1])/10**18)
        else:
            return (float(reserves[1])/10**18)/(float(reserves[1])/10**self.decimal)

    def getInfo(self):#DONTFORGET
        text = f"<b>Token Addres: {self.tokenAddress}</b>\n<b>Type: Token\nNetwork: {self.chainName}</b>"
        return text

class PreSale:
    def __init__(self, WebThree : Web3,tokenAddress,preSaleAddress, chainID, chainName,chainSymbol) -> None:
        self.chainID = chainID
        self.chainName = chainName
        self.chainSymbol= chainSymbol
        #Token
        self.preSaleAddress = preSaleAddress
        self.tokenAddress = tokenAddress
        self.tokenContract = WebThree.eth.contract(address=self.tokenAddress, abi=json.load(open('token_abi.json')))
        self.symbol = self.tokenContract.functions.symbol().call()
        self.decimal = self.tokenContract.functions.decimals().call()

    def processTx(self,txs,price):
        transactions=[]
        for tx in txs:
            transaction = {"txHash": 0,
                            "timestamp": 0,
                            "address": 0,
                            "wbnb_amount": 0,
                            "usd_amount": 0
                            }

            transaction["wbnb_amount"]=int(tx['data'][66:130],16)/10**18
            transaction["txHash"]=tx["transactionHash"]
            transaction["timestamp"]=int(tx["timeStamp"],16)
            transaction["address"]="0x"+tx["topics"][-1][-40:]
            transaction["wbnb_price"]=float(price)
            transaction["usd_amount"]= transaction["wbnb_amount"]*float(price)
            transactions.append(transaction)
        return transactions

    def getTopic(self):
        return "0x3868d5f103dc574f5c24ec0eccd553c21b9f0cb53b10b7b4028f5062867148bf"

    def getAddress(self):
        return  self.preSaleAddress

    def getTexts(self,Txs,price):
        transactions = self.processTx(Txs,price)
        textList=[]

        if transactions:
            transactions = sorted(transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                
                text = self.getText(transaction["address"],transaction["wbnb_amount"],transaction["usd_amount"],transaction["timestamp"],transaction["txHash"])
                textList.append([text,transaction["timestamp"]])
        return textList

    def getText(self, address, wbnb_amount, usd_amount,timestamp,txHash):
        wbnb_amount=round(wbnb_amount,4)
        usd_amount=round(usd_amount,4)

        text = "\n 🟢🟢🟢🟢<b>CONTRIBUTE</b>🟢🟢🟢🟢🟢" #DONTFORGET
        text += "\n <b><a href= 'https://{}.com/address/{}'>👤 Buyer Position</a> New </b>".format( self.chainName,address)
        # text += "\n <b>🤑 Got:</b> A lot Of {} \n <b>💵 Spent:</b> {} {} (${})".format( self.symbol, wbnb_amount,self.wbnb_symbol, usd_amount)
        text += "\n <b>🤑 Presale:</b>  {} \n <b>💵 Spent:</b> {} {} (${})".format( self.symbol, wbnb_amount,self.chainSymbol, usd_amount)
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        text += f"\n<a href='https://{self.chainName}.com/tx/{txHash}'>👁‍🗨 TX</a>"
        return text
    
    def getInfo(self):#DONTFORGET
        text = f"<b>Token Addres: {self.tokenAddress}</b>\n<b>Type: PreSale\nNetwork: {self.chainName}</b>"
        return text
        
class FairLaunch:
    def __init__(self, WebThree : Web3, tokenAddress,fairLaunchAddress, chainID, chainName,chainSymbol) -> None:
        self.chainID = chainID
        self.chainName = chainName
        self.chainSymbol = chainSymbol
        self.fairLaunchAddress=fairLaunchAddress
        #Token
        self.tokenAddress = tokenAddress
        print(self.tokenAddress)
        self.tokenContract = WebThree.eth.contract(address=self.tokenAddress, abi=json.load(open('token_abi.json')))
        self.symbol = self.tokenContract.functions.symbol().call()
        self.decimal = self.tokenContract.functions.decimals().call()
        

    def processTx(self,txs,price):
        transactions=[]
        for tx in txs:
            transaction = {"txHash": 0,
                            "timestamp": 0,
                            "address": 0,
                            "wbnb_amount": 0,
                            "usd_amount": 0
                            }

            transaction["wbnb_amount"]=int(tx['data'][66:130],16)/10**18
            transaction["txHash"]=tx["transactionHash"]
            transaction["timestamp"]=int(tx["timeStamp"],16)
            transaction["address"]="0x"+tx["topics"][-1][-40:]
            transaction["wbnb_price"]=float(price)
            transaction["usd_amount"]= transaction["wbnb_amount"]*float(price)
            transactions.append(transaction)
        return transactions

    def getTopic(self):
        return "0x76b049c6a58fbcb3b1b5c347116d3f7bb8ee99c66d0a424ef58b5539acde2e25"

    def getAddress(self):
        return  self.fairLaunchAddress

    def getTexts(self,Txs,price):
        transactions = self.processTx(Txs,price)
        textList=[]

        if transactions:
            transactions = sorted(transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                
                text = self.getText(transaction["address"],transaction["wbnb_amount"],transaction["usd_amount"],transaction["timestamp"],transaction["txHash"])
                textList.append([text,transaction["timestamp"]])
        return textList

    def getText(self, address, wbnb_amount, usd_amount,timestamp,txHash):
        wbnb_amount=round(wbnb_amount,4)
        usd_amount=round(usd_amount,4)
        text = "\n 🟢🟢🟢🟢<b>CONTRIBUTE</b>🟢🟢🟢🟢🟢" #DONTFORGET
        text += "\n <b><a href= 'https://{}.com/address/{}'>👤 Buyer Position</a> New </b>".format( self.chainName,address)
        # text += "\n <b>🤑 Got:</b> A lot Of {} \n <b>💵 Spent:</b> {} {} (${})".format( self.symbol, wbnb_amount,self.chainSymbol, usd_amount)
        text += "\n <b>FairLaunch:</b> {} \n <b>💵 Spent:</b> {} {} (${})".format( self.symbol, wbnb_amount,self.chainSymbol, usd_amount)
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        text += f"\n<a href='https://{self.chainName}.com/tx/{txHash}'>👁‍🗨 TX</a>"
        return text

    def getInfo(self):#DONTFORGET
        text = f"<b>Token Addres: {self.tokenAddress}</b>\n<b>Type: Fairlaunch\nNetwork: {self.chainName}</b>"
        return text
        
class PrivateSale:
    def __init__(self,WebThree : Web3,privateSaleAddress, chainID, chainName,chainSymbol) -> None:
        self.chainID = chainID
        self.chainName = chainName
        self.chainSymbol= chainSymbol
        self.privateSaleAddress=privateSaleAddress
       

    def processTx(self,txs,price):
        transactions=[]
        for tx in txs:
            transaction = {"txHash": 0,
                            "timestamp": 0,
                            "address": 0,
                            "wbnb_amount": 0,
                            "usd_amount": 0
                            }

            transaction["wbnb_amount"]=int(tx['data'][2:66],16)/10**18
            transaction["txHash"]=tx["transactionHash"]
            transaction["timestamp"]=int(tx["timeStamp"],16)
            transaction["address"]="0x"+tx["topics"][-1][-40:]
            transaction["wbnb_price"]=float(price)
            transaction["usd_amount"]= transaction["wbnb_amount"]*float(price)
            transactions.append(transaction)
        return transactions

    def getTopic(self):
        return "0x5590f179a891ab4bf7fcf125af1287b0defeb5542066f2f2ab95366810dcdb10"

    def getAddress(self):
        return  self.privateSaleAddress
        
    def getTexts(self,Txs,price):
        transactions = self.processTx(Txs,price)
        textList=[]

        if transactions:
            transactions = sorted(transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                
                text = self.getText(transaction["address"],transaction["wbnb_amount"],transaction["usd_amount"],transaction["timestamp"],transaction["txHash"])
                textList.append([text,transaction["timestamp"]])
        return textList

    def getText(self, address, wbnb_amount, usd_amount,timestamp,txHash):
        wbnb_amount=round(wbnb_amount,4)
        usd_amount=round(usd_amount,4)

        text = "\n 🟢🟢🟢🟢<b>CONTRIBUTE</b>🟢🟢🟢🟢🟢" #DONTFORGET
        text += "\n <b><a href= 'https://{}.com/address/{}'>👤 Buyer Position</a> New </b>".format( self.chainName,address)
        # text += "\n <b>Spent:</b> {} {} (${})".format( wbnb_amount,self.chainSymbol, usd_amount)
        text += "\n <b>🤑 PrivateSale:</b>\n <b>💵 Spent:</b> {} {} (${})".format( wbnb_amount,self.wbnb_symbol, usd_amount)
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        text += f"\n<a href='https://{self.chainName}.com/tx/{txHash}'>👁‍🗨 TX</a>"
        return text

    def getInfo(self):#DONTFORGET
        text = f"<b>Token Addres: {self.privateSaleAddress}</b>\n<b>Type: PrivateSale\nNetwork: {self.chainName}</b>"
        return text

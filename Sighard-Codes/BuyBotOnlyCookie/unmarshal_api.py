import json
from requests import get as getRequest
from web3 import Web3
from datetime import datetime
import random

class AddManager():
    def __init__(self) -> None:
        self.NormalAdds = []
        self.ButtonAdds = []
        self.readAdds()
        self.checkAdds()
        print(self.NormalAdds,self.ButtonAdds)

    def readAdds(self):
        try:
            with open('Addlog.bin') as f:
                printedList=json.load(f)   
        except:
            print("Couldn't Find Addlog.bin")
            printedList = {'NormalAdds':[],'ButtonAdds':[]}
        self.NormalAdds = printedList['NormalAdds']
        self.ButtonAdds = printedList['ButtonAdds']

    def writeAdds(self):
        with open('Addlog.bin','w') as f:
            json.dump({'NormalAdds':self.NormalAdds,'ButtonAdds':self.ButtonAdds},f)

    def checkAdds(self):
        current = int(datetime.timestamp(datetime.now()))
        
        for add in self.NormalAdds:
            if int(add[3]) +  int(add[2]) < current:   
                self.NormalAdds.remove(add)

        for add in self.ButtonAdds:
            if  int(add[3]) + int(add[2]) < current:   
                self.ButtonAdds.remove(add)
        self.writeAdds()
        self.readAdds()
    
    def getRandomAdds(self):
        self.checkAdds()
        Adds=[[f"\n\n <b>🚀 Ad's:</b> <b>Ads your project📞</b>",None,None,None],['Advertise your project here 📞', "https://t.me/CrypTechKing",None,None]]
        
        if len(self.NormalAdds) > 0:
            AnAdds = self.NormalAdds[random.randint(0,len(self.NormalAdds)-1)]
            Adds[0][0] = f"\n\n <b>🚀 Reklam:</b> '<a href='{AnAdds[1]}'><b>{AnAdds[0]}</b></a>'"

        if len(self.ButtonAdds) > 0:
            Adds[1] = self.ButtonAdds[random.randint(0,len(self.ButtonAdds)-1)]
        
        return Adds

    def addNormalAdd(self,text,link,time=24):
        self.NormalAdds.append([text.strip(),link.replace(' ',''),int(datetime.timestamp(datetime.now())),time*60*60])
        self.writeAdds()
    
    def AddButtonAdd(self,text,link,time=24):
        self.ButtonAdds.append([text.strip(),link.replace(' ',''),int(datetime.timestamp(datetime.now())),time*60*60])
        self.writeAdds()

class GetBuy():
    def __init__(self, pancakeswap_address, contract, api_key) -> None:
        self.pancakeswap_address = pancakeswap_address
        self.contract = contract
        self.api_key=api_key
        self.url = f"https://api.unmarshal.com/v2/bsc/address/{self.pancakeswap_address}/transactions?page=0&pageSize=10&contract={contract}&auth_key={api_key}"
        self.last_check = int(datetime.timestamp(datetime.now()))
        print(pancakeswap_address,contract,api_key)
        

    def getTransactions(self):
        resp = getRequest(self.url)
        try:
            resp = resp.json()
            last_transactions = resp['transactions']
            if last_transactions:
                return last_transactions
            else:
                return None
        except Exception as e:
            print(e)
        return None

    def timestampToHumanReadble(self,timestamp):
        date_time = datetime.fromtimestamp(timestamp)
        return date_time.strftime("%H:%M:%S %d/%m/%Y")

    def getAmounts(self,transaction):
        sent = transaction['sent']
        token_amounts = 0
        usd_amounts = 0.0
        for element in sent:
            token_amounts += int(element['value'])
            usd_amounts += float(element['quote'])

        token_amount = format(round(Web3.fromWei(int(token_amounts), "ether"), 2), ",")
        usd_amount = format(round(int(usd_amounts), 7), ",")

        wbnb_amount = round(Web3.fromWei(int(transaction['received'][0]['value']), "ether"), 2)
        token_name = sent[0]['symbol']
        token_price = round(float(sent[0]['quoteRate']), 8)
        return token_amount, token_name, wbnb_amount, usd_amount, token_price

    def getText(self):
        transactions = self.getTransactions()
        textList=[]
        timeList=self.last_check

        if transactions is not None:
            transactions = sorted(transactions, key=lambda k: int(k['date']))

            for transaction in transactions:
                if transaction['date'] > self.last_check:
                    if 'sent' in transaction:
                        if transaction['sent'][0]['name'] == "Wrapped BNB": #transaction['sent'][0]['name'] != "Wrapped BNB":
                            continue
                        if timeList < transaction['date']:  
                            timeList = transaction['date']
                        token_amount, token_name, wbnb_amount, usd_amount, token_price = self.getAmounts(transaction)
                        if wbnb_amount <0.2:
                            continue
                        if(int(wbnb_amount)>=4):
                            text = "\n {}".format(17*'🟢')
                        else:
                            text = "\n {}".format((int(wbnb_amount)*2+1)*'🟢')
                        text+= "\n <b>💵 BNB Miktari:</b> {} BNB (${}) ".format(wbnb_amount,usd_amount)
                        text += "\n <b><a href= 'https://bscscan.com/address/{}'>👤 SATIN ALAN</a> YENI </b>".format(transaction['sent'][0]['to'])
                        text += "\n <b>🤑 Token Miktari:</b> {} {} \n <b>💲Token Fiyati:</b> ${}".format(token_amount,token_name,token_price)
                        text += "\n <b>🚨DEX:</b> PancakeSwap"
                        text += f"\n <b>⏳ Zaman:</b> {self.timestampToHumanReadble(transaction['date'])}"
                        text += f"\n<a href='https://bscscan.com/tx/{transaction['id']}'>👁‍🗨 TX</a> | <a href= 'https://poocoin.app/tokens/{self.contract}'>📊 Chart</a> | <a href= 'https://pancakeswap.finance/swap?outputCurrency={self.contract}&chainId=56'>💱 Satin Al</a>"
                        
                        textList.append(text)
            self.last_check = timeList
        return textList

class ApiManager():
    def __init__(self) -> None:
        self.Marshall={} 
        self.readMarshall()
        
    def readMarshall(self):
        try:
            with open('MarshallLog.bin') as f:
                readFile=json.load(f)
                for element in readFile:
                    self.Marshall[str(element)]= GetBuy(readFile[element]['pancakeswap_address'],readFile[element]['contract'],readFile[element]['api_key'])
        except:
            print("Couldn't Find MarshallLog.bin")
            self.Marshall={}
        

    def writeMarshall(self):
        writeFile={}
        for element in  self.Marshall: 
            writeFile[str(element)] = {'pancakeswap_address':self.Marshall[element].pancakeswap_address,
                                'contract':self.Marshall[element].contract,
                                'api_key':self.Marshall[element].api_key}
        with open('MarshallLog.bin','w') as f:
            json.dump(writeFile,f)

    def addChat(self,chatId,pancakeswap_address,contract,api_key):
        self.Marshall[chatId] = GetBuy(pancakeswap_address.replace(' ',''),contract.replace(' ',''),api_key)
        self.writeMarshall()
        self.readMarshall()

    def removeChat(self,chatId):
        del self.Marshall[chatId]
        self.writeMarshall()
        self.readMarshall()

    def getText(self,chatId) -> list:
        result = self.Marshall[chatId].getText()
        return result

    def isReady(self,chatId):
        if chatId in self.Marshall:
            return True
        return False

import json
from datetime import datetime
from requests import get as getRequest
from web3 import Web3, HTTPProvider
import random
import requests

try:
    with open('MainLog.json') as f:
        Main = json.load(f)
except:
    print("Couldn't Find MainLog.json")
    Main = {}



    #self destruct PreSale PrivateSale FairLaunch
    #cookiesale adaptaation
    #clone
    #asycn

class AddManager():
    def init(self) -> None:
        self.NormalAdds = []
        self.ButtonAdds = []
        self.readAdds()
        self.checkAdds()

    def readAdds(self):
        try:
            with open('Addlog.json') as f:
                printedList = json.load(f)
        except:
            print("Couldn't Find Addlog.json")
            printedList = {'NormalAdds': [], 'ButtonAdds': []}
        self.NormalAdds = printedList['NormalAdds']
        self.ButtonAdds = printedList['ButtonAdds']

    def writeAdds(self):
        with open('Addlog.json', 'w') as f:
            json.dump({'NormalAdds': self.NormalAdds,
                      'ButtonAdds': self.ButtonAdds}, f)

    def checkAdds(self):
        current = int(datetime.timestamp(datetime.now()))

        for add in self.NormalAdds:
            if int(add[3]) + int(add[2]) < current:
                self.NormalAdds.remove(add)

        for add in self.ButtonAdds:
            if int(add[3]) + int(add[2]) < current:
                self.ButtonAdds.remove(add)
        self.writeAdds()
        self.readAdds()

    def getRandomAdds(self):
        self.checkAdds()
        Adds = [[f"\n\n <b>🚀 Ad's:</b> <b>Ads your project📞</b>", None, None, None],
                ['Advertise your project here 📞', "https://t.me/CrypTechKing", None, None]]

        if len(self.NormalAdds) > 0:
            AnAdds = self.NormalAdds[random.randint(0, len(self.NormalAdds)-1)]
            Adds[0][0] = f"\n\n <b>🚀 Ad's:</b> '<a href='{AnAdds[1]}'><b>{AnAdds[0]}</b></a>'"

        if len(self.ButtonAdds) > 0:
            Adds[1] = self.ButtonAdds[random.randint(
                0, len(self.ButtonAdds)-1)]

        return Adds

    def addNormalAdd(self, text, link, time=24):
        self.NormalAdds.append([text.strip(), link.replace(' ', ''), int(
            datetime.timestamp(datetime.now())), time*60*60])
        self.writeAdds()

    def AddButtonAdd(self, text, link, time=24):
        self.ButtonAdds.append([text.strip(), link.replace(' ', ''), int(
            datetime.timestamp(datetime.now())), time*60*60])
        self.writeAdds()

AddMngr=AddManager()

class Chats():
    def __init__(self) -> None:
        self.allChats = []
        self.read_chat()

    def add_chat(self,admin,chat_id,botToken):
        self.allChats.append(Chat(admin,chat_id,botToken))

    def remove_chat(self, chat_id):
        for chat in self.allChats:
            if chat_id == chat.chatId:
                self.allChats.remove(chat)
                self.write_chat()
                return True
        pass

    def read_chat(self):
        try:
            with open('ChatsLog.json') as f:
                readFile = json.load(f)
            for chatId in readFile:
                chat = Chat(readFile[chatId]["admin"],
                            chatId, readFile[chatId]["botToken"])
                for event in readFile[chatId]["events"]:
                    if event["type"] == 1:
                        chat.events.append(Token(
                            event["tokenAddress"],
                            event["token2Info"],
                            event["pairAddress"],
                            event["Network"],
                            event["DEX"],
                            event["symbol"],
                            event["name"],
                            event["decimals"],
                            event["isSellTrack"]))
                    elif event["type"] == 3:
                        chat.events.append(PrivateSale(
                            event["saleAddress"],
                            event["Network"],
                            event["Platform"]))
                    elif event["type"] == 2:
                        chat.events.append(PreSale(
                            event["tokenAddress"],
                            event["saleAddress"],
                            event["Network"],
                            event["Platform"],
                            event["symbol"],
                            event["name"],
                            event["decimal"]
                        ))

                    elif event["type"] == 4:
                        chat.events.append(FairLaunch(
                            event["tokenAddress"],
                            event["saleAddress"],
                            event["Network"],
                            event["Platform"],
                            event["symbol"],
                            event["name"],
                            event["decimal"]
                        ))
                self.allChats.append(chat)
        except:
            print("Couldn't Find ApiLog.json")
            self.allChats = {}

    def write_chat(self):
        writeDict = {}
        for chat in self.allChats:
            writeDict[chat.chatId] = {}
            writeDict[chat.chatId]["botToken"] = chat.botToken
            writeDict[chat.chatId]["admin"] = chat.admin
            writeDict[chat.chatId]["events"] = []
            for event in chat.events:
                if event.Type == 1:
                    writeDict[chat.chatId]["events"].append(
                        {"tokenAddress": event.tokenAddress,
                         "token2Info": event.token2Info,
                         "pairAddress": event.pairAddress,
                         "Network": event.Network,
                         "DEX": event.DEX,
                         "symbol": event.symbol,
                         "name": event.name,
                         "decimals": event.decimals,
                         "isSellTrack": event.isSellTrack,
                         "type": event.type,
                         })

                elif event.Type == 3:
                    writeDict[chat.chatId]["events"].append(
                        {"saleAddress": event.saleAddress,
                         "Network": event.Network,
                         "Platform": event.Platform,
                         "type": event.type})

                elif event.Type == 2 or event.Type == 4:
                    writeDict[chat.chatId]["events"].append({
                        "tokenAddress": event.tokenAddress,
                        "pairAddress": event.saleAddress,
                        "Network": event.Network,
                        "Platform": event.Platform,
                        "symbol": event.symbol,
                        "name": event.name,
                        "decimals": event.decimals,
                        "type": event.type
                    })
        try:
            with open('ChatsLog.json', 'w') as f:
                json.dump(writeDict, f)
        except:
            print("Couldn't Write ChatsLog.json")

    def get_chats(self):
        return self.allChats

    def get_chat(self, chat_id):
        for chat in self.allChats:
            if chat_id == chat.chatId:
                return chat
        return None

ChatMngr=Chats()
class Chat():
    def __init__(self, admin, chatId, botToken) -> None:
        self.botToken = botToken
        self.chatId = chatId
        self.gifAddress='https://media1.giphy.com/media/uFtywzELtkFzi/giphy.gif?cid=ecf05e47c09tjs9rucnyje673txuni8nl2oc2qit2177x8h4&rid=giphy.gif&ct=g'
        self.events = []
        self.admin = admin
        self.url = 'https://api.telegram.org/bot{0}/{1}'.format(
            self.botToken, "sendDocument")

    async def getEvent(self):
        for event in self.events:
            text = await event.getText()
            for t in text:
                Adds = AddMngr.getRandomAdds()
                t += Adds[0][0]
                _data = {'chat_id':  self.chatId,
                         'document': self.gifAddress,
                         'caption': t,
                         'parse_mode': 'HTML',
                         'reply_markup': json.dumps({"inline_keyboard": [[{"text": Adds[1][0], "url": Adds[1][1]}]]})}

            response = requests.post(url=self.url, data=_data).json()

            if 'description' in response:
                if response['description'] == 'Bad Request: chat not found' or response['description'] == 'Forbidden: bot was kicked from the supergroup chat':
                    return False
            return True

    def addEvent(self, event):
        self.events.append(event)

    def getEvents(self):
        return self.events

    def removeEvent(self, index):
        self.events.remove(index)

    def settingEvent(self, index, emoji=None, downLimit=None, Stop=None):
        if emoji:
            self.events[index].emoji = emoji

        if downLimit:
            self.events[index].downLimit = downLimit

        if Stop:
            self.events[index].Stop = Stop

    def getInformation(self):
        aList=[]
        for event in self.events:
            aList.append(event.getInfo())
        
        return aList

def timestampToHumanReadble(timestamp):
    date_time = datetime.fromtimestamp(timestamp)
    return date_time.strftime("%H:%M:%S %d/%m/%Y")


class EventCreateManeger():
    def __init__(self, tokenAddress, Network, Platform, Type):
        self.Type = int(Type)
        self.Element = None
        self.infoNetwork = Main["Networks"][Network]
        self.infoPlatform = Main["Platforms"][Platform]
        self.tokenAddress = tokenAddress
        self.ready = False

    async def getAllLPs(self):
        (self.symbol, self.name, self.decimal) = await WebThree().getMetaInformation(self.tokenAddress, self.infoNetwork["Provider"])
        lps = await WebThree().getLps(self.infoNetwork["Provider"], self.infoPlatform["FactoryAddress"], self.tokenAddress, self.infoNetwork["TokensInformation"])

        for lp in lps:
            lp[0] += " / " + self.name

        return lps

    def createToken(self, requirmentList):
        self.Element = Token(
            self.tokenAddress,
            requirmentList[2],
            requirmentList[1],
            self.infoNetwork,
            self.infoPlatform,
            self.symbol,
            self.name,
            self.decimal,
            requirmentList[3])
        self.ready = True
        return self.Element

    async def createSaleAddress(self, requirmentList):
        if self.Type == 2:
            (self.symbol, self.name, self.decimal) = await WebThree().getMetaInformation(self.tokenAddress, self.infoNetwork["Provider"])
            return PreSale(
                self.tokenAddress,
                requirmentList[0],
                self.infoNetwork,
                self.infoPlatform,
                self.symbol,
                self.name,
                self.decimal
            )
        elif self.Type == 3:
            return PrivateSale(
                requirmentList[0],
                self.infoNetwork,
                self.infoPlatform,
            )
        elif self.Type == 4:
            (self.symbol, self.name, self.decimal) = await WebThree().getMetaInformation(self.tokenAddress, self.infoNetwork["Provider"])
            return FairLaunch(
                self.tokenAddress,
                requirmentList[0],
                self.infoNetwork,
                self.infoPlatform,
                self.symbol,
                self.name,
                self.decimal
            )


class Token():
    async def __init__(
            self,
            tokenAddress,
            token2Info,
            pairAddress,
            Network,
            DEX,
            symbol,
            name,
            decimal,
            isSellTrack) -> None:

        self.tokenAddress = tokenAddress
        self.token2Info = token2Info
        self.pairAddress = pairAddress
        self.Network = Network
        self.DEX = DEX
        self.symbol = symbol
        self.name = name
        self.decimal = decimal
        self.isSellTrack = isSellTrack
        self.Text = {1: "SELL", 0: "BUY"}

        self.emoji = "🟢"
        self.downLimit = 100
        self.step = 100
        self.type = 1
        self.Stop = False

        self.lastCheckBlock = await WebThree().getBlockNumber(Network["Provider"])

    def isSell(self, amount0In, amount1In, amount0Out, amount1Out):
        if self.pairedTokenAddress == self.token2Info["Address"]:
            if amount1In > 0 and amount0Out > 0 and amount0In == 0 and amount1Out == 0:
                # Buy
                return (0, float(amount1In)/10**self.decimal, float(amount0Out)/10**18)
            elif amount1In == 0 and amount0Out == 0 and amount0In > 0 and amount1Out > 0:
                # Sell
                return (1, float(amount1Out)/10**self.decimal, float(amount0In)/10**18)
            else:
                return (2, 0, 0)  # DontKnow
        else:
            if amount1In > 0 and amount0Out > 0 and amount0In == 0 and amount1Out == 0:
                # Sell
                return (1, float(amount0Out)/10**self.decimal, float(amount1In)/10**18)
            elif amount1In == 0 and amount0Out == 0 and amount0In > 0 and amount1Out > 0:
                # Buy
                return (0, float(amount0In)/10**self.decimal, float(amount1Out)/10**18)
            else:
                return (2, 0, 0)  # DontKnow

    def getPrice(self):
        reserves, token0, = WebThree().getReserves(
            self.Network["Provider"], self.pairAddress)
        if self.pairedTokenAddress == token0:
            return (float(reserves[0])/10**self.decimal)/(float(reserves[1])/10**18)
        else:
            return (float(reserves[1])/10**18)/(float(reserves[1])/10**self.decimal)

    def processTx(self, txs, price):

        transactions = []
        for tx in txs:
            transaction = {"amount0In": 0,
                           "amount1In": 0,
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
            transaction["amount0In"] = int(tx["data"][2:66], 16)
            transaction["amount1In"] = int(tx["data"][66:130], 16)
            transaction["amount0Out"] = int(tx["data"][130:194], 16)
            transaction["amount1Out"] = int(tx["data"][194:258], 16)
            transaction["process"] = self.isSell(
                transaction["amount0In"], transaction["amount1In"], transaction["amount0Out"], transaction["amount1Out"])
            transaction["txHash"] = tx["transactionHash"]
            transaction["timestamp"] = int(tx["timeStamp"][2:], 16)
            transaction["address"] = "0x"+tx["topics"][-1][-40:]

            transaction["token2_price"] = float(price)
            transaction["token_price"] = self.getPrice()*float(price)
            transaction["token2_price_all"] = transaction["process"][2] * \
                float(price)
            transaction["token_price_all"] = transaction["process"][1] * \
                transaction["token_price"]
            transactions.append(transaction)
        return transactions

    async def getTx(self):
        url = self.Network["ApiURL"]+self.lastCheckBlock+"&address=" + str(self.pairAddress) + \
            "&topic0="+self.DEX["Topic"] + \
            "&apikey="+self.Network["ApiKey"]

        try:
            Txs = getRequest(url).json()['price']
        except:
            Txs = None

        self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
        return Txs

    def getUSDPrice(self):
        try:
            price = getRequest(self.token2Info["PriceURL"]).json()['price']
        except:
            price = 0
        return price

    async def getTxMessages(self):
        if self.Stop == True:
            self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
            return None
        txs = await self.getTx()
        price = self.getUSDPrice()
        transactions = self.processTx(txs, price)
        textList = []
        if transactions:
            transactions = sorted(
                transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                if (self.isSellTrack == transaction['process'][0]) and transaction["token2_price_all"] > self.downLimit:
                    textList.append(self.getText(transaction["address"], transaction["process"][1], transaction["process"][2],
                                    transaction["token2_price_all"], transaction["token_price"], transaction["timestamp"], transaction["txHash"]))

        return textList

    def getText(self, address, token_amount, token2_amount, usd_amount, token_price, timestamp, txHash):
        token_amount = round(token_amount, 4)
        token2_amount = round(token2_amount, 4)
        usd_amount = round(usd_amount, 4)
        token_price = round(token_price, 4)

        text = "{} {}\n".format(self.name, self.Text[self.isSellTrack])
        text += self.emoji * (int(usd_amount/self.step)+1)+"\n"
        text += "\n <b><a href= '{}address/{}'>👤 Trader</a></b>".format(
            self.Network["NetworkURL"], address)
        text += "\n <b>🤑 Got:</b> {} {} \n <b>💵 Spent:</b> {} {} (${}) \n <b>💲 Price/Token:</b> ${}".format(
            token_amount, self.symbol, token2_amount, self.token2Info["Symbol"], usd_amount, token_price)
        text += "\n <b>🚨DEX:</b> {}".format(self.DEX["PlatformName"])
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        text += "\n<a href='{}'>👁‍🗨 TX</a> | <a href= 'https://charts.bogged.finance/?c=bsc&t={}'>📊 Chart</a> | <a href= '{}'>💱 Buy</a>".format(
            self.Network["NetworkExplorer"]+txHash, self.tokenAddress, self.DEX["PlatformSwap"]+self.tokenAddress)
        return text

    def getInfo(self):#Need to be updated
        text=f"📈 <b>{self.name}</b> 📈\n"
        text+=f"🔗 <a href='{self.Network['NetworkURL']}address/{self.tokenAddress}'>Token</a> | <a href='{self.Network['NetworkURL']}address/{self.saleAddress}'>Sale</a>\n"
        text+=f"📊 <a href='https://charts.bogged.finance/?c=bsc&t={self.tokenAddress}'>Chart</a> | <a href='{self.DEX['PlatformSwap']}{self.tokenAddress}'>Buy</a>\n"
        text+=f"📝 <a href='{self.Network['NetworkExplorer']}'>Explorer</a> | <a href='{self.Network['NetworkURL']}'>Network</a>\n"
        text+=f"📈 <a href='{self.Network['PriceURL']}'>Price</a> | <a href='{self.Network['PriceURL']}'>Price</a>\n"
        return text

class PreSale():
    async def __init__(
            self,
            tokenAddress,
            saleAddress,
            Network,
            Platform,
            symbol,
            name,
            decimal) -> None:

        self.tokenAddress = tokenAddress
        self.saleAddress = saleAddress
        self.Network = Network
        self.Platform = Platform
        self.symbol = symbol
        self.name = name
        self.decimal = decimal

        self.tokenInfo2 = {"PriceURL": self.Network["PriceURL"]}
        self.emoji = "🟢"
        self.downLimit = 100
        self.step = 100
        self.type = 2
        self.Stop = False

        self.lastCheckBlock = await WebThree().getBlockNumber(Network["Provider"])

    def processTx(self, txs, price):

        transactions = []
        for tx in txs:
            if (not "Name" in self.tokenInfo2):
                token2Address = "0x"+tx['data'][26:66]
                flag = True
                for token in self.Network["TokensInformation"]:
                    if token['Address'] == token2Address:
                        self.tokenInfo2 = token
                        flag = False
                        break

                if flag:
                    self.tokenInfo2 = self.Network["CoinInformation"]

            transaction = {"tokenAmount": 0,
                           "txHash": 0,
                           "timestamp": 0,
                           "address": "",
                           "token_price": 0,
                           "usd_amount": 0
                           }

            transaction["token2Amount"] = int(
                tx['data'][66:130], 16)/self.tokenInfo2["Decimals"]**18
            transaction["txHash"] = tx["transactionHash"]
            transaction["timestamp"] = int(tx["timeStamp"], 16)
            transaction["address"] = "0x"+tx["topics"][-1][-40:]
            transaction["token2_price"] = float(price)
            transaction["usd_amount"] = transaction["tokenAmount"]*float(price)
            transactions.append(transaction)

        return transactions

    async def getTx(self):
        url = self.Network["ApiURL"]+self.lastCheckBlock+"&address=" + str(self.saleAddress) + \
            "&topic0="+self.Platform["PresaleTopic"] + \
            "&apikey="+self.Network["ApiKey"]

        try:
            Txs = getRequest(url).json()['price']
        except:
            Txs = None

        self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
        return Txs

    def getUSDPrice(self):
        try:
            price = getRequest(self.tokenInfo2["PriceURL"]).json()['price']
        except:
            price = 0
        return price

    async def getTxMessages(self):
        if self.Stop == True:
            self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
            return None
        txs = await self.getTx()
        price = self.getUSDPrice()
        transactions = self.processTx(txs, price)
        textList = []
        if transactions:
            transactions = sorted(
                transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                if transaction["token2Amount"] > self.downLimit:
                    textList.append(self.getText(transaction["address"], transaction["token2Amount"],
                                    transaction["usd_amount"], transaction["timestamp"], transaction["txHash"]))

        return textList

    def getText(self, address, token2_amount, usd_amount, timestamp, txHash):
        token2_amount = round(token2_amount, 4)
        usd_amount = round(usd_amount, 4)

        text = "{} {}\n".format(self.name, "CONTRIBUTE")
        text += self.emoji * (int(usd_amount/self.step)+1)+"\n"
        text += "\n <b><a href= '{}address/{}'>👤 Trader</a></b>".format(
            self.Network["NetworkURL"], address)
        text += "\n <b>🤑 Platform:</b> {}".format(
            self.Platform["PlatformName"])
        text += "\n <b>🤑 PreSale:</b>  {} \n <b>💵 Spent:</b> {} {} (${})".format(
            self.symbol, token2_amount, self.tokenInfo2["Symbol"], usd_amount)
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        text += "\n<a href='{}'>👁‍🗨 TX</a> | <a href= '{}'>💱 Contribute</a>".format(
            self.Network["NetworkExplorer"]+txHash, self.Platform["PlatformExplorer"]+self.saleAddress)
        return text

    def getInfo(self):#Need to be updated
        text=f"📈 <b>{self.name}</b> 📈\n"
        text+=f"🔗 <a href='{self.Network['NetworkURL']}address/{self.tokenAddress}'>Token</a> | <a href='{self.Network['NetworkURL']}address/{self.saleAddress}'>Sale</a>\n"
        text+=f"📊 <a href='https://charts.bogged.finance/?c=bsc&t={self.tokenAddress}'>Chart</a> | <a href='{self.DEX['PlatformSwap']}{self.tokenAddress}'>Buy</a>\n"
        text+=f"📝 <a href='{self.Network['NetworkExplorer']}'>Explorer</a> | <a href='{self.Network['NetworkURL']}'>Network</a>\n"
        text+=f"📈 <a href='{self.Network['PriceURL']}'>Price</a> | <a href='{self.Network['PriceURL']}'>Price</a>\n"
        return text

class PrivateSale():
    async def __init__(
        self,
        saleAddress,
        Network,
        Platform,
    ) -> None:

        self.saleAddress = saleAddress
        self.Network = Network
        self.Platform = Platform

        self.tokenInfo2 = {"PriceURL": self.Network["PriceURL"]}
        self.emoji = "🟢"
        self.downLimit = 100
        self.step = 100
        self.type = 3
        self.Stop = False

        self.lastCheckBlock = await WebThree().getBlockNumber(Network["Provider"])

    def processTx(self, txs, price):

        transactions = []
        for tx in txs:
            if (not "Name" in self.tokenInfo2):
                token2Address = "0x"+tx['data'][26:66]
                flag = True
                for token in self.Network["TokensInformation"]:
                    if token['Address'] == token2Address:
                        self.tokenInfo2 = token
                        flag = False
                        break

                if flag:
                    self.tokenInfo2 = self.Network["CoinInformation"]

            transaction = {"tokenAmount": 0,
                           "txHash": 0,
                           "timestamp": 0,
                           "address": "",
                           "token_price": 0,
                           "usd_amount": 0
                           }

            transaction["token2Amount"] = int(
                tx['data'][66:130], 16)/self.tokenInfo2["Decimals"]**18
            transaction["txHash"] = tx["transactionHash"]
            transaction["timestamp"] = int(tx["timeStamp"], 16)
            transaction["address"] = "0x"+tx["topics"][-1][-40:]
            transaction["token2_price"] = float(price)
            transaction["usd_amount"] = transaction["tokenAmount"]*float(price)
            transactions.append(transaction)

        return transactions

    async def getTx(self):
        url = self.Network["ApiURL"]+self.lastCheckBlock+"&address=" + str(self.saleAddress) + \
            "&topic0="+self.Platform["PrivateTopic"] + \
            "&apikey="+self.Network["ApiKey"]

        try:
            Txs = getRequest(url).json()['price']
        except:
            Txs = None

        self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
        return Txs

    def getUSDPrice(self):
        try:
            price = getRequest(self.tokenInfo2["PriceURL"]).json()['price']
        except:
            price = 0
        return price

    async def getTxMessages(self):
        if self.Stop == True:
            self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
            return None
        txs = await self.getTx()
        price = self.getUSDPrice()
        transactions = self.processTx(txs, price)
        textList = []
        if transactions:
            transactions = sorted(
                transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                if transaction["token2Amount"] > self.downLimit:
                    textList.append(self.getText(transaction["address"], transaction["token2Amount"],
                                    transaction["usd_amount"], transaction["timestamp"], transaction["txHash"]))

        return textList

    def getText(self, address, token2_amount, usd_amount, timestamp, txHash):
        token2_amount = round(token2_amount, 4)
        usd_amount = round(usd_amount, 4)

        text = "{}\n".format("CONTRIBUTE")
        text += self.emoji * (int(usd_amount/self.step)+1)+"\n"
        text += "\n <b><a href= '{}address/{}'>👤 Trader</a></b>".format(
            self.Network["NetworkURL"], address)
        text += "\n <b>🤑 Platform:</b> {}".format(
            self.Platform["PlatformName"])
        text += "<b>💵 Spent:</b> {} {} (${})".format(token2_amount,
                                                     self.tokenInfo2["Symbol"], usd_amount)
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        text += "\n<a href='{}'>👁‍🗨 TX</a> | <a href= '{}'>💱 Contribute</a>".format(
            self.Network["NetworkExplorer"]+txHash, self.Platform["PlatformExplorer"]+self.saleAddress)
        return text

    def getInfo(self):#Need to be updated
        text=f"📈 <b>{self.name}</b> 📈\n"
        text+=f"🔗 <a href='{self.Network['NetworkURL']}address/{self.tokenAddress}'>Token</a> | <a href='{self.Network['NetworkURL']}address/{self.saleAddress}'>Sale</a>\n"
        text+=f"📊 <a href='https://charts.bogged.finance/?c=bsc&t={self.tokenAddress}'>Chart</a> | <a href='{self.DEX['PlatformSwap']}{self.tokenAddress}'>Buy</a>\n"
        text+=f"📝 <a href='{self.Network['NetworkExplorer']}'>Explorer</a> | <a href='{self.Network['NetworkURL']}'>Network</a>\n"
        text+=f"📈 <a href='{self.Network['PriceURL']}'>Price</a> | <a href='{self.Network['PriceURL']}'>Price</a>\n"
        return text


class FairLaunch():
    async def __init__(
            self,
            tokenAddress,
            saleAddress,
            Network,
            Platform,
            symbol,
            name,
            decimal) -> None:

        self.tokenAddress = tokenAddress
        self.saleAddress = saleAddress
        self.Network = Network
        self.Platform = Platform
        self.symbol = symbol
        self.name = name
        self.decimal = decimal

        self.tokenInfo2 = {"PriceURL": self.Network["PriceURL"]}
        self.emoji = "🟢"
        self.downLimit = 100
        self.step = 100
        self.type = 2
        self.Stop = False

        self.lastCheckBlock = await WebThree().getBlockNumber(Network["Provider"])

    def processTx(self, txs, price):

        transactions = []
        for tx in txs:
            if (not "Name" in self.tokenInfo2):
                token2Address = "0x"+tx['data'][26:66]
                flag = True
                for token in self.Network["TokensInformation"]:
                    if token['Address'] == token2Address:
                        self.tokenInfo2 = token
                        flag = False
                        break

                if flag:
                    self.tokenInfo2 = self.Network["CoinInformation"]

            transaction = {"tokenAmount": 0,
                           "txHash": 0,
                           "timestamp": 0,
                           "address": "",
                           "token_price": 0,
                           "usd_amount": 0
                           }

            transaction["token2Amount"] = int(
                tx['data'][66:130], 16)/self.tokenInfo2["Decimals"]**18
            transaction["txHash"] = tx["transactionHash"]
            transaction["timestamp"] = int(tx["timeStamp"], 16)
            transaction["address"] = "0x"+tx["topics"][-1][-40:]
            transaction["token2_price"] = float(price)
            transaction["usd_amount"] = transaction["tokenAmount"]*float(price)
            transactions.append(transaction)

        return transactions

    async def getTx(self):
        url = self.Network["ApiURL"]+self.lastCheckBlock+"&address=" + str(self.saleAddress) + \
            "&topic0="+self.Platform["FairLaunchTopic"] + \
            "&apikey="+self.Network["ApiKey"]

        try:
            Txs = getRequest(url).json()['price']
        except:
            Txs = None

        self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
        return Txs

    def getUSDPrice(self):
        try:
            price = getRequest(self.tokenInfo2["PriceURL"]).json()['price']
        except:
            price = 0
        return price

    async def getTxMessages(self):
        if self.Stop == True:
            self.lastCheckBlock = await WebThree().getBlockNumber(self.Network["Provider"])
            return None
        txs = self.getTx()
        price = self.getUSDPrice()
        transactions = self.processTx(txs, price)
        textList = []
        if transactions:
            transactions = sorted(
                transactions, key=lambda element: int(element["timestamp"]))

            for transaction in transactions:
                if transaction["token2Amount"] > self.downLimit:
                    textList.append(self.getText(transaction["address"], transaction["token2Amount"],
                                    transaction["usd_amount"], transaction["timestamp"], transaction["txHash"]))

        return textList

    def getText(self, address, token2_amount, usd_amount, timestamp, txHash):
        token2_amount = round(token2_amount, 4)
        usd_amount = round(usd_amount, 4)

        text = "{} {}\n".format(self.name, "CONTRIBUTE")
        text += self.emoji * (int(usd_amount/self.step)+1)+"\n"
        text += "\n <b><a href= '{}address/{}'>👤 Trader</a></b>".format(
            self.Network["NetworkURL"], address)
        text += "\n <b>🤑 Platform:</b> {}".format(
            self.Platform["PlatformName"])
        text += "\n <b>🤑 FairLaunch:</b>  {} \n <b>💵 Spent:</b> {} {} (${})".format(
            self.symbol, token2_amount, self.tokenInfo2["Symbol"], usd_amount)
        text += f"\n <b>⏳ Time:</b> {timestampToHumanReadble(timestamp)}"
        text += "\n<a href='{}'>👁‍🗨 TX</a> | <a href= '{}'>💱 Contribute</a>".format(
            self.Network["NetworkExplorer"]+txHash, self.Platform["PlatformExplorer"]+self.saleAddress)
        return text

    def getInfo(self):#Need to be updated
        text=f"📈 <b>{self.name}</b> 📈\n"
        text+=f"🔗 <a href='{self.Network['NetworkURL']}address/{self.tokenAddress}'>Token</a> | <a href='{self.Network['NetworkURL']}address/{self.saleAddress}'>Sale</a>\n"
        text+=f"📊 <a href='https://charts.bogged.finance/?c=bsc&t={self.tokenAddress}'>Chart</a> | <a href='{self.DEX['PlatformSwap']}{self.tokenAddress}'>Buy</a>\n"
        text+=f"📝 <a href='{self.Network['NetworkExplorer']}'>Explorer</a> | <a href='{self.Network['NetworkURL']}'>Network</a>\n"
        text+=f"📈 <a href='{self.Network['PriceURL']}'>Price</a> | <a href='{self.Network['PriceURL']}'>Price</a>\n"
        return text

class WebThree():
    @staticmethod
    async def getBlockNumber(provider):
        web3 = Web3(HTTPProvider(provider))
        blockNumber = await web3.eth.blockNumber
        return blockNumber-10

    @staticmethod
    def getReserves(provider, pairAddress):
        web3 = Web3(HTTPProvider(provider))
        pairContract = web3.eth.contract(address=str(
            pairAddress), abi=json.load(open('pair_abi.json')))
        reserves = pairContract.functions.getReserves().call()
        token0 = pairContract.functions.token0().call()
        token1 = pairContract.functions.token1().call()
        return reserves, token0, token1

    @staticmethod
    async def getMetaInformation(provider, tokenAddress):
        web3 = Web3(HTTPProvider(provider))
        tokenContract = await web3.eth.contract(address=str(tokenAddress), abi=json.load(open('token_abi.json')))
        symbol = await tokenContract.functions.symbol().call()
        name = await tokenContract.functions.name().call()
        decimal = await tokenContract.functions.decimals().call()
        return symbol, name, decimal

    @staticmethod
    async def getLPs(provider, platformAddress, tokenAddress, pairedTokens):
        web3 = Web3(HTTPProvider(provider))
        platformContract = web3.eth.contract(address=str(
            platformAddress), abi=json.load(open('factory_abi.json')))
        resultPairs = []
        for pairedToken in pairedTokens:
            pairAddress = await platformContract.functions.getPair(tokenAddress, pairedToken["Address"]).call()
            if pairAddress != "0x0000000000000000000000000000000000000000":
                resultPairs.append(
                    [pairedToken["Name"], pairAddress, pairedToken])

        return resultPairs

    @staticmethod
    async def getLP(provider, factoryAddress, tokenAddress, tokenAddress2):
        web3 = Web3(HTTPProvider(provider))
        factory_contract = web3.eth.contract(
            address=factoryAddress, abi=json.load(open('factory_abi.json')))

        # Pair
        token2Address = Web3.toChecksumAddress(str(tokenAddress2))
        tokenAddress = Web3.toChecksumAddress(str(tokenAddress))

        pairAddress = factory_contract.functions.getPair(
            token2Address, tokenAddress).call()

        return pairAddress

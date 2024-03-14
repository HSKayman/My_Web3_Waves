import json
from msilib.schema import TextStyle
from requests import get as getRequest
from web3 import Web3, HTTPProvider
from datetime import datetime
from Types import Token, PreSale, FairLaunch, PrivateSale


class BSC:
    def __init__(self, API_key, tokenAddress, isWhat, router_address="0x10ED43C718714eb63d5aA57B78B54704E256024E") -> None:
        self.chainID = 56
        self.API_key = API_key
        self.WebThree = Web3(HTTPProvider("https://bsc-dataseed.binance.org/"))
        self.tokenAddress = tokenAddress
        self.setBlock()
        self.last_check = int(datetime.timestamp(datetime.now()))
        self.alchemy = None
        self.isWhat = isWhat
        self.router_address = router_address
        if int(isWhat) == 0:
            self.element = Token(self.WebThree, tokenAddress, router_address, 56, "bscscan", "PancakeSwap", [
                                 "https://pancakeswap.finance/swap?outputCurrency=", "&chainId="], "BNB")
        elif int(isWhat) == 1:
            self.element = PreSale(
                self.WebThree, tokenAddress, router_address, 56, "bscscan", "BNB")
        elif int(isWhat) == 2:
            self.element = FairLaunch(
                self.WebThree, tokenAddress, router_address, 56, "bscscan", "BNB")
        elif int(isWhat) == 3:
            self.element = PrivateSale(
                self.WebThree, tokenAddress, 56, "bscscan", "BNB")

    def getTx(self):

        try:
            price = getRequest(self.amountLink()).json()['price']
            txs = getRequest(self.getLink()).json()['result']
        except Exception as e:
            print("Error", e)
            return None, None
        return price, txs

    def getLink(self):
        link = "https://api.bscscan.com/api" + "?module=logs" + "&action=getLogs" + "&fromBlock=" + \
            str(self.fromBlock) + "&address=" + str(self.element.getAddress()) + \
            "&topic0="+str(self.element.getTopic()) + \
            "&apikey="+str(self.API_key)
        print("Link", link)
        return link

    def amountLink(self):
        return "https://api.binance.com/api/v3/ticker/price?symbol=BNBUSDT"

    def getInfo(self):
        return self.element.getInfo()

    def getText(self):
        price, txs = self.getTx()
        textList = []
        temp_last_check = self.last_check
        if txs:
            self.setBlock()
            transactions = self.element.getTexts(txs, price)
            for transaction in transactions:
                if self.last_check >= transaction[1]:
                    continue
                if temp_last_check < transaction[1]:
                    temp_last_check = transaction[1]

                textList.append(transaction[0])
            self.last_check =  temp_last_check

        return textList

    def setBlock(self):
        self.fromBlock = self.WebThree.eth.block_number-10



class ETH:
    def __init__(self, API_key, tokenAddress, isWhat, alchemy, router_address="0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D") -> None:
        self.chainID = 1
        self.API_key = API_key
        self.alchemy = alchemy
        self.router_address = router_address
        self.WebThree = Web3(HTTPProvider(
            f"https://eth-mainnet.g.alchemy.com/v2/{alchemy}"))

        self.setBlock()
        self.tokenAddress = tokenAddress
        self.last_check = int(datetime.timestamp(datetime.now()))
        self.isWhat = isWhat
        if int(isWhat) == 0:
            self.element = Token(self.WebThree, tokenAddress, router_address, 1, "etherscan", "UniSwap", [
                                 "https://pancakeswap.finance/swap?outputCurrency="], "ETH")
        elif int(isWhat) == 1:
            self.element = PreSale(
                self.WebThree, tokenAddress, router_address, 1, "etherscan", "ETH")
        elif int(isWhat) == 2:
            self.element = FairLaunch(
                self.WebThree, tokenAddress, router_address, 1, "etherscan", "ETH")
        elif int(isWhat) == 3:
            self.element = PrivateSale(
                self.WebThree, tokenAddress, 1, "etherscan", "ETH")

    def getTx(self):
        try:
            price = getRequest(self.amountLink()).json()['price']
            txs = getRequest(self.getLink()).json()['result']
        except Exception as e:
            print("Error", e)
            return None, None
        return price, txs

    def getLink(self):
        link = "https://api.etherscan.com/api?module=logs&action=getLogs&fromBlock=" + \
            str(self.fromBlock) + "&address=" + str(self.element.getAddress()) + \
            "&topic0="+self.element.getTopic() + "&apikey="+str(self.API_key)
        print("LINK", link)
        return link

    def amountLink(self):
        return "https://api.binance.com/api/v3/ticker/price?symbol=ETHUSDT"

    def getInfo(self):
        return self.element.getInfo()

    def getText(self):
        price, txs = self.getTx()
        textList = []
        temp_last_check = self.last_check
        if txs:
            self.setBlock()
            transactions = self.element.getTexts(txs, price)
            for transaction in transactions:
                if self.last_check >= transaction[1]:
                    continue
                if temp_last_check < transaction[1]:
                    temp_last_check = transaction[1]

                textList.append(transaction[0])
            self.last_check = temp_last_check

        return textList

    def setBlock(self):
        self.fromBlock = self.WebThree.eth.block_number-10


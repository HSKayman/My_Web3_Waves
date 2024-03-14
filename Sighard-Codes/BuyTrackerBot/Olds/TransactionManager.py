import json
from requests import get as getRequest
from datetime import datetime
from Networks import BSC,ETH
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
            with open('Addlog.json') as f:
                printedList=json.load(f)   
        except:
            print("Couldn't Find Addlog.json")
            printedList = {'NormalAdds':[],'ButtonAdds':[]}
        self.NormalAdds = printedList['NormalAdds']
        self.ButtonAdds = printedList['ButtonAdds']

    def writeAdds(self):
        with open('Addlog.json','w') as f:
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
            Adds[0][0] = f"\n\n <b>🚀 Ad's:</b> '<a href='{AnAdds[1]}'><b>{AnAdds[0]}</b></a>'"

        if len(self.ButtonAdds) > 0:
            Adds[1] = self.ButtonAdds[random.randint(0,len(self.ButtonAdds)-1)]
        
        return Adds

    def addNormalAdd(self,text,link,time=24):
        self.NormalAdds.append([text.strip(),link.replace(' ',''),int(datetime.timestamp(datetime.now())),time*60*60])
        self.writeAdds()
    
    def AddButtonAdd(self,text,link,time=24):
        self.ButtonAdds.append([text.strip(),link.replace(' ',''),int(datetime.timestamp(datetime.now())),time*60*60])
        self.writeAdds()


class CreateManager():
    def __init__(self) -> None:
        self.APIS={} 
        self.readApi()

    def readApi(self):
        try:
            with open('ApiLog.json') as f:
                readFile=json.load(f)
                for element in readFile:
                      self.APIS[element] = element["ChainID"]
                      self.APIS[element] = element["ChainID"] 
        except Exception as e:
            print("Couldn't Find ApiLog.json",e)
            self.APIS={}


class Token():
    def __init__(self):
        pass
with open('Addlog.json') as f:
    InformationList=json.load(f) 

class TransactionManager():
    def __init__(self,types,tokenAddress,chainName,saleAddressOrDex=None,platform=None) -> None:
        self.chainName=chainName
        self.tokenAddress=tokenAddress
        self.types=types
        self.saleAddressOrDex=saleAddressOrDex
        self.platform=platform
        if types == "Token":
            self.Tx=Token(self.tokenAddress,self.chainName,saleAddressOrDex)
        elif types == "PreSale":
            self.Tx=PreSale(self.tokenAddress,self.chainName,platform)
        elif types == "FairLaunch":
            self.Tx=FairLaunch(self.tokenAddress,self.chainName,platform)
        else:
            self.Tx=PrivateSale(self.tokenAddress,self.chainName,platform)

    



class PreSale():
    def __init__(self):
        pass

class FairLaunch():
    def __init__(self):
        pass

class PrivateSale():
    def __init__(self):
        pass

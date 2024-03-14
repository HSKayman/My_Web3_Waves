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


class ApiManager():
    def __init__(self) -> None:
        self.APIS={} 
        self.readApi()

        
    def readApi(self):
        try:
            with open('ApiLog.json') as f:
                readFile=json.load(f)
                for element in readFile:
                    if readFile[str(element)]['chainID']==56:
                        if int(readFile[str(element)]['isWhat'])>0:
                            self.APIS[str(element)]= BSC(readFile[str(element)]['API_key'],readFile[str(element)]['tokenAddress'],readFile[str(element)]['isWhat'],readFile[str(element)]['routerOrPair'])
                        else:
                            self.APIS[str(element)]= BSC(readFile[str(element)]['API_key'],readFile[str(element)]['tokenAddress'],readFile[str(element)]['isWhat'])
                    elif readFile[str(element)]['chainID']==1:
                        if int(readFile[str(element)]['isWhat'])>0:
                            self.APIS[str(element)]= ETH(readFile[str(element)]['API_key'],readFile[str(element)]['tokenAddress'],readFile[str(element)]['isWhat'],readFile[str(element)]['alchemy'],readFile[str(element)]['routerOrPair'])
                        else:
                            self.APIS[str(element)]= ETH(readFile[str(element)]['API_key'],readFile[str(element)]['tokenAddress'],readFile[str(element)]['isWhat'],readFile[str(element)]['alchemy'])
        except Exception as e:
            print("Couldn't Find ApiLog.json",e)
            self.APIS={}


    def writeApi(self):
        writeFile={}
        for element in  self.APIS: 
            writeFile[str(element)] = {'chainID': self.APIS[element].chainID,
                                    'API_key': self.APIS[element].API_key,
                                    'tokenAddress': self.APIS[element].tokenAddress,
                                    'isWhat': self.APIS[element].isWhat, 
                                    'alchemy': self.APIS[element].alchemy,
                                    'routerOrPair': self.APIS[element].router_address}
        with open('ApiLog.bin','w') as f:
            json.dump(writeFile,f)

    def addChat(self,chatId,contract,api_key,chainID,isWhat,routerOrPair=None,alchemy=None):
        if chainID==56:
            if(int(isWhat)==3):
                self.APIS[str(chatId)]= BSC(api_key.replace(' ',''),contract.replace(' ',''),int(isWhat))
            elif int(isWhat)>0:
                self.APIS[str(chatId)]= BSC(api_key.replace(' ',''),contract.replace(' ',''),int(isWhat),routerOrPair.replace(' ',''))
            else:
                self.APIS[str(chatId)]= BSC(api_key.replace(' ',''),contract.replace(' ',''),int(isWhat))
        elif chainID==1:
            if(int(isWhat)==3):
                self.APIS[str(chatId)]= BSC(api_key.replace(' ',''),contract.replace(' ',''),int(isWhat),alchemy.replace(' ',''))
            elif int(isWhat)>0:
                self.APIS[str(chatId)]= ETH(api_key.replace(' ',''),contract.replace(' ',''),int(isWhat),alchemy.replace(' ',''),routerOrPair.replace(' ',''))
            else:
                self.APIS[str(chatId)]= ETH(api_key.replace(' ',''),contract.replace(' ',''),int(isWhat),alchemy.replace(' ',''))
        self.writeApi()
        self.readApi()

    def removeChat(self,chatId):
        del self.APIS[chatId]
        self.writeApi()
        self.readApi()

    def getText(self,chatId) -> list:
        result = self.APIS[chatId].getText()
        return result

    def isReady(self,chatId):
        if chatId in self.APIS:
            return True
        return False

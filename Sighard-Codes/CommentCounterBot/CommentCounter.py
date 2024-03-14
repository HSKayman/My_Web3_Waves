# -*- coding: utf-8 -*-
"""
Created on Tue Jul  5 21:48:40 2022

@author: suca
"""

import json
import requests
import asyncio
from aiogram import Bot, Dispatcher
from aiogram.types import ParseMode
from aiogram.utils import executor
from datetime import datetime
import nest_asyncio
import time
nest_asyncio.apply()
bot: Bot
dp: Dispatcher
channel_id: int

async def startBot():
    while True:
        try:
            Memory=[]
            for username in usernames:
                try:
                    data=requests.get('https://disqus.com/api/3.0/timelines/activities?type=profile&index=comments&target=user%3Ausername%3A{}&api_key=E8Uh5l5fHZ6gD8U3KycjAIAk46f68Zw7C6eW8WSjZvCLXebZ7p0r1yrYDrLilk2F'.format(username))
                    comments=data.json()
                except Exception as e:
                    print('[E]1',e)
                    continue
                
                #print(comments)
                for key, value in comments["response"]["objects"].items():
                    if 'createdAt' in list(value.keys()):
                        if not value['createdAt'][:10] in list(printedList[username].keys()):
                            printedList[username][value["createdAt"][:10]]={}
                            printedList[username][value["createdAt"][:10]]['Count']=0
                            printedList[username][value["createdAt"][:10]]['Id']=[]
                            
                
                for key, value in comments["response"]["objects"].items():
                    if 'forum' in list(value.keys()) and 'createdAt' in list(value.keys()):
                        if not value['id'] in printedList[username][value['createdAt'][:10]]['Id'] and value['forum']=="pinksale":
                            
                            printedList[username][value['createdAt'][:10]]['Id'].append(value['id'])
                            printedList[username][value['createdAt'][:10]]['Count']+=1
                            if not value["createdAt"][:10] in Memory and value["createdAt"][:7]==datetime.now().strftime("%Y-%m"):
                                Memory.append(value["createdAt"][:10])
                                
            if not datetime.now().strftime("%Y-%m-%d") in Memory:
                Memory.append(datetime.now().strftime("%Y-%m-%d"))
                
            Memory=sorted(Memory,key=lambda i: int(i.replace('-',"")),reverse=True)
            for date in Memory:
                message=str(date)+"\n\n"
                for username in usernames:
                    if date in list(printedList[username].keys()):
                        message += f'{username} : <b>{printedList[username][date]["Count"]}</b>\n'
                    else: 
                        message += f'{username} : <b>0</b>\n'
                await bot.send_message(channel_id,message)
                await asyncio.sleep(5)
                
                if Memory[-1]==date:
                    message="Total Comments By Month \n\n"
                    messagesLine=[]
                    for username in usernames:
                        count=0
                        for recordedDate in printedList[username]:
                            if date[:-3] == recordedDate[:-3]:
                                count+=printedList[username][recordedDate]['Count']
                        messagesLine.append([username,count])
                    for username,count in sorted(messagesLine,key=lambda element: element[1],reverse=True):
                        message+=f'{username}\t\t:<b>{count}</b>\n'
                    await bot.send_message(channel_id,message)
                    await asyncio.sleep(5)
                
            
        except Exception as e:
            print('[E]2',e)
        finally:
            json.dump(printedList, open("log.bin",'w'))
            if(int(datetime.timestamp(datetime.now()))%86400 >= 86300):
                await asyncio.sleep(86400-int(datetime.timestamp(datetime.now()))%86400+5)
            
            await asyncio.sleep(86300-int(datetime.timestamp(datetime.now()))%86400)
def init():
    

    global usernames, dp, channel_id, bot, printedList
    #channel_id='-1001581088687'#test
    channel_id='-1001648583714'#group
    
    
    usernames=["harrykedelman",
             "interfinetwork",
             "AnalytixAudit",
             "techaudit",
             "CoinscopeCo",
             "blocksafuproject",
             "kesaviwebsolutions",
             "daudit",
             "defimoon_audits",
             "crackentech",
             "freshcoins",
             "SpyWolf_Audits",
             "audit_rate_tech",
             "contractwolf",
             "safuaudit",
             "rugfreecoins",
             "kishield",
             "cfgninja",
             "solidproof_io",
             "coinsultnet",
             "expelee"]
    
    try:
        with open('log.bin') as f:
            printedList=json.load(f)
        for username in usernames:
            if not username in printedList.keys():
                printedList[username]={}
            
    except:
        print("Couldn't Find log.bin")
        printedList = {}
        for i in usernames:
            printedList[i]={}
        
    #bot = Bot(token='5406551909:AAGbcuBlU1zzQ1jXfDxU-uZvqQyqfOokfKs', parse_mode=ParseMode.HTML)#test  
    bot = Bot(token='5396192235:AAFH2a6X-OKddfqjN9K_C2spNNlifFZDReI', parse_mode=ParseMode.HTML)#reel
    dp = Dispatcher(bot)
    if(int(datetime.timestamp(datetime.now()))%86400 >= 86300):
        time.sleep(86400-int(datetime.timestamp(datetime.now()))%86400+5)
    
    time.sleep(86300-int(datetime.timestamp(datetime.now()))%86400)
    

async def on_bot_start_up(dispatcher) -> None:
    asyncio.create_task(startBot())



init()
executor.start_polling(dp, skip_updates=True, on_startup=on_bot_start_up)
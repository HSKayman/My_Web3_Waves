# -*- coding: utf-8 -*-
"""
Created on Tue Jul  5 21:48:40 2022

@author: suca
"""

import urllib.request, json
import asyncio
from aiogram import Bot, Dispatcher
from aiogram.types import ParseMode
from aiogram.utils import executor

import nest_asyncio
import random
nest_asyncio.apply()
bot: Bot
dp: Dispatcher
channel_id: int

async def startBot():
    while True:
        try: 
            try:
                url='https://api.bscscan.com/api?module=logs&action=getLogs&fromBlock=20203221&toBlock=331913279&address=0x9a1cbE7C3D3bF452Ef21770992A7605Ae80c6A42&topic0=0x069a389daa77fb205c0a96c4e101fd8a54ffc755826d97c30e3ec9c921e947c0'
                with urllib.request.urlopen(url) as response:
                    events = {}
                    for i in response:
                        events = json.loads(i)
            except Exception as e:
                print('[E]1',e)
                continue
           
            for event in events['result']:
                if not event['transactionHash'] in printedList["transactionHash"]:
                    
                    Id=str(bytes.fromhex(event["data"][-64:]).decode('utf-8'))
                    randomNumber=random.random()
                    if randomNumber<0.33:
                        message='Hey admins, let @'+Id.replace('\x00','')+' in!\n'
                        await bot.send_animation(channel_id, animation="https://giphy.com/gifs/yx400dIdkwWdsCgWYp", caption=message)
                    elif randomNumber<0.66:
                        message='Welcome, sir! @'+Id+'\n'
                        await bot.send_photo(channel_id, photo='https://i.kym-cdn.com/entries/icons/mobile/000/021/290/bounsa.jpg' ,caption=message)
                    else:
                        message='Welcome to the club @'+Id+'\n'
                        await bot.send_animation(channel_id, animation="https://giphy.com/gifs/dicaprio-draw-serial-8Iv5lqKwKsZ2g",caption=message)
                    await asyncio.sleep(5)
                    printedList["transactionHash"].append(event['transactionHash'])
                
            
        except Exception as e:
            print('[E]2',e)
        finally:
            json.dump(printedList, open("log.bin",'w'))  
            await asyncio.sleep(90)
def init():
    

    global usernames, dp, channel_id, bot, printedList
    #channel_id='-1001581088687'#test
    channel_id='-1001750456890'#group
    
    try:
        with open('log.bin') as f:
            printedList=json.load(f)
            if not "transactionHash" in printedList.keys():
                printedList["transactionHash"]=[]    
            
    except:
        print("Couldn't Find log.bin")
        printedList = {}
        printedList["transactionHash"]=[]
        
    bot = Bot(token='', parse_mode=ParseMode.HTML)#reel
    dp = Dispatcher(bot)
    

async def on_bot_start_up(dispatcher) -> None:
    asyncio.create_task(startBot())



init()
executor.start_polling(dp, skip_updates=True, on_startup=on_bot_start_up)
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 15 22:53:08 2022

@author: suca
"""
import asyncio
import json

from aiogram import Bot, Dispatcher
from aiogram.types import ParseMode
from aiogram.utils import executor
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
import nest_asyncio
import time
from bs4 import BeautifulSoup
from requests import get
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time
nest_asyncio.apply()
 
async def tracer():
    global bot
        
    chrome_options = Options()
    chrome_options.add_argument("--headless") 
    chrome_path = './chromedriver.exe'
    driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
    url ="https://pinksale-trending.s3.ap-northeast-1.amazonaws.com/56_trending.json"
    Flag=True
    X=120
    await bot.send_message(-482189955,f"{1}. BERMUDA it's just test.")   
    while Flag:
        driver.get(url)
        jsonFile=driver.find_element_by_tag_name('pre').text
        for index,i in enumerate(json.loads(jsonFile)['list']):
            if i['address']=='0x3b9832C457B5C4FD2cC268ddD3C6e4274006bD38'.lower():
                await bot.send_message(-482189955,f"{index+1}. BERMUDA")
                X=6000
                break
        else:
            X=120       
        time.sleep(X)
    driver.close()
    return None

async def on_bot_start_up(dispatcher) -> None:
    #logger.info('Start up')
    asyncio.create_task(tracer())
    
bot = Bot(token='', parse_mode=ParseMode.HTML)
dp = Dispatcher(bot)
executor.start_polling(dp, skip_updates=True, on_startup=on_bot_start_up)




#print(ABIfinder('0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3',True))
#print(ABIfinder('0x757dBF1c18aE85b193F9cBb8E6875cf41E9F14C5'))
#print(ABIfinder('0x01aff183CbeB655644340A868f6c91FBDB172FCe'))
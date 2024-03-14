
from ast import parse
from xmlrpc.client import gzip_decode
import logging
import requests
import asyncio
import nest_asyncio
import json
from web3 import Web3, HTTPProvider
from aiogram.contrib.fsm_storage.memory import MemoryStorage
from requests import get as getRequest
from aiogram.dispatcher import FSMContext
from aiogram.dispatcher.filters import Text
from aiogram.dispatcher.filters.state import State, StatesGroup
from aiogram import Bot, Dispatcher, executor, types
from aiogram.types import ReplyKeyboardMarkup, ForceReply, KeyboardButton
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton
from requests import *
import os
import nest_asyncio
nest_asyncio.apply()
with open('conf.json') as f:
    Main = json.load(f)





BOT_TOKEN = Main["Telegram"]["BotToken"]
NetworkInfo = Main["Telegram"]["NetworkInfo"]
Address=Main["Telegram"]["Address"]
LastBlock=Main["Telegram"]["LastBlock"]
ISREADY=True
ChatID=Main["Telegram"]["ChatID"]

storage = MemoryStorage()
bot = Bot(token=BOT_TOKEN, parse_mode=types.ParseMode.HTML)
dp = Dispatcher(bot, storage=storage)

def getBlockNumber(provider):
    web3 = Web3(HTTPProvider(provider))
    blockNumber = web3.eth.blockNumber
    return blockNumber


async def Checker():
    global Address, NetworkInfo,LastBlock,ISREADY,ChatID
    while True:
        try:
            print("Waiting")
            await asyncio.sleep(10)
            if ISREADY:
                print("Checking")
                try:
                    Txs = getRequest(NetworkInfo["Link"]+"&address="+str(Address)+"&startblock="+str(LastBlock)).json()
                except:
                    Txs = None
                if Txs:
                    for Tx in Txs["result"]:

                        if (int(Tx["value"]) == 3*int(10**18) or int(Tx["value"]) == 2*int(10**18)) and Tx["to"]==str(Address).lower():
                            await bot.send_message(ChatID,"<b>Token Tracker</b>\n\n<b>Network:</b> "+NetworkInfo["Name"]+"\n<b>Wallet Address:</b> "+Address+"\n<b>Amount:</b> "+str(int(Tx["value"])/10**18)+" "+NetworkInfo["Name"]+"\n<b><a href= '"+NetworkInfo["Explorer"]+Tx["hash"]+"'>Transaction</a></b> ")
                            await asyncio.sleep(2)
                            if int(LastBlock)<int(Tx["blockNumber"]):
                                LastBlock=int(Tx["blockNumber"])+1

        except Exception as e:
           print("E2", e)



class Form(StatesGroup):
    One = State()  
    Two = State()  

@dp.message_handler(commands=['continue'])
async def addTracker(message: types.Message):
    global Address, NetworkInfo,LastBlock,ISREADY,ChatID
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        if len(Main["Telegram"]["Address"])==42:
            ISREADY=True
            await message.reply("Tracker Started")
        else:
            await message.reply("Tracker is not configured.")

@dp.message_handler(commands=['track'])
async def addTracker(message: types.Message):
    global Address, NetworkInfo,LastBlock,ISREADY,ChatID
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        ChatID=str(message.chat.id)
        button1 = InlineKeyboardButton(text="BSC", callback_data="BSC")
        button2 = InlineKeyboardButton(text="ETH", callback_data="ETH")
        button3 = InlineKeyboardButton(text="BSCT", callback_data="BSCT")
        keyboard_inline = InlineKeyboardMarkup().add(button1, button2,button3)
        await message.reply("<b>Select Network:</b>", reply_markup=keyboard_inline)
    else:
        await message.reply("You are not an admin of this group.")



@dp.callback_query_handler(text=["BSC", "ETH","BSCT"])
async def addTracker2(call: types.CallbackQuery):
    global Address, NetworkInfo,LastBlock,ISREADY,ChatID
    member = await bot.get_chat_member(call.message.chat.id, call["from"].id)
    if member.is_chat_admin():
        await bot.delete_message(call.message.chat.id, call.message.message_id)
        en_options_kb = ForceReply()
        NetworkInfo=Main["Network"][str(call.data)]
     
        await Form.One.set()
        await bot.send_message(call.message.chat.id, "Send me, Wallet Address",reply_markup = en_options_kb)
       
@dp.message_handler(lambda message: len(message.text) != 42 or message.text[:2] != "0x", state=Form.One)
async def handlerTwo(message: types.Message):
    await message.reply("Invalid Wallet Address")
    
    en_options_kb = ForceReply()
    await bot.send_message(message.chat.id, "Send me, Wallet Address",reply_markup = en_options_kb)


@dp.message_handler(lambda message: len(message.text) ==
                   42 and message.text[:2] == "0x", state=Form.One)
async def TypeOptionThree(message: types.Message, state: FSMContext):
    global Address, NetworkInfo,LastBlock,ISREADY,ChatID
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        ISREADY=True
        Address=message.text
        LastBlock= getBlockNumber(NetworkInfo["Provider"])
        Main["Telegram"]["Address"]=Address
        Main["Telegram"]["LastBlock"]=LastBlock
        Main["Telegram"]["NetworkInfo"]=NetworkInfo
        Main["Telegram"]["ChatID"]=ChatID
        json.dump(Main, open("conf.json",'w'))
        await message.reply("Okey All of them is setted")
        await state.finish()
        
       



loop = asyncio.get_event_loop()
tasks = [loop.create_task(Checker()),loop.create_task(dp.start_polling())]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()






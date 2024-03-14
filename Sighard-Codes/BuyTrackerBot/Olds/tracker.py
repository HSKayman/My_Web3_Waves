from ast import parse
from xmlrpc.client import gzip_decode
from TxManager import AddManager, ApiManager
import logging
import requests
from telethon.sync import TelegramClient, Button
import asyncio
import nest_asyncio
from telethon import TelegramClient, events
import time
import json
from enum import Enum, auto
from aiogram.contrib.fsm_storage.memory import MemoryStorage
from aiogram.dispatcher import FSMContext
from aiogram.dispatcher.filters import Text
from aiogram.dispatcher.filters.state import State, StatesGroup
from aiogram import Bot, Dispatcher, executor, types
from aiogram.types import ReplyKeyboardMarkup, ForceReply, KeyboardButton
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton

from requests import *

import os
from dotenv import load_dotenv

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO)
LOGGER = logging.getLogger(__name__)


load_dotenv()



class Form(StatesGroup):
    getTokenAddress = State()  
    getTokenAddress2 = State()  
    addButtonAds = State()
    addAds = State()


conversation_state = {}

nest_asyncio.apply()


def stringControl(message):

    errorMessage = ""
    flag = False
    if message[0] != 'eth' and message[0] != 'bsc':
        flag = True
        errorMessage += "Unsported Chain\n"
    if int(message[1]) < 0 or int(message[1]) > 3:
        flag = True
        errorMessage += "Wrong Tracker Type\n"
    if int(message[1]) == 0 or int(message[1]) == 3:
        if int(len(message)) != 3:
            flag = True
            errorMessage += "Please check input and try again (entered too little or too much)\n"
        else:

            if (len(message[2]) != 42):
                flag = True
                errorMessage += "Invalid Token Address\n"
    if int(message[1]) > 0 and int(message[1]) != 3:
        if int(len(message)) != 4:
            flag = True
            errorMessage += "Please check input and try again\n"
        else:
            if (len(message[2]) != 42):
                flag = True
                errorMessage += "Invalid Token Address\n"
            if (len(message[3]) != 42):
                flag = True
                errorMessage += "Invalid PreSale Address\n"
    return (flag, errorMessage)


def init():
    global bot, dp, BOT_TOKEN, ISTART,  MASTERMANAGER,  ADDMANAGER,  APIMANAGER,  ISTOP,  ISBUSY, ALCHMENYKEY, BSCAPIKEY, ETHAPIKEY
    ISTART = False
    ISTOP = False
    ISBUSY = False

    ALCHMENYKEY = os.getenv("ALCHMENYKEY")
    BSCAPIKEY = os.getenv("BNBAPIKEY")
    ETHAPIKEY = os.getenv("ETHAPIKEY")

    BOT_TOKEN = os.getenv("BOT_TOKEN")

    storage = MemoryStorage()
    bot = Bot(token=BOT_TOKEN, parse_mode=types.ParseMode.HTML)
    dp = Dispatcher(bot, storage=storage)

    ADDMANAGER = AddManager()
    APIMANAGER = ApiManager()
    MASTERMANAGER = os.getenv("MASTERMANAGER")


init()
#  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#  Checker
#  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
logf = open("error.log", "a")
logf.close()


async def Checker():
    global ISBUSY

    while True:
        try:
            print("Waiting")
            await asyncio.sleep(10)
            if ISTART == True and ISTOP == False:
                for chats in APIMANAGER.APIS:
                    print("Checking")
                    if APIMANAGER.isReady(chats):
                        print("Ready")
                        try:
                            BuyOperations = APIMANAGER.getText(chats)
                            for textMessage in BuyOperations:
                                await asyncio.sleep(3)
                                print("Sending")
                                textMessages = textMessage
                                Adds = ADDMANAGER.getRandomAdds()
                                textMessages += Adds[0][0]
                                ISBUSY = True
                                _url = 'https://api.telegram.org/bot{0}/{1}'.format(
                                    BOT_TOKEN, "sendDocument")
                                _data = {'chat_id': chats,
                                         'document': 'https://media1.giphy.com/media/uFtywzELtkFzi/giphy.gif?cid=ecf05e47c09tjs9rucnyje673txuni8nl2oc2qit2177x8h4&rid=giphy.gif&ct=g',
                                         'caption': textMessages,
                                         'parse_mode': 'HTML',
                                         'reply_markup': json.dumps({"inline_keyboard": [[{"text": Adds[1][0], "url": Adds[1][1]}]]})}

                                response = requests.post(
                                    url=_url, data=_data).json()

                                if 'description' in response:
                                    if response['description'] == 'Bad Request: chat not found' or response['description'] == 'Forbidden: bot was kicked from the supergroup chat':
                                        APIMANAGER.removeChat(chats)
                                        ISBUSY = False
                                        break
                                print(response)
                                ISBUSY = False
                                await asyncio.sleep(5)
                        except Exception as e:
                            logf = open("error.log", "a")
                            logf.write("\nE1 "+str(e))
                            logf.close()
                            print("E1", e)

                    else:
                        print("Waiting for the next update")

        except Exception as e:
            logf = open("error.log", "a")
            logf.write("\nE2 "+str(e))
            logf.close()
            print("E2", e)


# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # TOKEN
# # ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@dp.message_handler(commands=['add_token'])
async def addToken(message: types.Message):
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        button1 = InlineKeyboardButton(text="BSC", callback_data="BSC")
        button2 = InlineKeyboardButton(text="ETH", callback_data="ETH")
        keyboard_inline = InlineKeyboardMarkup().add(button1, button2)
        await message.reply("<b>Select Network:</b>", reply_markup=keyboard_inline)
    else:
        await message.reply("You are not an admin of this group.")


@dp.callback_query_handler(text=["BSC", "ETH"])
async def TypeOption(call: types.CallbackQuery):
    member = await bot.get_chat_member(call.message.chat.id, call["from"].id)
    if member.is_chat_admin():
        await bot.delete_message(call.message.chat.id, call.message.message_id)
        if call.data == "BSC":
            conversation_state[call["from"].id]=[]            
            conversation_state[call["from"].id].append("BSC")
            button1 = InlineKeyboardButton(text="TOKEN", callback_data="BSC-T")
            button2 = InlineKeyboardButton(
                text="PRESALE", callback_data="BSC-P")
            button3 = InlineKeyboardButton(
                text="FAIRLAUNCH", callback_data="BSC-F")
            button4 = InlineKeyboardButton(
                text="PRIVATESALE", callback_data="BSCP-R")
            keyboard_inline = InlineKeyboardMarkup().add(button1, button2, button3, button4)
            await bot.send_message(call.message.chat.id, "<b>Select Token Type:</b>", reply_markup=keyboard_inline)
        elif call.data == "ETH":
            conversation_state[call["from"].id]=[]            
            conversation_state[call["from"].id].append("ETH")
            button1 = InlineKeyboardButton(text="TOKEN", callback_data="ETH-T")
            button2 = InlineKeyboardButton(
                text="PRESALE", callback_data="ETH-P")
            button3 = InlineKeyboardButton(
                text="FAIRLAUNCH", callback_data="ETH-F")
            button4 = InlineKeyboardButton(
                text="PRIVATESALE", callback_data="ETHP-R")
            keyboard_inline = InlineKeyboardMarkup().add(button1, button2, button3, button4)
            await bot.send_message(call.message.chat.id, "<b>Select Token Type:</b>", reply_markup=keyboard_inline)


@dp.callback_query_handler(text=["ETH-T", "ETH-P", "ETH-F", "ETH-R", "BSC-T", "BSC-P", "BSC-F", "BSCP-R"])
async def TypeOptionTwo(call: types.CallbackQuery, state: FSMContext):
    member = await bot.get_chat_member(call.message.chat.id, call["from"].id)
    if member.is_chat_admin():
        chat_id = call.message.chat.id
        await bot.delete_message(chat_id, call.message.message_id)

       
        conversation_state[call["from"].id].append(call.data)
        en_options_kb = ForceReply()
        await Form.getTokenAddress.set()

        if call.data[-1] == "R":
            await bot.send_message(call.message.chat.id, "Send me, Set PrivateSale Address",reply_markup = en_options_kb)
        else:
            await bot.send_message(call.message.chat.id, "Send me, Set Token Address",reply_markup = en_options_kb)

@dp.message_handler(lambda message: len(message.text) != 42 or message.text[:2] != "0x", state=Form.getTokenAddress)
async def contractAddress1(message: types.Message):
    return await message.reply("Invalid Contract Address")

@dp.message_handler(lambda message: len(message.text) ==
                   42 and message.text[:2] == "0x", state=Form.getTokenAddress)
async def process_firstContract(message: types.Message, state: FSMContext):
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        if (conversation_state[message.from_user.id][-1][-1]=="R" or conversation_state[message.from_user.id][-1][-1]=="T"):
            elements = [conversation_state[message.from_user.id][-2],conversation_state[message.from_user.id][-1],message.text]
            chain = {"ETH": 1, "BSC": 56}
            tokentype = {"T": 0, "R": 3}
            if chain[elements[0]] == 1:
                await bot.send_message(message.chat.id, "You set <a>https://etherscan.com/address/"+message.text+"</a> as Contract Address")
                APIMANAGER.addChat(message.chat.id, message.text,  ETHAPIKEY,
                                    chain[elements[0]], tokentype[elements[1][-1]], alchemy=ALCHMENYKEY)
            else:
                await bot.send_message(message.chat.id, "You set <a>https://bscscan.com/address/"+message.text+"</a> as Contract Address")
                APIMANAGER.addChat(message.chat.id, message.text,
                                    BSCAPIKEY, chain[elements[0]], tokentype[elements[1][-1]])
                await bot.send_message(message.chat.id, str(elements))
            await state.finish()
            del conversation_state[message.from_user.id]
        else:
            conversation_state[message.from_user.id].append(message.text)
            await Form.next()
            en_options_kb = ForceReply()
            if conversation_state[message.from_user.id][-2][-1] == "P":
                await bot.send_message(message.chat.id, "Send me, Set Presale Address",reply_markup = en_options_kb)
            else:
                await bot.send_message(message.chat.id, "Send me, Set FairLaunch Address",reply_markup = en_options_kb)
        #   await event.respond('Set to <b>Network</b>: {} \n<b>Token:{}</b> thanks. LFG 🚀'.format(elements[0],elements[2]), parse_mode='HTML')


@dp.message_handler(lambda message: len(message.text) != 42 or message.text[:2] != "0x", state=Form.getTokenAddress2)
async def contractAddress2(message: types.Message):
    return await message.reply("Invalid Contract Address Please Try Again")


@dp.message_handler(lambda message: len(message.text) == 42 and message.text[:2] == "0x", state=Form.getTokenAddress2)
async def process_secondContract(message: types.Message, state: FSMContext):
    # Update state and data
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        elements = [conversation_state[message.from_user.id][-3],conversation_state[message.from_user.id][-2],conversation_state[message.from_user.id][-1],message.text]
        chain = {"ETH": 1, "BSC": 56}
        tokentype = { "P": 1, "F": 2}
        if chain[elements[0]] == 1:
            APIMANAGER.addChat(message.chat.id, elements[2],  ETHAPIKEY, chain[elements[0]],
                                tokentype[elements[1][-1]],elements[3], alchemy=ALCHMENYKEY)
            await bot.send_message(message.chat.id, str(elements))
        else:
            APIMANAGER.addChat(
                message.chat.id, elements[2],  BSCAPIKEY, chain[elements[0]], tokentype[elements[1][-1]],elements[3])
            await bot.send_message(message.chat.id, str(elements))
        await state.finish()
        del conversation_state[message.from_user.id]
        return

# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADD ADS
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

@dp.message_handler(commands=['add_ads'])
async def addAds(message: types.Message):
    if str(message.from_user.id) == str(MASTERMANAGER):
        await message.reply("Send me, Set Ads Message")
        await Form.addAds.set()
    else:
        await message.reply("Only KingBuyBot creator call this command.")

@dp.message_handler(state=Form.addAds)
async def process_addAds(message: types.Message, state: FSMContext):
    # Update state and data
    if str(message.from_user.id) == str(MASTERMANAGER):
        print(message.text)
        elements = message.text.split("&")
        ADDMANAGER.addNormalAdd(elements[0],  elements[1])
        await message.reply("You set <b>"+message.text+"</b> as Ads Message", parse_mode='HTML')
        await state.finish()
        return
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADD BUTTON ADS
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@dp.message_handler(commands=['add_button_ads'])
async def addButtonAds(message: types.Message):
    if str(message.from_user.id) == str(MASTERMANAGER):
        await message.reply("Send me, Set Ads Message")
        await Form.addButtonAds.set()                                                      
    else:
        await message.reply("Only KingBuyBot creator call this command.")

@dp.message_handler(state=Form.addButtonAds)
async def process_addButtonAds(message: types.Message, state: FSMContext):
    # Update state and data
    if str(message.from_user.id) == str(MASTERMANAGER):
        elements = message.text.split("&")
        ADDMANAGER.AddButtonAdd(elements[0],  elements[1])
        await message.reply("You set <b>"+message.text+"</b> as Ads Message", parse_mode='HTML')
        await state.finish()
        return
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADDS INFO
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------


@dp.message_handler(commands=['ads_info'])
async def adsInfo(message: types.Message):
    text = "🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢\n 👤 <b>Buyer Position</b> New \n 🤑 Got: 417,274,404,972.33 Example Token \n 💵 Spent: 0.11831 BNB ($32.8434294) \n 💲 Price/Token: $0.07870943 \n 🚨DEX: PancakeSwap \n ⏳ Time: 18:13:55 09/10/2022 \n "
    text += "<a href='{https://example.com/}'>👁‍🗨 TX</a> | <a href= '{https://example.com/}'>📊 Chart</a> | <a href= '{https://example.com/}'>💱 Buy</a>\n\n"
    text += f"<b>🚀 Ad's:</b> <b>Ads your project📞</b> \n\n\n"
    text += "<b>🎯 Ads run for 24 hours</b> \n<b>🎯 Rotate Ads 3 slots and Button Ads Option</b> \n<b>🎯 Token</b>\n<b>🎯 PrivateSale</b>\n<b>🎯 Fairlaunch</b>\n<b>🎯 Presale</b> \n\n <b>Current daily ad rates:</b> \n\n - Eth: <b>0.20 ETH</b> for Link ad’s\n <b>0.40 ETH</b> for Button Ad's\n- BNB: <b>1 BNB</b> for Link Ad’s\n <b>2 BNB</b> for Button ad’s \n\n"
    text += "If you want to advertise your project, please contact <b>@CryptechKing</b>"
    button = InlineKeyboardButton(
        text="Advertise your project here 📞", url="https://t.me/CrypTechKing")
    keyboard_inline = InlineKeyboardMarkup().add(button)
    await message.reply(text, reply_markup=keyboard_inline)

# how to send gif
# await bot.send_animation(chat_id, animation, caption=None, parse_mode=None, disable_notification=None, reply_to_message_id=None,
# reply_markup=None, timeout=None, thumb=None, width=None, height=None, duration=None, supports_streaming=None, parse_mode=None)

# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # TOKEN INFO
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@dp.message_handler(commands=['token_info'])
async def tokenInfo(message: types.Message):
    if str(message.chat.id) in APIMANAGER.APIS:
        text = "{}".format(APIMANAGER.APIS[str(message.chat.id)].getInfo())
        await message.reply(text)
    else:
        await message.reply(message.chat.id, "No token set.",  parse_mode='HTML')

# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # START
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@dp.message_handler(commands=['start'])
async def start(message: types.Message):
    if str(message.from_user.id) == str(MASTERMANAGER):
        global ISTART
        ISTART = True
        await message.reply("Bot Started Wait...")
    else:
        await message.reply("Only KingBuyBot creator call this command.")

# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # HELP
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@dp.message_handler(commands=['help'])
async def help(message: types.Message):
    await message.reply("ℹ️ℹ️ℹ️ℹ️ℹ️\n<b>Bot need to be admin</b> \n\n - If you would like to info about bot commands, please use <b>/commands</b> \n\n- If you would like to add a token, please use <b>/add_token</b> in your group chat <b>(group admins only)</b> \n\n- If you would like to change a tokens settings, please use again <b>/add_token</b> in your group chat <b>(group admins only).</b> <b>This will override.</b>\n\n- If you would like information on advertising , please use <b>/ads_info</b> \n\n- If you would like information on token , please use <b>/token_info</b> \n\nThanks!  🚀 ")

# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # COMMANDS
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@dp.message_handler(commands=['commands'])
async def welcome(message: types.Message):
    await message.reply("ℹ️ℹ️ℹ️ℹ️ℹ️\n<b>Bot need to be admin</b> \n\n - If you would like to info about bot commands, please use <b>/commands</b> \n\n- If you would like to add a token, please use <b>/add_token</b> in your group chat <b>(group admins only)</b> \n\n- If you would like to change a tokens settings, please use again <b>/add_token</b> in your group chat <b>(group admins only).</b> <b>This will override.</b>\n\n- If you would like information on advertising , please use <b>/ads_info</b> \n\n- If you would like information on token , please use <b>/token_info</b> \n\nThanks!  🚀 ")

executor.start_polling(dp)

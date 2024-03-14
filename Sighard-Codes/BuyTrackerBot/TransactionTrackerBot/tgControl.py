from ast import parse
from xmlrpc.client import gzip_decode
from Manager import *
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
    getTokenAddressForRemove = State()
    addButtonAds = State()
    addAds = State()


conversation_state = {}

nest_asyncio.apply()


def init():
    global bot, dp, BOT_TOKEN, ISTART,  MASTERMANAGER, CHATS, ADDMANAGER




    BOT_TOKEN = os.getenv("BOT_TOKEN")

    CHATS = ChatMngr
    ADDMANAGER = AddMngr

    storage = MemoryStorage()
    bot = Bot(token=BOT_TOKEN, parse_mode=types.ParseMode.HTML)
    dp = Dispatcher(bot, storage=storage)

    MASTERMANAGER = os.getenv("MASTERMANAGER")


init()
# --------------
# AD'S INFO
# --------------
@dp.message_handler(commands=['ads_info'])
async def adsInfo(message: types.Message):
    text = "bla bla"
    button = InlineKeyboardButton(
        text="bla bla", url="https://t.me/CrypTechKing")
    keyboard_inline = InlineKeyboardMarkup().add(button)
    await message.reply(text, reply_markup=keyboard_inline)

# --------------
# HELP
# --------------
@dp.message_handler(commands=['help'])
async def help(message: types.Message):
    await message.reply("bla bla")

# --------------
# TOKEN_INFO
# --------------
@dp.message_handler(commands=['token_info'])
async def tokenInfo(message: types.Message):
    chat = ChatMngr.get_chat(str(message.chat.id))
    if chat is not None:
        events=chat.getInformation()
        for event in events:
            await message.reply(event)
            await asyncio.sleep(1)
   

# --------------
# START
# --------------
@dp.message_handler(commands=['start'])
async def start(message: types.Message):
    if str(message.from_user.id) == str(MASTERMANAGER):
        global ISTART
        ISTART = True
        await message.reply("Bot Started Wait...")
    else:
        await message.reply("Only KingBuyBot creator call this command.")


# --------------
# ADD TOKEN
# --------------
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
            conversation_state[call["from"].id] = []
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
            conversation_state[call["from"].id] = []
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
            await bot.send_message(call.message.chat.id, "Send me, Set PrivateSale Address", reply_markup=en_options_kb)
        else:
            await bot.send_message(call.message.chat.id, "Send me, Set Token Address", reply_markup=en_options_kb)

@dp.message_handler(lambda message: len(message.text) != 42 or message.text[:2] != "0x", state=Form.getTokenAddress)
async def contractAddress1(message: types.Message):
    return await message.reply("Invalid Contract Address")

@dp.message_handler(lambda message: len(message.text) ==
                        42 and message.text[:2] == "0x", state=Form.getTokenAddress)
async def process_firstContract(message: types.Message, state: FSMContext):
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        if (conversation_state[message.from_user.id][-1][-1] == "R" or conversation_state[message.from_user.id][-1][-1] == "T"):
            elements = [conversation_state[message.from_user.id][-2],
                        conversation_state[message.from_user.id][-1], message.text]
            chain = {"ETH": 1, "BSC": 56}
            tokentype = {"T": 0, "R": 3}
            if chain[elements[0]] == 1:
                await bot.send_message(message.chat.id, "You set <a>https://etherscan.com/address/"+message.text+"</a> as Contract Address")
                CHATS.addChat(message.chat.id, message.text,  ETHAPIKEY,
                                   chain[elements[0]], tokentype[elements[1][-1]], alchemy=ALCHMENYKEY)
            else:
                await bot.send_message(message.chat.id, "You set <a>https://bscscan.com/address/"+message.text+"</a> as Contract Address")
                CHATS.addChat(message.chat.id, message.text,
                                   BSCAPIKEY, chain[elements[0]], tokentype[elements[1][-1]])
                await bot.send_message(message.chat.id, str(elements))
            await state.finish()
            del conversation_state[message.from_user.id]
        else:
            conversation_state[message.from_user.id].append(message.text)
            await Form.next()
            en_options_kb = ForceReply()
            if conversation_state[message.from_user.id][-2][-1] == "P":
                await bot.send_message(message.chat.id, "Send me, Set Presale Address", reply_markup=en_options_kb)
            else:
                await bot.send_message(message.chat.id, "Send me, Set FairLaunch Address", reply_markup=en_options_kb)

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
            CHATS.addChat(message.chat.id, elements[2],  ETHAPIKEY, chain[elements[0]],
                                tokentype[elements[1][-1]],elements[3], alchemy=ALCHMENYKEY)
            await bot.send_message(message.chat.id, str(elements))
        else:
            CHATS.addChat(
                message.chat.id, elements[2],  BSCAPIKEY, chain[elements[0]], tokentype[elements[1][-1]],elements[3])
            await bot.send_message(message.chat.id, str(elements))
        await state.finish()
        del conversation_state[message.from_user.id]
        return
# --------------
# REMOVE TOKEN
# --------------
@dp.message_handler(commands=['remove_token'])
async def removeToken(message: types.Message):
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        await message.reply("Enter the token address you want to remove:")
        await Form.getTokenAddressForRemove.set()
    else:
        await message.reply("You are not an admin of this group.")

@dp.message_handler(state=Form.getTokenAddressForRemove)
async def removeTokenAddress(message: types.Message, state: FSMContext):
    member = await bot.get_chat_member(message.chat.id, message.from_user.id)
    if member.is_chat_admin():
        if len(message.text) == 42:
            if CHATS.remove_chat(message.chat.id, message.text):
                await message.reply("Token removed successfully.")
            else:
                await message.reply("Token not found.")
        else:
            await message.reply("Invalid token address.")
    else:
        await message.reply("You are not an admin of this group.")
    await state.finish()


executor.start_polling(dp)

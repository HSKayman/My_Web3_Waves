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

import os
from dotenv import load_dotenv

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO)
LOGGER = logging.getLogger(__name__)


load_dotenv()


class State(Enum):
    IDLE = auto()
    # CONTRACT AND LP ADDRESS
    WAITING_FOR_CONTRACT_ADDRESS_STEP_1 = auto()
    WAITING_FOR_CONTRACT_ADDRESS_STEP_2 = auto()
    # ADS
    WAITING_FOR_ADS_STEP_1 = auto()
    WAITING_FOR_ADS_STEP_2 = auto()
    # BUTTON
    WAITING_FOR_ADSBUTTON_STEP_1 = auto()
    WAITING_FOR_ADSBUTTON_STEP_2 = auto()



conversation_state = {}

nest_asyncio.apply()

def stringControl(message):

    errorMessage=""
    flag=False
    if message[0]!='eth' and message[0]!='bsc':
        flag=True
        errorMessage+="Unsported Chain\n"
    if int(message[1])<0 or int(message[1]) > 3:
        flag=True
        errorMessage+="Wrong Tracker Type\n"
    if int(message[1])==0 or int(message[1])==3:
        if int(len(message))!=3:
            flag=True
            errorMessage+="Please check input and try again (entered too little or too much)\n"
        else:
            
            if(len(message[2])!=42):
                flag=True
                errorMessage+="Invalid Token Address\n"
    if int(message[1])>0 and int(message[1])!=3:
        if int(len(message))!=4:
            flag=True
            errorMessage+="Please check input and try again\n"
        else:
            if(len(message[2])!=42):
                flag=True
                errorMessage+="Invalid Token Address\n"
            if(len(message[3])!=42):
                flag=True
                errorMessage+="Invalid PreSale Address\n"
    return (flag,errorMessage)

        

def init():
    global UNMARSHAL_API_KEY, BOT, BOT_TOKEN, ISTART,  MASTERMANAGER,  ADDMANAGER,  APIMANAGER,  ISTOP,  ISBUSY, ALCHMENYKEY,BSCAPIKEY,ETHAPIKEY
    ISTART = True
    ISTOP = False
    ISBUSY = False

    ALCHMENYKEY = os.getenv("ALCHMENYKEY")
    BSCAPIKEY = os.getenv("BNBAPIKEY")
    ETHAPIKEY = os.getenv("ETHAPIKEY")

    BOT_TOKEN = os.getenv("BOT_TOKEN")
    API_KEY = os.getenv("API_KEY")    
    API_HASH = os.getenv("API_HASH")
    BOT =  TelegramClient("King Buy Bot",  API_KEY,API_HASH).start(bot_token=BOT_TOKEN)
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
            if ISTART == True and ISTOP  ==  False:
                for chats in APIMANAGER.APIS:
                    print("Checking")
                    await asyncio.sleep(3)
                    if APIMANAGER.isReady(chats):
                        print("Ready")
                        try:
                            BuyOperations  = APIMANAGER.getText(chats)   
                            for textMessage in BuyOperations:
                                await asyncio.sleep(3)
                                print("Sending")
                                textMessages = textMessage
                                Adds  =  ADDMANAGER.getRandomAdds()
                                textMessages  +=  Adds[0][0]
                                
                                ISBUSY  =  True
                                _url='https://api.telegram.org/bot{0}/{1}'.format(BOT_TOKEN, "sendDocument")
                                
                                _data={'chat_id': chats,
                                'document': 'https://media1.giphy.com/media/uFtywzELtkFzi/giphy.gif?cid=ecf05e47c09tjs9rucnyje673txuni8nl2oc2qit2177x8h4&rid=giphy.gif&ct=g',
                                'caption': textMessages,
                                'parse_mode': 'HTML',
                                'reply_markup':json.dumps({ "inline_keyboard": [[{"text": Adds[1][0], "url": Adds[1][1]}]]}) }
                                
                                response = requests.post(url=_url,data=_data).json()
                                await asyncio.sleep(5)
                                if 'description' in response:
                                    if response['description']=='Bad Request: chat not found' or response['description']=='Forbidden: bot was kicked from the supergroup chat':  
                                        APIMANAGER.removeChat(chats)
                                        ISBUSY  =  False
                                        break                                      
                                print(response)
                                ISBUSY  =  False
                                await asyncio.sleep(1)
                        except Exception as e:
                            logf = open("error.log", "a")
                            logf.write("\nE1 "+str(e))
                            logf.close()
                            print("E1",e)
                            
                    else:
                        print("Waiting for the next update")

        except Exception as e:
            logf = open("error.log", "a")
            logf.write("\nE2 "+str(e))
            logf.close()
            print("E2",e)

#  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage)
async def handler(event):
    permissions = await BOT.get_permissions(event.chat_id, int(event.sender_id))
    if str(event.sender_id) ==  str(MASTERMANAGER):
        who = event.sender_id
        state = conversation_state.get(who)

        if state is State.WAITING_FOR_ADS_STEP_1:
            ISTOP  =  True
            await event.reply("Send me the Ad's\n<b>For Example: TestCoin new listing 5PM UTC & testxyz.com</b>", parse_mode='HTML')
            conversation_state[who] = State.WAITING_FOR_ADS_STEP_2

        elif state == State.WAITING_FOR_ADS_STEP_2:

            if len(str(event.message.message).split('&'))  !=  2:
                await event.reply(("Wrong input!\n<b>Please use...</b> For Example: <b>TestCoin new listing 5PM UTC & testxyz.com</b>"), parse_mode='HTML')
            else:
                elements  =  str(event.message.message).split('&')
                ADDMANAGER.addNormalAdd(elements[0],  elements[1])
                await event.reply('Set to Ads:\n<b>{}</b> \n <b>{}</b>  thanks.'.format(elements[0],  elements[1]), parse_mode='HTML')
                conversation_state[who]  =  State.IDLE
                ISTOP  =  False

        elif state is State.WAITING_FOR_ADSBUTTON_STEP_1:
            ISTOP  =  True
            await event.reply("Send me the Button Ad's\n<b>For Example: TestCoin new listing 5PM UTC & testxyz.com</b>", parse_mode='HTML')
            conversation_state[who] = State.WAITING_FOR_ADSBUTTON_STEP_2

        elif state == State.WAITING_FOR_ADSBUTTON_STEP_2:
            if len(str(event.message.message).split('&'))  !=  2:
                await event.reply(("Wrong input!\n<b>Please use...</b> For Example: <b>TestCoin new listing 5PM UTC & testxyz.com</b>"), parse_mode='HTML')
            else:
                elements  =  str(event.message.message).split('&')
                ADDMANAGER.AddButtonAdd(elements[0],  elements[1])
                await event.reply('Set to Button Ads:\n<b>{}</b> \n <b>{}</b> thanks.'.format(elements[0],  elements[1]), parse_mode='HTML')
                conversation_state[who]  =  State.IDLE
                ISTOP  =  False

    elif permissions.is_admin:
        who = event.sender_id
        state = conversation_state.get(who)

        if state is State.WAITING_FOR_CONTRACT_ADDRESS_STEP_1:
            await event.reply("ℹ️ℹ️ℹ️<b>\nChainName(bsc,eth)\n\n0(Token)\n1(Presale)\n2(FairLaunch)\n3(PrivateSale)</b>\n\n<b>For Example</b>\n\nℹ️ℹ️ℹ️\n<b>TOKEN Monitoring</b>\nbsc 0 tokenAddress\neth 0 tokenAddress\n---\n<b>PRESALE Monitoring</b>\nbsc 1 tokenAdress presaleAddres\neth 1 tokenAdress presaleAddres\n---\n<b>FAIRLAUNCH Monitoring</b>\nbsc 2 tokenAddress fairlaunchAddress\neth 2 tokenAddress fairlaunchAddress\n---\n<b>PRIVATE SALE Monitoring</b>\nbsc 3 privateSaleAddress\neth 3 privateSaleAddress\n---\netc...",parse_mode='HTML')
            await event.reply("Please send me the contract address", parse_mode='HTML')
            
            #Choose Type

            conversation_state[who] = State.WAITING_FOR_CONTRACT_ADDRESS_STEP_2

        elif state == State.WAITING_FOR_CONTRACT_ADDRESS_STEP_2:
            chat_id = event.chat_id
            strings=str(event.message.message).split(' ') 
            flag, errorMessage = stringControl(strings)
            if flag:
               await event.reply(("Wrong!!\n"+errorMessage), parse_mode='HTML')
            else:
                elements  =  str(event.message.message).split(' ')
     
#                # !elements (chainName,
#                #    !Type[
#                #        !0(Token),
#                #        !1(PreSale),
#                #        !2(FairLaunch),
#                #        !3(PrivateSale)],
#                #    !Token Address
#                #    !Optinal PreSale Fairlaunch PrivateSale Address)
               
                types={1:"PreSale",2:"FairLaunch",3:"PrivateSale"}
                if(elements[0]=='eth'): #eth
                    if(int(elements[1])>0 and int(elements[1])!=3):
                        APIMANAGER.addChat(chat_id, elements[2],  ETHAPIKEY, 1, elements[1],routerOrPair=elements[3],alchemy=ALCHMENYKEY)
                        
                        await event.respond('Set to <b>Network</b>: {} \n<b>Token</b>: {} \n<b>{}</b>: {} thanks. LFG 🚀'.format(elements[0],elements[2],types[int(elements[1])],elements[3]), parse_mode='HTML')
                    else:
                        APIMANAGER.addChat(chat_id, elements[2],  ETHAPIKEY, 1, elements[1],alchemy=ALCHMENYKEY)
                        await event.respond('Set to <b>Network</b>: {} \n<b>Token:{}</b> thanks. LFG 🚀'.format(elements[0],elements[2]), parse_mode='HTML')
                else: #bsc
                    
                    if(int(elements[1])>0 and int(elements[1])!=3):
                        APIMANAGER.addChat(chat_id, elements[2],  BSCAPIKEY, 56, elements[1],elements[3])
                        await event.respond('Set to <b>Network</b>: {} \n<b>Token</b>: {} \n<b>{}</b>: {} thanks. LFG 🚀'.format(elements[0],elements[2],types[int(elements[1])],elements[3]), parse_mode='HTML')
                    else:
                        APIMANAGER.addChat(chat_id, elements[2],  BSCAPIKEY, 56, elements[1])
                        await event.respond('Set to <b>Network</b>: {} \n<b>Token:{}</b> thanks. LFG 🚀'.format(elements[0],elements[2]), parse_mode='HTML')

                conversation_state[who]  =  State.IDLE
            
                



# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ALL COMMANDS
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADD TOKEN
@BOT.on(events.NewMessage(pattern='/add_token'))
async def addToken(event):
    permissions = await BOT.get_permissions(event.chat_id, int(event.sender_id))
    if permissions.is_admin and ISBUSY  ==  False:
        conversation_state[event.sender_id] = State.WAITING_FOR_CONTRACT_ADDRESS_STEP_1
        await handler(event)
    elif permissions.is_admin:
        await event.reply("Please wait for the next update.",  parse_mode='HTML')
    else:
        await event.reply("You are not an admin of this group.",  parse_mode='HTML')

# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADD ADS
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage(pattern='/add_ads'))
async def addAds(event):
    if str(event.sender_id) ==  str(MASTERMANAGER) and ISBUSY  ==  False:
        conversation_state[event.sender_id] = State.WAITING_FOR_ADS_STEP_1
        await handler(event)
    elif str(event.sender_id) ==  str(MASTERMANAGER):
        await event.reply("Please wait for the next update.",  parse_mode='HTML')
    else:
        await event.reply("Only KingBuyBot creator call this command.",  parse_mode='HTML')
        
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADD BUTTON ADS
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage(pattern='/add_button_ads'))
async def addButtonAds(event):

    if str(event.sender_id) ==  str(MASTERMANAGER) and ISBUSY  ==  False:
        conversation_state[event.sender_id] = State.WAITING_FOR_ADSBUTTON_STEP_1
        await handler(event)
    elif str(event.sender_id) ==  str(MASTERMANAGER):
        await event.reply("Please wait for the next update.",  parse_mode='HTML')
    else:
        await event.reply("Only KingBuyBot creator call this command.",  parse_mode='HTML')

# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADS INFO
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage(pattern='/ads_info'))
async def adsInfo(event):

    text2 = "🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢\n 👤 <b>Buyer Position</b> New \n 🤑 Got: 417,274,404,972.33 Example Token \n 💵 Spent: 0.11831 BNB ($32.8434294) \n 💲 Price/Token: $0.07870943 \n 🚨DEX: PancakeSwap \n ⏳ Time: 18:13:55 09/10/2022 \n "
    text2 += "<a href='{https://example.com/}'>👁‍🗨 TX</a> | <a href= '{https://example.com/}'>📊 Chart</a> | <a href= '{https://example.com/}'>💱 Buy</a>\n\n"
    text2 += f"<b>🚀 Ad's:</b> <b>Ads your project📞</b> \n\n\n"
    text2 += "<b>🎯 Ads run for 24 hours</b> \n<b>🎯 Rotate Ads 3 slots and Button Ads Option</b> \n<b>🎯 Token</b>\n<b>🎯 PrivateSale</b>\n<b>🎯 Fairlaunch</b>\n<b>🎯 Presale</b> \n\n <b>Current daily ad rates:</b> \n\n - Eth: <b>X ETH</b> (Paid via Ethereum Network) \n- BNB: <b>X BNB</b> (Paid via the BSC Network)\n\n"
    text2 += "If you want to advertise your project, please contact <b>@CryptechKing</b>"
    keyboard2 = [[Button.url('Advertise your project here 📞', "https://t.me/CrypTechKing")]]

    await BOT.send_file(event.chat_id, 'https://media1.giphy.com/media/uFtywzELtkFzi/giphy.gif?cid=ecf05e47c09tjs9rucnyje673txuni8nl2oc2qit2177x8h4&rid=giphy.gif&ct=g', caption=text2, parse_mode='HTML', buttons=keyboard2)
    raise events.StopPropagation

# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # ADS INFO
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage(pattern='/token_info'))  #Token Info 
async def tokenInfo(event):    
    if str(event.chat_id) in APIMANAGER.APIS:        
        text ="<b>Token Addres: {}</b>".format(APIMANAGER.APIS[str(event.chat_id)].tokenAddress,  parse_mode='HTML')
        
        await event.reply(text,  parse_mode='HTML')
    else:
        await event.reply("No token set.",  parse_mode='HTML')
    raise events.StopPropagation

# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # START
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage(pattern='/start'))
async def start(event):
    if str(event.sender_id) ==  str(MASTERMANAGER):
        global ISTART
        ISTART  =  True
        await event.reply("Bot Started Wait...", parse_mode='HTML')
        raise events.StopPropagation
    else:
        await event.reply("Only KingBuyBot creator call this command.",  parse_mode='HTML')
        raise events.StopPropagation

# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # HELP
# # -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage(pattern='/help'))
async def help(event):
    await event.reply("ℹ️ℹ️ℹ️ℹ️ℹ️\n<b>Bot need to be admin</b> \n\n - If you would like to info about bot commands, please use <b>/commands</b> \n\n- If you would like to add a token, please use <b>/add_token</b> in your group chat <b>(group admins only)</b> \n\n- If you would like to change a tokens settings, please use again <b>/add_token</b> in your group chat <b>(group admins only).</b> <b>This will override.</b>\n\n- If you would like information on advertising , please use <b>/ads_info</b> \n\n- If you would like information on token , please use <b>/token_info</b> \n\nThanks!  🚀 ",  parse_mode='HTML')
    raise events.StopPropagation
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# # COMMANDS
# #  -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
@BOT.on(events.NewMessage(pattern='/commands'))
async def commands(event):

    await event.reply("ℹ️ℹ️ℹ️ℹ️ℹ️\n- <b>Bot need to be admin </b> \n\n- <b>/add_token</b> = If you would like to add a token <b>(group admin only)</b>\n\n- <b>/add_token</b> = If you would like to change a tokens settings  <b>This will override</b> <b>(group admin only)\n\n- <b>/ads_info</b> = If you would like information on advertising\n\n- <b>/add_ads</b> = <b>(Only bot Creator)</b> \n\n- <b>/add_button_ads</b> = <b>(Only bot Creator)</b> \n\n- <b>/start</b> = Start Bot <b>(Only bot Creator)</b> \n\n- <b>/help</b> = If you would like to info about @KingBuybot \n\n- If you would like information on token , please use <b>/token_info</b> \n\nThanks!  🚀 ",  parse_mode='HTML')
    raise events.StopPropagation


loop = asyncio.get_event_loop()
tasks = [loop.create_task(Checker()),loop.create_task(BOT.run_until_disconnected())]
loop.run_until_complete(asyncio.wait(tasks))
loop.close()

import json
import requests
import asyncio
from aiogram import Bot, Dispatcher
from aiogram.types import ParseMode
from aiogram.utils import executor
from datetime import datetime
import hashlib
import hmac
import random
import nest_asyncio
nest_asyncio.apply()
bot: Bot
dp: Dispatcher
channel_id: int
INTERVAL: int

async def startBot():
    while True:
        try:
            New=False
            for chain in networks:
                try:
                    randomChar = random.choices('qwertyuioplkjhgfdsazxcvbnmQWERTYUIOPLKJHGFDSAZXCVBNM')[0]
                    passwd = {"chainId":'{}'.format(chain),
                              "r": randomChar,
                              "h": hmac.new(SECRET, randomChar.encode('latin1'), hashlib.sha512).hexdigest()}

                    data=requests.post('https://project-cookie-api.contractchecker.app/pools',json =passwd )
                    cards=data.json()
                except Exception as e:
                    print('[E]1',e)
                    continue
                for card in cards:
                    if not "address" in card:
                        continue
                    elif card["address"] in printedList['address']:
                        continue
                    else:
                        New=True
                        
                    dictionary={}
                    if  card['typePresale']==0:
                        dictionary['Token Name']           =card['tokenName']+' ('+card['tokenSymbol']+')'
                        #dictionary['Telegram']             =card['links'][8]
                        dictionary['Token Address']        ="<a href='{}'>{}</a>".format(networklinks[chain]+card["tokenAddress"],card["tokenAddress"])
                        dictionary['Block Chain']          =networks[chain]
                        dictionary['Sale Type']            ='Pre-Sale'
                        dictionary['Soft/Hard Cap']        =card['softCap']+' / '+card['hardCap']
                        dictionary['Min/Max']              =str(card['minBuy'])+' / '+str(card['maxBuy'])
                        dictionary['Presale Rate']         ='1'+networkToken[chain]+' = '+card['presaleRate']+' '+card['tokenName']
                        dictionary['Liquidity']            =str(card['liquidityPercent'])+'%'
                        dictionary['Liquidity Lockup Time']=str(card['liquidityLockupTime'])+' days'
                        dictionary['Website']              =card['links'][0]
                        dictionary['Presale Time']         ='\n'+str(datetime.utcfromtimestamp(card['startTime']).strftime('%Y-%m-%d %H:%M:%S'))+ ' - '+str(datetime.utcfromtimestamp(card['endTime']).strftime('%Y-%m-%d %H:%M:%S'))+'\n'
                        dictionary['CookieSale Link:']     ='https://cookiesale.io/launchpad/'+card['address']+'?chain='+networks[chain]
                    else:
                        dictionary['Token Name']           =card['tokenName']+' ('+card['tokenSymbol']+')'
                        #dictionary['Telegram']             =card['links'][8]
                        dictionary['Token Address']        ="<a href='{}'>{}</a>".format(networklinks[chain]+card["tokenAddress"],card["tokenAddress"])
                        dictionary['Block Chain']          =networks[chain]
                        dictionary['Sale Type']            ='Fair Launch'
                        dictionary['Soft/Hard Cap']        =card['softCap']+' / '+card['hardCap']
                        dictionary['Min/Max']              =str(card['minBuy'])+' / '+str(card['maxBuy'])
                        dictionary['Presale Rate']         ='1'+networkToken[chain]+' = '+card['presaleRate']+' '+card['tokenName']
                        dictionary['Liquidity']            =str(card['liquidityPercent'])+'%'
                        dictionary['Liquidity Lockup Time']=str(card['liquidityLockupTime'])+' days'
                        dictionary['Website']              =card['links'][0]
                        dictionary['Presale Time']         ='\n'+str(datetime.utcfromtimestamp(card['startTime']).strftime('%Y-%m-%d %H:%M:%S'))+ ' - '+str(datetime.utcfromtimestamp(card['endTime']).strftime('%Y-%m-%d %H:%M:%S'))+'\n'
                        dictionary['CookieSale Link:']     ='https://cookiesale.io/launchpad/'+card['address']+'?chain='+networks[chain]
    
                    
                    message="" 
                    #print(message)
                    for key, value in dictionary.items():
                        if value=='':
                            continue
                        if key=='Presale Time':
                            message += f'\n <b>{key}</b> : {value} \n'
                        else:
                            message += f'<b>{key}</b> : {value} \n'
                    print(message)  
                    await bot.send_message(channel_id,message)
                    #await bot.send_photo(channel_id, card['links'][1],caption=message)
                    await asyncio.sleep(INTERVAL//40)
                    printedList['address'].append(card['address'])
        except Exception as e:
            print('[E]2',e)
        finally:
            if New:
                json.dump(printedList, open("log.bin",'w'))
            await asyncio.sleep(INTERVAL)
def init():
    

    global networks, networklinks, dp, INTERVAL, channel_id, bot, New, printedList, networkToken, SECRET
    New=False
    SECRET=b'8~)4kMfAr2@-gfAk_e=F]Q3qviZEmv]vJ?kAbRWqfFe@?RnN:N=wcB>WP+8.'
    channel_id='-1001672436278' #Channel
    #channel_id='-1001719756084' #Group
    #channel_id='-694620224' #Test
    INTERVAL=600
    networks={56:'BSC',
              137:'POLYGON',
              43114:'AVALANCHE',
              1:'ETH'}
    networkToken={56:'BNB',
              137:'MATIC',
              43114:'AVAX',
              1:'ETH',
              97:'TBNB'}
    networklinks={56:'https://bscscan.com/address/',
                 137:'https://polygonscan.com/address/',
                 43114:'https://snowtrace.io/address/',
                 1:'https://etherscan.io/address/',
                 97:'https://testnet.bscscan.com/address/'}

    try:
        with open('log.bin') as f:
            printedList=json.load(f)
            
    except:
        print("Couldn't Find log.bin")
        printedList = {'address':[]}
        
    bot = Bot(token='5319025529:AAHPss3M3PcFNutUZlozqE_khAdRUkH7vfg', parse_mode=ParseMode.HTML)
    dp = Dispatcher(bot)

async def on_bot_start_up(dispatcher) -> None:
    asyncio.create_task(startBot())



init()
executor.start_polling(dp, skip_updates=True, on_startup=on_bot_start_up)
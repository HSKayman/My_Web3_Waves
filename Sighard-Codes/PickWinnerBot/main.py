import asyncio
import json

from aiogram import Bot, Dispatcher
from aiogram.types import ParseMode
from aiogram.utils import executor
from loguru import logger
from web3 import Web3, HTTPProvider
from trader import Trader
import nest_asyncio
import time
nest_asyncio.apply()

bot: Bot
dp: Dispatcher

web3: Web3
TX_URL: str

channel_id: int

INTERVAL: int


def load_config():
    logger.info('Loading config...')
    with open('config.json') as f:
        return json.load(f)
    


    
async def pickBot():
    logger.info('PickWinner Operator Bot Start...')
   
    await asyncio.sleep(86400-int(datetime.timestamp(datetime.now()))%86400)
    
    while True:
        self.router_contract.functions.WETH().call()
        await bot.send_message(channel_id,
                              f'{prevAddress} Bought {result["amount"]} {trader.symbol} tokens with BNB {result["bnb"]} Token Balance:{tokens_amount/10e18}\n BNB Balance:{bnb_amount/10e18}{TX_URL % result["tx"]}\n{"Coded By ©HTM"}')
        await asyncio.sleep(INTERVAL)
        
    except:
        logger.error(f"Account {address} can't buy and sell\nBNB: {bnb_amount}\nTokens amount:{tokens_amount}")
        await bot.send_message(channel_id,
                            f"Account {address} can't buy and sell\nBNB balance: {trader.wei_to_eth(bnb_amount)}\nTokens balance:{tokens_amount / trader.decimals}")
       
              
                            

def init():
    global bot, dp, web3, TX_URL, channel_id, staking_contract
    config = load_config()
    web3 = Web3(HTTPProvider(config['bscNode']))
    TX_URL = config['txUrl']
    channel_id = config['channelId']

    logger.info(f'Connected: {web3.isConnected()}')
    logger.info(f'Chain ID: {web3.eth.chainId}')
    lottery_contract = web3.eth.contract(address = config['lotteryAddress'], abi=config['ABI'])

    bot = Bot(token=config['telegramBotToken'], parse_mode=ParseMode.HTML)
    dp = Dispatcher(bot)



async def on_bot_start_up(dispatcher) -> None:
    logger.info('Start up')
    asyncio.create_task(boost_volume())


if __name__ == '__main__':
    init()
    executor.start_polling(dp, skip_updates=True, on_startup=on_bot_start_up)
    

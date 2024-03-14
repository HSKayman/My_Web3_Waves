import asyncio
import json

from aiogram import Bot, Dispatcher
from aiogram.types import ParseMode
from aiogram.utils import executor
from loguru import logger
from web3 import Web3, HTTPProvider
from ABI import ABIfinder
from trader import Trader
import nest_asyncio
import time
nest_asyncio.apply()

bot: Bot
dp: Dispatcher

web3: Web3
trader: Trader
TX_URL: str

accounts = []
channel_id: int

INTERVAL: int


def load_config():
    logger.info('Loading config...')
    with open('config.json') as f:
        return json.load(f)


def load_accounts():
    """Load ethereum wallets private keys from keys.txt file for making swaps"""
    logger.info('Loading accounts...')
    with open('keys.txt') as f:
        for key in f:
            key = key.strip()
            address = web3.eth.account.from_key(key).address
            accounts.append((address, key))
            
def getRate(pair_contract,pair_token_contract):
    bnbPrice = pair_contract.functions.getReserves().call()
    tokenPrice = pair_token_contract.functions.getReserves().call()
    

    return bnbPrice[0]/bnbPrice[1],tokenPrice[0]/tokenPrice[1]

async def boost_volume():
    logger.info('Volume Booster Start...')
   
    
    
    pair_address="0xF855E52ecc8b3b795Ac289f85F6Fd7A99883492b"
    pair_abi = ABIfinder(pair_address , isMain=False)
    pair_contract = web3.eth.contract(address=pair_address, abi=pair_abi)

    pair_token_address="0xAE4C99935B1AA0e76900e86cD155BFA63aB77A2a"
    pair_token_abi = ABIfinder(pair_token_address , isMain=False)
    pair_token_contract = web3.eth.contract(address=pair_token_address, abi=pair_token_abi)
    while True:
            for index_account ,account in enumerate(accounts):
                for index_trader, trader in enumerate(traders):
                    address, key = account
                    prevAddress,prevKey = accounts[index_account-1]
                    
                    try:
                        # =============================================================================
                        # Selll                        
                        # =============================================================================
                        rates = getRate(pair_contract,pair_token_contract)
                        tokens_amount = trader.get_token_balance(address) 
                        bnb_amount = trader.get_bnb_balance(address)
                        
                        addAmount = 0
                        tokens_rate = (1+addAmount)/rates[0]
                        tokens=tokens_rate*rates[1]


                        if tokens > 0:
                            result = trader.sell(address, key, tokens)
                            tokens_amount = trader.get_token_balance(address)
                            bnb_amount = trader.get_bnb_balance(address)
                            await bot.send_message(channel_id,
                                                   f'{address} Sold {result["amount"]} {trader.symbol} tokens for {result["bnb"]} Token Balance:{tokens_amount/10e18}\n BNB Balance:{bnb_amount/10e18}\n{TX_URL % result["tx"]}\n{"Coded By ©HTM"}')
                        
                            await asyncio.sleep(INTERVAL)
                            

                        # =============================================================================
                        # Buy
                        # =============================================================================
                        rates = getRate(pair_contract,pair_token_contract)
                        tokens = trader.get_token_balance(prevAddress)
                        bnb_amount = trader.get_bnb_balance(prevAddress)
                        
                        addAmount = 0
                        BuyByBNBEachTokens = (1+addAmount)/rates[0]
                        
                        bnb = web3.toWei(BuyByBNBEachTokens,'ether')#Decimalli mi, degilmi
                           
                        if bnb > 0 and trader.can_buy(bnb, wallet=prevAddress):
                            result = trader.buy(prevAddress, prevKey, bnb)
                            tokens_amount = trader.get_token_balance(prevAddress)
                            bnb_amount = trader.get_bnb_balance(prevAddress)
                            await bot.send_message(channel_id,
                                                  f'{prevAddress} Bought {result["amount"]} {trader.symbol} tokens with BNB {result["bnb"]} Token Balance:{tokens_amount/10e18}\n BNB Balance:{bnb_amount/10e18}{TX_URL % result["tx"]}\n{"Coded By ©HTM"}')
                            await asyncio.sleep(INTERVAL)
                            
                    except:
                        logger.error(f"Account {address} can't buy and sell\nBNB: {bnb_amount}\nTokens amount:{tokens_amount}")
                        await bot.send_message(channel_id,
                                            f"Account {address} can't buy and sell\nBNB balance: {trader.wei_to_eth(bnb_amount)}\nTokens balance:{tokens_amount / trader.decimals}")
                   
              
                            

def init():
    global bot, dp, web3, traders, TX_URL, INTERVAL, channel_id, isBermuda
    config = load_config()
    web3 = Web3(HTTPProvider(config['bscNode']))
    TX_URL = config['txUrl']
    channel_id = config['channelId']
    INTERVAL = config['intervalInSeconds']
    
    router_address = Web3.toChecksumAddress(config['pancakeSwapRouterAddress'])
    router_abi = ABIfinder(router_address,isMain=False)
    
    logger.info(f'Connected: {web3.isConnected()}')
    logger.info(f'Chain ID: {web3.eth.chainId}')
    tokens_address = config['tokenAddress']
    traders=[]

    for token_adress in tokens_address:
        time.sleep(6)
        token_addressV1 = Web3.toChecksumAddress(token_adress)
        token_abi = ABIfinder(token_addressV1,isMain=False)
        token_contract = web3.eth.contract(address=token_addressV1, abi=token_abi)
        traders.append(Trader(web3, router_address, router_abi, token_contract, token_addressV1))

    bot = Bot(token=config['telegramBotToken'], parse_mode=ParseMode.HTML)
    dp = Dispatcher(bot)
    load_accounts()



async def on_bot_start_up(dispatcher) -> None:
    """List of actions which should be done before bot start"""
    logger.info('Start up')
    asyncio.create_task(boost_volume())


if __name__ == '__main__':
    init()
    executor.start_polling(dp, skip_updates=True, on_startup=on_bot_start_up)
    

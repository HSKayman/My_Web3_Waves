from web3.contract import ContractFunction, Contract
from web3 import HTTPProvider, Web3
from web3.types import Wei, TxParams
from loguru import logger
from ABI import ABIfinder
#import nest_asyncio
import time
from typing import Optional


class FeeCalculator:
    max_approval_hex = f"0x{64 * 'f'}"
    max_approval_int = int(max_approval_hex, 16)
    max_approval_check_hex = f"0x{15 * '0'}{49 * 'f'}"
    max_approval_check_int = int(max_approval_check_hex, 16)

    def __init__(self, web3: Web3, router_address, router_abi, token_contract: Contract, token_address):
        self.web3 = web3
        self.router_address = router_address
        self.router_contract = self.web3.eth.contract(address=router_address, abi=router_abi)
        self.token_contract = token_contract
        self.token_address = token_address
        self.symbol = self.token_contract.functions.symbol().call()
        self.decimals = 10 ** self.token_contract.functions.decimals().call()
        self.wbnb_address = self.router_contract.functions.WETH().call()
        self.slipage=0

    def approve(self, wallet, private_key) -> None:
        """Give an router max approval of a token."""
        approve_function = self.token_contract.functions.approve(self.router_address, self.max_approval_int)
        logger.info(f"Approving {self.symbol}...")
        tx = self._build_and_send_tx(approve_function, wallet, private_key)
        receipt = self.web3.eth.waitForTransactionReceipt(tx, timeout=6000)
        logger.info(f'Approved: {receipt}')
        # Add extra sleep to let tx propagate correctly
        time.sleep(1)

    def _is_approved(self, wallet) -> bool:
        """Check to see if the exchange and token is approved."""
        amount = self.token_contract.functions.allowance(wallet, self.router_address).call()
        if amount >= self.max_approval_check_int:
            return True
        return False

    def get_bnb_balance(self, wallet, in_ether: bool = False):
        """Get the balance of BNB in a wallet."""
        balance = self.web3.eth.getBalance(wallet)
        return Web3.fromWei(balance, 'ether') if in_ether else balance

    def get_token_balance(self, wallet, formatted: bool = False) -> int:
        """Get the balance of a token in a wallet."""
        balance: int = self.token_contract.functions.balanceOf(wallet).call()
        return balance / self.decimals if formatted else balance

    @staticmethod
    def _deadline() -> int:
        """Get a predefined deadline. 10min by default (same as the Uniswap SDK)."""
        return int(time.time()) + 10 * 60

    def can_buy(self, bnb, wallet=None, tx_fee=None) -> bool:
        if not tx_fee and wallet:
            buy_function = self._swap_eth_for_tokens(wallet,bnb)
            gas_limit = self.estimate_gas(buy_function, wallet, bnb)
            gas_price = self.web3.eth.gas_price
            tx_fee = self._calc_tx_fee(gas_limit, gas_price)
        return bnb - (tx_fee*6) > 0

    def can_sell(self, wallet, amount):
        sell_function = self._swap_tokens_for_eth(wallet, amount)
        gas_limit = self.estimate_gas(sell_function, wallet)
        gas_price = self.web3.eth.gas_price
        tx_fee = self._calc_tx_fee(gas_limit, gas_price)
        bnb_balance = self.get_bnb_balance(wallet)
        
        return bnb_balance - tx_fee > 0

    @staticmethod
    def estimate_gas(function: ContractFunction, address_from, value: Wei = Wei(0)) -> Wei:
        return Wei(function.estimateGas({'from': address_from, 'value': value}) + 30000)

    def _get_tx_params(self, function: ContractFunction, address_from: str, value: Wei = Wei(0)) -> TxParams:
        """Get generic transaction parameters."""
        gas_limit = self.estimate_gas(function, address_from, value)
        gas_price = self.web3.eth.gas_price
        if value > 0:
            tx_fee = self._calc_tx_fee(gas_limit, gas_price)
            if not self.can_buy(value, tx_fee=tx_fee):
                raise Exception('BNB balance is insufficient for [BUY]')
            value-=(tx_fee*6)
        return {
            'from': address_from,
            'value': value,
            "gas": gas_limit,
            'gasPrice': gas_price,
            "nonce": self.web3.eth.getTransactionCount(address_from)
        }

    @staticmethod
    def _calc_tx_fee(gas_limit: Wei, gas_price: Wei):
        return gas_limit * gas_price 

    @staticmethod
    def wei_to_eth(wei):
        return Web3.fromWei(wei, 'ether')

    def _build_and_send_tx(self, function: ContractFunction, address_from, private_key,
                           tx_params: Optional[TxParams] = None):
        """Build and send a transaction."""
        if not tx_params:
            tx_params = self._get_tx_params(function, address_from)
        transaction = function.buildTransaction(tx_params)
        signed_txn = self.web3.eth.account.sign_transaction(
            transaction, private_key=private_key
        )
        return self.web3.eth.sendRawTransaction(signed_txn.rawTransaction)
    
    def _build_and_send_tx_fee(self, function: ContractFunction, address_from, private_key,
                            tx_params: Optional[TxParams] = None):
         """Build and send a transaction."""
         if not tx_params:
             tx_params = self._get_tx_params(function, address_from)
         transaction = function.buildTransaction(tx_params)
         return None

    def _swap_eth_for_tokens(self, wallet, amount):
        
        price=self.router_contract.functions.getAmountsOut(amount, [self.wbnb_address,self.token_address]).call()
        int(price[0]/price[1]*self.decimal)
        amountOutMin = price[1]-(int(price[1]/100)*self.slipage)
        
        return self.router_contract.functions.swapExactETHForTokensSupportingFeeOnTransferTokens(
            amountOutMin,
            [self.wbnb_address, self.token_address],
            wallet,
            self._deadline()
        )

    def buy(self, wallet, private_key, bnb_amount):
        try:
            
            buy_function = self._swap_eth_for_tokens(wallet,bnb_amount)
            tx_params = self._get_tx_params(buy_function, wallet, bnb_amount)
            bnb_used = self.wei_to_eth(tx_params["value"])
            logger.info(f'[BUY] using {wallet} {self.symbol} token for {bnb_used} BNB')
            self._build_and_send_tx_fee(buy_function, wallet, private_key, tx_params)
            return True
        except Exception as e:
             logger.error(f"[ERROR] while [Buy]: {e} Slipage:{self.slipage}%")
             return False

    def _swap_tokens_for_eth(self, wallet, amount):
        
        price=self.router_contract.functions.getAmountsOut(amount, [self.token_address,self.wbnb_address]).call()
        amountOutMin = price[1]-(int(price[1]/100)*self.slipage)
        
        return self.router_contract.functions.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            amountOutMin,
            [self.token_address, self.wbnb_address],
            wallet,
            self._deadline()
        )

    def sell(self, wallet, private_key, amount):
        try:
            if amount <= 0:
                raise Exception('Invalid token amount or token balance is insufficient')
            if not self._is_approved(wallet):
                self.approve(wallet, private_key)
            #logger.info(f'[SELL] using {wallet} {amount / self.decimals} {self.symbol} tokens for BNB')
            sell_function = self._swap_tokens_for_eth(wallet, amount)

            tx_params = self._get_tx_params(sell_function,wallet)
            self._build_and_send_tx_fee(sell_function, wallet, private_key, tx_params)
            return True
        except Exception as e:
            logger.error(f"[ERROR] while [SELL]: {e} Slipage:{self.slipage}%")
            return False
    
    def fee_calculate(self,isSell,wallet,private_key,amount):
        if isSell:
            i=0
            while i<100:
                try:
                    self.slipage=i
                    sell_function =self.sell(wallet, private_key, amount)
                    if sell_function:
                        return i
                except Exception as e:
                    logger.error(f'{i}, {e}')
                    
                finally:
                    i+=1
                #if sell_function==True:
                #    return i

        else:
            i=0
            while i<100:
                try:
                    self.slipage=i
                    buy_function =self.buy(wallet, private_key, amount)
                    if buy_function:
                        return i
                except Exception as e:
                    logger.error(f'{i}, {e}')
                    
                finally:
                    i+=1

global config
config={
   "tokenAddress":"0x9F654cDd528B07CfBd2D38C5A8ca0218827ffF9D",
   "pancakeSwapRouterAddress": "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3",
   "bscNode": "https://data-seed-prebsc-1-s1.binance.org:8545/",
   "chainId": 97,
   "Address": "0xcaA98CBaF47F8fB2b5e2f6add18c43bf7182516E",
   "Private":"320ffce361afe139f78553bb47b2b23eb5def730b9602ec16fe1554dfc0f2ebf"
   
   }

web3 = Web3(HTTPProvider(config['bscNode']))
channel_id = config['chainId']


router_address = Web3.toChecksumAddress(config['pancakeSwapRouterAddress'])
router_abi = ABIfinder(router_address,isMain=channel_id==56)

logger.info(f'Connected: {web3.isConnected()}')
logger.info(f'Chain ID: {web3.eth.chainId}')
tokens_address = config['tokenAddress']
 
token_address = Web3.toChecksumAddress(config['tokenAddress'])
token_abi = ABIfinder(token_address,isMain=channel_id==56)
token_contract = web3.eth.contract(address=token_address, abi=token_abi)

Calculator=FeeCalculator(web3, router_address, router_abi, token_contract, token_address)
logger.info(f'Conected: {config["tokenAddress"]}')

SellFee=Calculator.fee_calculate(True,config['Address'],config['Private'],Web3.toWei(0.001, 'ether'))
logger.info(f'Sell Fee: <{SellFee}')

BuyFee=Calculator.fee_calculate(False,config['Address'],config['Private'],Web3.toWei(0.1, 'ether'))
logger.info(f'Buy Fee: <{BuyFee} ')




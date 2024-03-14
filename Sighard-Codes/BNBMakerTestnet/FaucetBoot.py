# -*- coding: utf-8 -*-
"""
Created on Sun Sep 25 15:33:10 2022

@author: HSK
"""

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from datetime import datetime
from eth_account import Account
from selenium import webdriver
from web3 import Web3
import warnings
import secrets
import time
import os
import json
import nest_asyncio

nest_asyncio.apply()


warnings.filterwarnings("ignore")
web3 = Web3(Web3.HTTPProvider("https://data-seed-prebsc-1-s1.binance.org:8545/"))

ipList=[]
faucets='https://testnet.binance.org/faucet-smart'
faucetsProcess=[['//*[@id="url"]','input'],
                ['/html/body/div/div/div[2]/div/div[1]/span[1]/button','click'],
                ['/html/body/div/div/div[2]/div/div[1]/span[1]/ul/li/a','click']]

startIps={"108.165.252.":[[2,128],[129,255]],
	"5.105.24.":[[2,128],[129,255]],
	"108.165.202.":[[2,128],[129,255]],
	"194.87.22.":[[2,128],[129,255]],
          "194.87.200.":[[2,128],[129,255]]
          
            }

gateway=[]
clock={}
try:
    with open('log.bin') as f:
        clock=json.load(f)
except:
    print("Couldn't Find log.bin")


for link in startIps:
    if not link in gateway: 
        gateway.append(link)
    ipRange=[]
    if not link in clock:
        clock[link]={}
    for ranges in startIps[link]:
        for ip in range(ranges[0],ranges[1]):
            ipRange.append(link+'{}'.format(ip))
            if not link+'{}'.format(ip) in clock[link]:
                clock[link][link+'{}'.format(ip)]=-1
    ipList.append(ipRange)



MainWallet='0xC99CA32F614079d69D6C178b9dc37b399dE3eFAF'

async def checkWallet(WalletPriv,WalletAddress):
        for (Priv,address) in zip(WalletPriv,WalletAddress):
            
            if await web3.eth.getBalance(address)<=(web3.eth.gasPrice * 31600):
                continue
            
            tx = {
                'nonce': 0,
                'to': MainWallet,
                'value': web3.eth.getBalance(address) - (web3.eth.gasPrice * 31600),
                'gas': 31600,
                'gasPrice': web3.eth.gasPrice
            }
            try:
                signed_tx = await web3.eth.account.signTransaction(tx, Priv)
            finally:
                try:
                    time.sleep(3)
                    signed_tx = await web3.eth.account.signTransaction(tx, Priv)
                except:
                    continue
                
            tx_hash = await web3.eth.sendRawTransaction(signed_tx.rawTransaction)
            trans = web3.toHex(tx_hash)
            print(trans)
        

while True:
    mini=[99999]
    flag=False
    for indexOfIps,ips in enumerate(ipList):
        if clock[gateway[indexOfIps]][ips[-1]]!=-1 and clock[gateway[indexOfIps]][ips[-1]]> int(datetime.timestamp(datetime.now()))-86400:
            print('Waiting {} minutes Gateway {} it will start {}'.format(clock[gateway[indexOfIps]][ips[-1]]+86410-int(datetime.timestamp(datetime.now())),
                                                                          gateway[indexOfIps],
                                                                          datetime.fromtimestamp(clock[gateway[indexOfIps]][ips[-1]]+86410)))
            mini.append(clock[gateway[indexOfIps]][ips[-1]]+86410-int(datetime.timestamp(datetime.now())))
            flag=True
            continue
    if flag:
        time.sleep(min(mini))
    for indexOfIps,ips in enumerate(ipList):
        if clock[gateway[indexOfIps]][ips[-1]]!=-1 and clock[gateway[indexOfIps]][ips[-1]]> int(datetime.timestamp(datetime.now()))-86400:
            continue

        WalletPriv=[]
        WalletAddress=[]
        for key in range(len(ips)):
            private_key = secrets.token_hex(32)
            acct = Account.from_key(private_key)
            WalletPriv.append(private_key)
            WalletAddress.append(acct.address)
         
        try:
            for index,ip in enumerate(ips):
                if(clock[gateway[indexOfIps]][ip]> int(datetime.timestamp(datetime.now()))-86400):
                    continue
                os.system('netsh interface ip set address name="Ethernet1" static {} 255.255.255.0 {}1'.format(ip,gateway[indexOfIps]))
                print("Count:",index,"\tIP:",ip)
                flag=True
                cFlag=0
                while flag:
                    try:
                        time.sleep(5)
                        proxy = ""+ip+":3128"
                     
                        options = Options()
                        options.add_argument("--window-size=1280,800")
                        options.add_extension("hCaptcha-Solver.crx")
                        options.add_argument("--disable-gpu")
                        
                        driver = webdriver.Chrome(executable_path='chromedriver.exe',options=options)#,capabilities=firefox_capabilities)
                        driver.get(faucets)
                        
                        print("Count:",index,"\t AI is trying to solve hCaptcha")
                        process=False
                        cFlag+=1
                        driver.implicitly_wait(120)
    
                        for process in faucetsProcess:
                            if 'input'==process[1]:
                                WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value=process[0])).send_keys(WalletAddress[index])
                            elif 'click'==process[1]:
                                WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value=process[0])).click()
                            if faucetsProcess[-1]==process:
                                process=True
                            time.sleep(0.5)
                        
                        if process or cFlag==2:
                            print("[Complete Faucet] Count:",index,"\tIP:",proxy,"\tWallet:",WalletAddress[index])
                            clock[gateway[indexOfIps]][ip]=int(datetime.timestamp(datetime.now()))
                            flag=False
                        
                        if web3.eth.getBalance(WalletAddress[index-1])>0:
                            tx = {
                                'nonce': 0,
                                'to': MainWallet,
                                'value': web3.eth.getBalance(WalletAddress[index-1]) - (web3.eth.gasPrice * 31600),
                                'gas': 31600,
                                'gasPrice': web3.eth.gasPrice
                            }
                            signed_tx = web3.eth.account.signTransaction(tx, WalletPriv[index-1])
                            print("[Transfer] Count:",index-1,"\tWallet:",WalletAddress[index-1])
                            
                            tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
                            trans = web3.toHex(tx_hash)
                            print(trans)
                                
    
                    except Exception as e:
                        print(e)
                        print("Count:",index,"\t AI couldn't solve hCaptcha. it will try again")  
                    finally:
                        json.dump(clock, open("log.bin",'w'))
                        try:
                            driver.close()
                        except:
                            pass
                        
        except Exception as e:
            print(e)
        finally:
            time.sleep(10)
            checkWallet(WalletPriv,WalletAddress)
            balance = web3.eth.get_balance(MainWallet)   
            humanReadable = web3.fromWei(balance, 'ether')
            print("Terminate This Process",humanReadable)
            json.dump(clock, open("log.bin",'w'))

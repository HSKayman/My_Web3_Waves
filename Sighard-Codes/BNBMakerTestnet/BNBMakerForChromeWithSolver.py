# -*- coding: utf-8 -*-
"""
Created on Wed May 11 01:28:37 2022

@author: Administrator
"""

from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.common.by import By
from eth_account import Account
#from pypasser import reCaptchaV2
from selenium import webdriver
from web3 import Web3
import warnings
import secrets
import random
import time
import json 
import os
import pickle
#from requests import session
warnings.filterwarnings("ignore")

web3 = Web3(Web3.HTTPProvider("https://data-seed-prebsc-1-s1.binance.org:8545/"))

ipList=[]
faucets=['https://testnet.binance.org/faucet-smart']
faucetsProcess=[[
                ['//*[@id="url"]','input'],
                ['/html/body/div/div/div[2]/div/div[1]/span[1]/button','click'],
                ['/html/body/div/div/div[2]/div/div[1]/span[1]/ul/li/a','click']]]

startIps={"5.105.24.":[[2,5],[15,20]],
          "194.87.200.":[[2,255]],
        "109.206.239.":[[2,255]]
            }


for link in startIps:
    for ranges in startIps[link]:
        for ip in range(ranges[0],ranges[1]):
            ipList.append(link+'{}'.format(ip))

MainWallet='0xC99CA32F614079d69D6C178b9dc37b399dE3eFAF'

while True: 
    print("Don't Terminate This Process")
    WalletPriv=[]
    WalletAddress=[]
    for key in range(2,254):
        private_key = secrets.token_hex(32)
        acct = Account.from_key(private_key)
        WalletPriv.append(private_key)
        WalletAddress.append(acct.address)
    try:
        for index,ip in enumerate(ipList):
            os.system('netsh interface ip set address name="Ethernet1" static {} 255.255.255.0 185.126.179.1'.format(ip))
            print("Count:",index,"\tIP:",ip)
            flag=True
            cflag=0
            while flag and cflag!=2:
                try:
                    for indexFaucet,targetFaucet in enumerate(faucets):

                        time.sleep(5)
                        proxy = ""+ip+":3128"
                     
                        options = Options()
                        options.add_argument("--window-size=1280,800")
                        options.add_extension("hCaptcha-Solver.crx")
                        options.add_argument("--disable-gpu")
                        
                        driver = webdriver.Chrome(executable_path='chromedriver.exe',options=options)#,capabilities=firefox_capabilities)
                        driver.get(targetFaucet)
                        
                        print("Count:",index,"\t AI is trying to solve hCaptcha")
                        process=False
                        driver.implicitly_wait(120)
                        cflag+=1
                        for process in faucetsProcess[indexFaucet]:
                            if 'input'==process[1]:
                                WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value=process[0])).send_keys(WalletAddress[index])
                            elif 'click'==process[1]:
                                WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value=process[0])).click()
                            process=True
                            time.sleep(2)
                        
                        if process:
                            print("[Complete Faucet] Count:",index,"\tIP:",proxy,"\tWallet:",WalletAddress[index])
                            flag=False
                        
                        
                        if web3.eth.getBalance(WalletAddress[index-1])>0:
                           
                            tx = {
                                'nonce': 0,
                                'to': MainWallet,
                                'value': web3.eth.getBalance(WalletAddress[index-1]) - (web3.eth.gasPrice * 31600),
                                'gas': 31600,
                                'gasPrice': web3.eth.gasPrice
                            }
                            time.sleep(3)
                            signed_tx = web3.eth.account.signTransaction(tx, WalletPriv[index-1])
                            print("[Transfer] Count:",index-1,"\tWallet:",WalletAddress[index-1])
                            
                            tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
                            trans = web3.toHex(tx_hash)
                            print(trans)
                        elif index!=0:
                            ipList.append(ipList[index-1])
                            WalletPriv.append(WalletPriv[index-1])
                            WalletAddress.append(WalletAddress[index-1])

                        
 
                except Exception as e:
                    print(e)
                    print("Count:",index,"\t AI couldn't solve hCaptcha. it will try again")  
                finally:
                    try:
                        driver.close()
                    except:
                        pass
                    
    except Exception as e:
        print(e)
    finally:
        time.sleep(30)
        for (Priv,address) in zip(WalletPriv,WalletAddress):
            
            if web3.eth.getBalance(address)<=(web3.eth.gasPrice * 31600):
                continue
            
            tx = {
                'nonce': 0,
                'to': MainWallet,
                'value': web3.eth.getBalance(address) - (web3.eth.gasPrice * 31600),
                'gas': 31600,
                'gasPrice': web3.eth.gasPrice
            }
            try:
                signed_tx = web3.eth.account.signTransaction(tx, Priv)
            finally:
                try:
                    time.sleep(3)
                    signed_tx = web3.eth.account.signTransaction(tx, Priv)
                except:
                    continue
                
            tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)
            trans = web3.toHex(tx_hash)
            print(trans)
        balance = web3.eth.get_balance(MainWallet)   
        humanReadable = web3.fromWei(balance, 'ether')
        print("Terminate This Process",humanReadable)   
    break
        

    #driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
    #ip = get('https://api64.ipify.org').text
    #print(f'My public IP address is: {ip}')
    #os.system('ip -6 route replace ::/0 via 2a04:3880:0:16::1 src {}'.format(ipList[-1]))
    #os.system('ip -6 addr del {} dev ens32'.format(ipList[-1]))
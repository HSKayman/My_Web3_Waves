# -*- coding: utf-8 -*-
"""
Created on Wed May 11 01:28:37 2022

@author: Administrator
"""

from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
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
#warnings.filterwarnings("ignore")

web3 = Web3(Web3.HTTPProvider("https://data-seed-prebsc-1-s1.binance.org:8545/"))

ipList=[]
faucets=['https://testnet.binance.org/faucet-smart']
faucetsProcess=[[['//*[@id="url"]','input'],
                ['/html/body/div/div/div[2]/div/div[1]/span[1]/button','click'],
                ['/html/body/div/div/div[2]/div/div[1]/span[1]/ul/li/a','click']]]

for ip in range(2,255):
    ipList.append('185.126.179.{}'.format(ip))
MainWallet='0xf0c5b1FD48a235F2D91dAdedEcf73D5C0AECB210'
while True: 
    print("Don't Terminate This Process")
    WalletPriv=[]
    WalletAddress=[]
    for key in range(2,255):
        private_key = secrets.token_hex(32)
        acct = Account.from_key(private_key)
        WalletPriv.append(private_key)
        WalletAddress.append(acct.address)
    try:
        for index,ip in enumerate(ipList):
            try:
                for indexFaucet,targetFaucet in enumerate(faucets):
        
                    os.system('netsh interface ip set address name="Ethernet 2" static {} 255.255.255.0 185.126.179.1'.format(ip))
                    time.sleep(5)
                    proxy = ""+ip+":3128"
                    #webdriver.DesiredCapabilities.CHROME['proxy'] = {
                   #     "httpProxy": proxy,
                   #     "proxyType": "MANUAL",
                   # 
                   # }
                    
                    #webdriver.DesiredCapabilities.CHROME['acceptSslCerts']=True
        
                    #firefox_capabilities = webdriver.DesiredCapabilities.FIREFOX
                    #firefox_capabilities['marionette'] = True
                    #firefox_capabilities['proxy'] = {"proxyType": "MANUAL","httpProxy": proxy}
                    #profile = webdriver.FirefoxProfile()
                    #profile.set_preference("general.useragent.override", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17")
                    
                    options = Options()
                    #options.set_preference('profile', profile)
                    options.add_argument("window-size=1280,800")
                    #options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36")
                    #options.add_argument('--disable-blink-features=AutomationControlled')
                    options.add_argument('--proxy-server={}'.format(proxy))
                    #options.add_argument("user-data-dir=selenium") 
                    #options.add_experimental_option("excludeSwitches", ["enable-logging"])
                    #options.binary_location = r'C:\Program Files (x86)\Mozilla Firefox\firefox.exe'
                    #options.set_capability("loggingPrefs",firefox_capabilities)
                    #options.headless = True
                    
                    driver = webdriver.Chrome(executable_path='chromedriver.exe')#,options=options)#,capabilities=firefox_capabilities)
                    driver.get(targetFaucet)
                    #pickle.dump(driver.get_cookies(), open("cookies.pkl","wb"))
                    #is_checked = reCaptchaV2(driver=driver, play=False)
                    #if is_checked:
                    for process in faucetsProcess[indexFaucet]:
                        if 'input'==process[1]:
                            WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value=process[0])).send_keys(WalletAddress[index])
                        elif 'click'==process[1]:
                            WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value=process[0])).click()
                        time.sleep(3)
                    print("Count:",index,"\tIP:",proxy,"\tWallet:",WalletAddress[index])
                    driver.close()
            except Exception as e:
                print(e)       
    except Exception as e:
        print(e)
    finally:
        for (Priv,address) in zip(WalletPriv,WalletAddress):
            
            if web3.eth.getBalance(address)<=(web3.eth.gasPrice * 21000):
                continue
            
            tx = {
                'nonce': 0,
                'to': MainWallet,
                'value': web3.eth.getBalance(address) - (web3.eth.gasPrice * 21000),
                'gas': 21000,
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
    time.sleep(60*60*24)
        

    #driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
    #ip = get('https://api64.ipify.org').text
    #print(f'My public IP address is: {ip}')
    #os.system('ip -6 route replace ::/0 via 2a04:3880:0:16::1 src {}'.format(ipList[-1]))
    #os.system('ip -6 addr del {} dev ens32'.format(ipList[-1]))
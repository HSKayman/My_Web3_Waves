# -*- coding: utf-8 -*-
"""
Created on Thu Apr 14 20:49:56 2022

@author: suca
"""

#Suca
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import random
from selenium.webdriver.support.ui import WebDriverWait
import time
import selenium.webdriver.support.ui as ui
#import os
#from requests import get
import warnings

from eth_account import Account
from senderBot import multiSender
from receiverBot import multiGatherer
import warnings
import secrets


multiGatherer()
accounts = []
priv_keys=[]
addresses=[]
numberOfWallet=10
def load_accounts():
     """Load ethereum wallets private keys from keys.txt file for making swaps"""

     for key in range(numberOfWallet):
        private_key = secrets.token_hex(32)
        acct = Account.from_key(private_key)
        accounts.append((acct.address,private_key))
        priv_keys.append(private_key)
        addresses.append(acct.address)
        
     f = open("accounts.txt", 'w')
     for account in accounts:
        f.write(str(account)+'\n')
     f.close()
     
     f = open("priv_keys.txt", 'w')
     for key in priv_keys:
        f.write(str(key)+'\n')
     f.close()
     
     f = open("addresses.txt", 'w')
     for address in addresses:
        f.write(str(address)+'\n')
     f.close()
     
load_accounts()
multiSender()
warnings.filterwarnings("ignore")
i=0
i_uns=0
flag=True
targetAddress= '0x2727b6f90067116a39D0B98479e45e18a80E85e7'
targetLauncpad="https://www.pinksale.finance/#/launchpad/{}?chain=BSC-Test".format(targetAddress)

def clicker(mode,link,data=""):
    if mode == "click":
        ui.WebDriverWait(driver,1000).until(lambda d: d.find_element_by_xpath(link))
        driver.find_element_by_xpath(link).click()
    elif mode == "send":
        ui.WebDriverWait(driver,1000).until(lambda d: d.find_element_by_xpath(link))
        driver.find_element_by_xpath(link).send_keys(data)
    elif mode == "selector":
        ui.WebDriverWait(driver,1000).until(lambda d: d.find_element_by_css_selector(link))
        driver.find_element_by_css_selector(link).click()
    else:
        ui.WebDriverWait(driver,1000).until(lambda d: d.find_element_by_css_selector(link))
        driver.find_element_by_css_selector(link).send_keys(data)
chrome_path = 'chromedriver.exe'
chrome_options = Options()
#chrome_options.add_argument("--headless") 
#chrome_options.add_argument("--start-maximized");
chrome_options.add_extension("MetaMask.crx")
print(1)
#chrome_options.add_argument("user-data-dir=C:/Users/V/Documents/STACKS OVERFLOW/Test")  # Save Profile
#chrome_options.add_argument("--profile-directory=test")  # Choose witch profile you would like to use

print(1)

driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)

time.sleep(random.random()+1)

#time.sleep(random.random()+10)
driver.get('chrome-extension://nkbihfbeogaeaoehlefnkodbefgpgknn/home.html#initialize/welcome')
driver.switch_to.window(driver.window_handles[1])
driver.close()
driver.switch_to.window(driver.window_handles[0])
clicker("click", '//button[text()="Get Started"]')

clicker("click", '//button[text()="Import wallet"]')

clicker("click", '//button[text()="No Thanks"]')

inputs = driver.find_elements_by_css_selector('.MuiInputBase-input.MuiInput-input')
inputs[0].send_keys('tourist')
inputs[1].send_keys('doctor')
inputs[2].send_keys('dose')
inputs[3].send_keys('spend')
inputs[4].send_keys('toast')
inputs[5].send_keys('kite')
inputs[6].send_keys('dune')
inputs[7].send_keys('village')
inputs[8].send_keys('cover')
inputs[9].send_keys('agree')
inputs[10].send_keys('test')
inputs[11].send_keys('spoon')
inputs[12].send_keys('SonOfMetaMask')
inputs[13].send_keys('SonOfMetaMask')

clicker("selector",'.check-box.far.fa-square')

clicker("click", '//button[text()="Import"]')

clicker("click", '//button[text()="All Done"]')

clicker("click", '//*[@id="popover-content"]/div/div/section/div[1]/div/button')

for i in range(numberOfWallet):
    clicker('click','//*[@id="app-content"]/div/div[1]/div/div[2]/div[2]')

    clicker('click','//*[@id="app-content"]/div/div[3]/div[7]')

    clicker('send','//*[@id="private-key-box"]',priv_keys[i])
  
    clicker('click','//*[@id="app-content"]/div/div[3]/div/div/div[2]/div[2]/div[2]/button[2]')


clicker("click", '//*[@id="app-content"]/div/div[1]/div/div[2]/div[1]/div')

clicker("click", '//*[@id="app-content"]/div/div[2]/div/div[3]/button')

clicker("send", '/html/body/div[1]/div/div[3]/div/div[2]/div[2]/div/div[2]/div/div[2]/div[1]/label/input',"BSC Testnet")

clicker("send",'//*[@id="app-content"]/div/div[3]/div/div[2]/div[2]/div/div[2]/div/div[2]/div[2]/label/input',"https://data-seed-prebsc-1-s1.binance.org:8545")

clicker("send", '//*[@id="app-content"]/div/div[3]/div/div[2]/div[2]/div/div[2]/div/div[2]/div[3]/label/input',"97")

clicker("send", '//*[@id="app-content"]/div/div[3]/div/div[2]/div[2]/div/div[2]/div/div[2]/div[4]/label/input',"BNB")

clicker("click", '//*[@id="app-content"]/div/div[3]/div/div[2]/div[2]/div/div[2]/div/div[3]/button[2]')


driver.execute_script("window.open('');")
driver.switch_to.window(driver.window_handles[1])
driver.get(targetLauncpad)

driver.switch_to.window(driver.window_handles[0])
time.sleep(5)
clicker("click", '/html/body/div[1]/div/div[3]/div/div/div[1]/div[2]/div/div[2]/button[2]')

clicker("click", '/html/body/div[1]/div/div[1]/div/div[1]')
   
clicker("click", '//*[@id="app-content"]/div/div[2]/div/div[2]/div[2]/div[1]/div[1]/input')  

clicker("click", '/html/body/div[1]/div/div[2]/div/div[3]/div[2]/button[2]')

clicker("click", '/html/body/div[1]/div/div[2]/div/div[2]/div[2]/div[2]/footer/button[2]')

 
clicker("click",'//*[@id="app-content"]/div/div[1]/div/div[2]/div[2]/div')

driver.find_elements_by_css_selector('.account-menu__account.account-menu__item--clickable')[1].click()
  
count=1

while flag:
    try:

        driver.switch_to.window(driver.window_handles[1])
        driver.get(targetLauncpad)
        time.sleep(15)
        clicker("send",'/html/body/div/section/section/main/div/div[1]/div[2]/div[1]/div/form/div[3]/div/div/input','0.0001')
        time.sleep(5)

        clicker("click",'/html/body/div[1]/section/section/main/div/div[1]/div[2]/div[1]/div/form/button')
        time.sleep(5)
        driver.switch_to.window(driver.window_handles[0])
        
        
        clicker("click", '//*[@id="app-content"]/div/div[3]/div/div/div[1]/div[3]/ul/li[2]/button')
        
        clicker("click", '//*[@id="app-content"]/div/div[3]/div/div/div[1]/div[3]/div/div/div/div[1]/div[2]')

        clicker("click", '/html/body/div[1]/div/div[3]/div/div[5]/div[3]/footer/button[2]')

        #driver.find_element_by_css_selector('.account-menu__close-area')
        #driver.find_elements_by_css_selector('account-menu__accounts')[count].click()
        
        
        driver.find_element_by_xpath('//*[@id="app-content"]/div/div[1]/div/div[2]/div[2]/div').click()
        
  
        if (count+1)%numberOfWallet==0:
            count+=1
        driver.find_elements_by_css_selector('.account-menu__account.account-menu__item--clickable')[(count+1)%numberOfWallet].click()
        
    except Exception as e:
        print("[Error]:{} ".format(e))
    finally:
        count+=1
        if count==numberOfWallet:
            break
multiGatherer()     
for handle in driver.window_handles:
            driver.switch_to.window(handle)
            driver.close()
    ########
       #os.system('ip -6 addr del {} dev ens32'.format(ipList[-1]))
           
 


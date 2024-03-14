# -*- coding: utf-8 -*-
"""
Created on Thu Apr 14 20:49:56 2022

@author: suca
"""

#Suca
from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile
import random
import time
import os
#from requests import get
import warnings
warnings.filterwarnings("ignore")
i=0
i_uns=0
flag=True
targetAddress= '0x276c0e9F25cA8b33Cf251992cA48fbF44b8Ca316'
targetLauncpad="https://www.pinksale.finance/#/launchpad/{}?chain=BSC".format(targetAddress)
ipList=[]
firefox_path = '/usr/bin/geckodriver'
os.system('netplan apply')
time.sleep(4)
while flag:
    try:
        ipList.append('2a04:3880:0:34::{}:{}'.format(str(hex(int(random.random()*65535-1)))[2:],str(hex(int(random.random()*65535-1)))[2:]))
        os.system('ip -6 addr add {} dev ens32'.format(ipList[-1]))
        #os.system('ip -6 route replace ::/0 via 2a04:3880:0:16::1 src {}'.format(ipList[-1]))
        proxy = "["+ipList[-1]+"]:3128"
        firefox_capabilities = webdriver.DesiredCapabilities.FIREFOX
        firefox_capabilities['marionette'] = True
        firefox_capabilities['proxy'] = {
         "proxyType": "MANUAL",
         "httpProxy": proxy
         #"ftpProxy": proxy,
         #"sslProxy": proxy
         }
        options = Options()
        options.headless = True
        #options.profile = FirefoxProfile().set_preference("javascript.enabled", False)
        #options.set_capability("loggingPrefs", {'performance': 'ALL'})
        #options.proxy()
        driver = webdriver.Firefox(executable_path=firefox_path,options=options,capabilities=firefox_capabilities)
        #driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
        #ip = get('https://api64.ipify.org').text
        #print(f'My public IP address is: {ip}')
        #driver.get("https://mirror.bursabil.com.tr/")
        #pageSource = driver.page_source
        #print(pageSource)
        #time.sleep(random.random()+3)
        driver.get(targetLauncpad)
        #driver.implicitly_wait(5)
        time.sleep(random.random()+2)
        #pageSource = driver.page_source
        #print(pageSource)
        coin_names=[]
        try: 
            coin_name=driver.find_elements_by_css_selector(".title.mr-2")
            for coin in coin_name:
                coin_names.append(coin.text)
            if 'Moon' in coin_names[-1]: 
                i+=1
            else:
                i_uns+=1
        except:
            coin_names.append("Connection ErrorPage")
            i_uns+=1
        	    
        print(i+i_uns,". Click with ",ipList[-1]," IP",coin_names,"Success:",i,"Unsuccess:",i_uns)
        
    except Exception as e:
        print("[Error]:{} ".format(e))
    finally:
        driver.close()
        os.system('ip -6 addr del {} dev ens32'.format(ipList[-1]))
            
        


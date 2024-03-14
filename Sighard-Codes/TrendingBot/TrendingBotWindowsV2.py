# -*- coding: utf-8 -*-
"""
Created on Thu Apr 14 20:49:56 2022

@author: suca
"""

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
targetAddress= '0x3b9832C457B5C4FD2cC268ddD3C6e4274006bD38'
targetLauncpad="https://www.pinksale.finance/#/launchpad/{}?chain=BSC".format(targetAddress)
ipList=[]
firefox_path = 'geckodriver.exe'
#os.system('netplan apply')
#time.sleep(4)
while flag:
    try:

        ipList.append('185.126.179.{}'.format(int(random.random()*240+2)))
        ######
        os.system('netsh interface ip set address name="Ethernet 2" static {} 255.255.255.0 185.126.179.1'.format(ipList[-1]))
        #os.system('ip -6 route replace ::/0 via 2a04:3880:0:16::1 src {}'.format(ipList[-1]))
        ######
        proxy = ""+ipList[-1]+":3128"
        firefox_capabilities = webdriver.DesiredCapabilities.FIREFOX
        firefox_capabilities['marionette'] = True
        firefox_capabilities['proxy'] = {
         "proxyType": "MANUAL",
          "httpProxy": proxy
         #"ftpProxy": proxy,
         #"sslProxy": proxy
         }
        options = Options()
        options.binary_location = r'C:\Program Files (x86)\Mozilla Firefox\firefox.exe'
        options.headless = True
        #options.profile = FirefoxProfile().set_preference("javascript.enabled", False)
        #options.set_capability("loggingPrefs", {'performance': 'ALL'})
        #options.proxy()
        driver = webdriver.Firefox(executable_path=firefox_path,options=options)#,capabilities=firefox_capabilities)
        driver.get('https://www.pinksale.finance/#/launchpads?chain=BSC')
        time.sleep(random.random()+5)
        driver.find_element_by_css_selector('.ant-input').send_keys("BERMUDA")
        time.sleep(random.random()+5)
        searchedToken=driver.find_element_by_css_selector('.ant-list-item-meta-description')
        if searchedToken.text=="0x3b9832C457B5C4FD2cC268ddD3C6e4274006bD38":
            driver.find_element_by_css_selector('.ant-btn.ant-btn-primary').click()
        else:
            raise Exception("Cant find ")
        #driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
        #ip = get('https://api64.ipify.org').text
        #print(f'My public IP address is: {ip}')
        #driver.get("https://mirror.bursabil.com.tr/")
        #pageSource = driver.page_source
        #print(pageSource)
        #time.sleep(random.random()+3)
        
        #driver.implicitly_wait(5)
        #time.sleep(random.random()+4)
        #pageSource = driver.page_source
        #print(pageSource)
        coin_names=[]
        try:
            time.sleep(random.random()+5)
            coin_name=driver.find_elements_by_css_selector(".title.mr-2")
            for coin in coin_name:
                coin_names.append(coin.text)
            if 'BERMUDA' in coin_names[-1]: 
                i+=1
            else:
                i_uns+=1
        except:
            coin_names.append("Connection ErrorPage")
            i_uns+=1
        
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(random.random()+10)   
        driver.execute_script("window.scrollTo(0, 0);")
        time.sleep(random.random()+35)
        driver.find_element_by_css_selector('.is-flex.tag.is-small.mr-2').click()
        time.sleep(random.random()+5)
        ##driver.execute_script("window.history.go(-1)")
        print(i+i_uns,". Click with ",ipList[-1]," IP",coin_names,"Success:",i,"Unsuccess:",i_uns)
    except Exception as e:
        print("[Error]:{} ".format(e))
    finally:
        for handle in driver.window_handles:
            driver.switch_to.window(handle)
            driver.close()
        ########
        #os.system('ip -6 addr del {} dev ens32'.format(ipList[-1]))
        pass    
        


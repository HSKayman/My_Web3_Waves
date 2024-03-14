# -*- coding: utf-8 -*-
"""
Created on Wed May 11 01:28:37 2022

@author: Suca
"""
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
#from pypasser import reCaptchaV2
from selenium import webdriver
import warnings
#from requests import session
warnings.filterwarnings("ignore")

options = Options()

options.add_argument("--window-size=600,1000")
#options.headless = True
options.add_experimental_option('prefs',  {
    "download.prompt_for_download": False,
    "plugins.always_open_pdf_externally": True
    }
)
##https://certik-public-assets.s3.amazonaws.com/CertiK-Audit-for-Matic-Staking-Contract.pdf
driver = webdriver.Chrome(executable_path='chromedriver.exe',options=options)
driver.get("https://www.certik.com/")
#driver.maximize_window()
for index in range(69):
    for i in range(2,32):
        driver.implicitly_wait(5)
        try:
            WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[4]/div/div[2]/div/div[2]/div/div/div[1]/button")).click()#pop up
            WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[5]/a")).click()#accept
            
        except:
            pass 
        
        WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[5]/div/div/div[1]/div/div[2]/div/div[1]/div/div/div/div/div/div/table/tbody/tr[{}]/td[2]/div/div[2]/a".format(i))).click()#coins
        driver.implicitly_wait(5)
        parentdiv=1
        try:                                                                          
            parentdiv=len(WebDriverWait(driver,10).until(lambda d: d.find_elements(by=By.XPATH, value="/html/body/div[1]/div/div[4]/section[1]/div/div[2]/div/div/div[1]/div/div[1]/div[2]/div/div/div")))#auidit sayisi
        except:
            parentdiv=1
            pass
        try:
            WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[4]/div/div[2]/div/div[2]/div/div/div[1]/button")).click()#pop up
            WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[5]/a")).click()#accept
            
        except:
            pass 
        for j in range(2,parentdiv+2):
            print(i,j)
            driver.implicitly_wait(10)
            try:
                WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[4]/div/div[2]/div/div[2]/div/div/div[1]/button")).click()#pop up
                WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[5]/a")).click()#accept
                
            except:
                pass
            #driver.execute_script("window.scrollTo(0, 1800);")
            driver.implicitly_wait(5)
            element = WebDriverWait(driver, 20).until(
            EC.element_to_be_clickable((By.XPATH, "/html/body/div[1]/div/div[4]/section[1]/div/div[2]/div/div/div[2]/div/div/div/div[1]/div[2]/div/button")))#view pdf
            driver.execute_script("arguments[0].click();", element)
            #element.click()
            try:
                WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[4]/div/div[2]/div/div[2]/div/div/div[1]/button")).click()#pop up
                WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[5]/a")).click()#accept
                
            except:
                pass
                    
            driver.implicitly_wait(5)
            #WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[4]/section[1]/div/div[2]/div/div/div[2]/div/div/div/div[1]/div[2]/div/div/div/div[2]/button")).click()#change audit
            if  j!=parentdiv+1:                                                                         
                                                                                                        
                element = WebDriverWait(driver,20).until(lambda d: d.find_element(by=By.XPATH, value='//*[@id="audit"]/div/div[2]/div/div/div[1]/div/div[1]/div[2]/div/div/div[{}]/a/div[1]'.format(j)))
                driver.execute_script("arguments[0].click();", element)
                #element.click()
                driver.implicitly_wait(10)   
            try:
                WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[4]/div/div[2]/div/div[2]/div/div/div[1]/button")).click()#pop up
                WebDriverWait(driver,10).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[5]/a")).click()#accept
                
            except:
                pass                                  
            #geri gelme kodu
        driver.execute_script("window.history.go(-1)")
    driver.implicitly_wait(10)
    WebDriverWait(driver,100).until(lambda d: d.find_element(by=By.XPATH, value="/html/body/div[1]/div/div[5]/div/div/div[1]/div/div[2]/div/div[2]/div[2]/div/ul/li[9]/button")).click()#next page change audit
    


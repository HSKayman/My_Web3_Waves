from bs4 import BeautifulSoup
from requests import get
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import time

# def ABIfinder(address,isMain):

#     chrome_options = Options()
#     chrome_options.add_argument("--headless") 
#     chrome_path = './chromedriver.exe'
#     driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
#     if isMain:
#         url ="https://api.bscscan.com/api?module=contract&action=getabi&address={}".format(address)
#         stawrtWith=93
#     else:
#         url ="https://api-testnet.bscscan.com/api?module=contract&action=getabi&address={}".format(address)  
#         stawrtWith=39
#     driver.get(url)
#     result = driver.find_element_by_tag_name('pre').text
#     driver.close()
#     return result[stawrtWith:-2].replace('\\\\',"").replace("\\","")

def ABIfinder(address,isMain):

     if isMain:
         url ="https://api.bscscan.com/api?module=contract&action=getabi&address={}".format(address)
     else:
         url ="https://api-testnet.bscscan.com/api?module=contract&action=getabi&address={}".format(address) 
        
     data=requests.get(url)
     abi=data.json()['result']
     return abi
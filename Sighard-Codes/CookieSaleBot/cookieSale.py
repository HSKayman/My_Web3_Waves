"""
Created on Thu Apr 14 20:49:56 2022

@author: HTM
"""
import asyncio
from aiogram import Bot, Dispatcher
from aiogram.types import ParseMode
from aiogram.utils import executor
import nest_asyncio
import time
nest_asyncio.apply()
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
import warnings
import json
warnings.filterwarnings("ignore")
print("Bot just Started...")
bot: Bot
dp: Dispatcher
channel_id: int
INTERVAL: int

async def startBot():
    while True:
        
       
        try:
            driver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
            New=False
            for network in networks:
                for itype in types:
                    driver.get("https://cookiesale.io/{}?chain={}".format(itype,network))
                    WebDriverWait(driver,100).until(lambda d: d.find_element_by_xpath("//div[@class = 'tokenCard_cardWrapper__34P3P']"))
                    tokenCards=driver.find_elements(By.XPATH,"//div[@class = 'tokenCard_cardWrapper__34P3P']")
                    for numberOfTokenCard in range(1,len(tokenCards)+1):
                        
# =============================================================================
#                             Connection Token URL
# =============================================================================
                        WebDriverWait(driver,100).until(lambda d: d.find_element_by_xpath("//*[@id='root']/div[2]/section/main/div[5]/div[{}]/div[4]/a/div/a".format(numberOfTokenCard)))
                        tokenSites=driver.find_element_by_xpath('//*[@id="root"]/div[2]/section/main/div[5]/div[{}]/div[4]/a/div/a'.format(numberOfTokenCard)).get_attribute('href')
                        if tokenSites in dictionary['CookieSale Link']:
                            break
                        else:
                            New=True
                        try:
                            tokenSitesDriver = webdriver.Chrome(executable_path=chrome_path, options=chrome_options)
                            tokenSitesDriver.get(tokenSites)
                            
# =============================================================================
#                             Presales Address
# =============================================================================
                            WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_element_by_xpath("//*[@id='root']/div[2]/div/div[3]/div[1]/div[1]/div[1]"))
                            tokenFeatureCard=tokenSitesDriver.find_element(By.XPATH,"//*[@id='root']/div[2]/div/div[3]/div[1]/div[1]/div[1]")
                            WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_element_by_xpath("//*[@id='root']/div[2]/div/div[3]/div[1]/div[1]/div[2]/a"))
                            tokenInfoCard=tokenSitesDriver.find_element(By.XPATH,"//*[@id='root']/div[2]/div/div[3]/div[1]/div[1]/div[2]/a")
                            time.sleep(3)
                            if tokenFeatureCard.text in dictionary.keys():
                                dictionary[tokenFeatureCard.text].append(tokenInfoCard.text)
                            else:
                                dictionary[tokenFeatureCard.text]=['' for element in range(len(dictionary['Number'])-1)]
                                dictionary[tokenFeatureCard.text].append(tokenInfoCard.text)
                                
# =============================================================================
#                             Token Address
# =============================================================================                           
                            WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_element_by_xpath("//*[@id='root']/div[2]/div/div[3]/div[1]/div[5]/div[1]"))
                            tokenFeatureCard=tokenSitesDriver.find_element(By.XPATH,"//*[@id='root']/div[2]/div/div[3]/div[1]/div[5]/div[1]")
                            WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_element_by_xpath('//*[@id="root"]/div[2]/div/div[3]/div[1]/div[5]/div[2]/a'))
                            tokenInfoCard=tokenSitesDriver.find_element(By.XPATH,'//*[@id="root"]/div[2]/div/div[3]/div[1]/div[5]/div[2]/a')
                            
                            time.sleep(15)
                            if tokenFeatureCard.text in dictionary.keys():       
                                dictionary[tokenFeatureCard.text].append(tokenInfoCard.text)
                            else:
                                dictionary[tokenFeatureCard.text]=['' for element in range(len(dictionary['Number'])-1)]
                                dictionary[tokenFeatureCard.text].append(tokenInfoCard.text)
                                
# =============================================================================
#                           Other Specializiation       
# =============================================================================
                            WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_element_by_xpath("//div[@class='infoToken_leftDataItem__e_HRq']//*[@class = 'infoToken_leftDataItemTitle__t1aq0']"))
                            tokenFeatureCards=tokenSitesDriver.find_elements(By.XPATH,"//div[@class='infoToken_leftDataItem__e_HRq']//*[@class = 'infoToken_leftDataItemTitle__t1aq0']")
                            WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_element_by_xpath("//div[@class='infoToken_leftDataItem__e_HRq']//*[@class = 'infoToken_leftDataItemValue__2ldAK false']"))
                            tokenInfoCards=tokenSitesDriver.find_elements(By.XPATH,"//div[@class='infoToken_leftDataItem__e_HRq']//*[@class = 'infoToken_leftDataItemValue__2ldAK false']")
                            #General
                            for index,tokenInfoCard in enumerate(tokenInfoCards):
                                time.sleep(3)
                                if tokenFeatureCards[index].text in dictionary.keys():
                                    dictionary[tokenFeatureCards[index].text].append(tokenInfoCard.text)
                                else:
                                    dictionary[tokenFeatureCards[index].text]=['' for element in range(len(dictionary['Number'])-1)]
                                    dictionary[tokenFeatureCards[index].text].append(tokenInfoCard.text)
                            
# =============================================================================
#                             Telegram
# =============================================================================
                            WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_elements_by_xpath("//*[@id='root']/div[2]/div/div[1]/div[2]/div[1]/div/div[1]/div[2]/div[2]/ul/li"))
                            websites=tokenSitesDriver.find_elements(By.XPATH,"//*[@id='root']/div[2]/div/div[1]/div[2]/div[1]/div/div[1]/div[2]/div[2]/ul/li")
                            for index in range(1,len(websites)+1):
                                WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_elements_by_xpath("//*[@id='root']/div[2]/div/div[1]/div[2]/div[1]/div/div[1]/div[2]/div[2]/ul/li[{}]".format(index)))
                                website=tokenSitesDriver.find_element(By.XPATH,"//*[@id='root']/div[2]/div/div[1]/div[2]/div[1]/div/div[1]/div[2]/div[2]/ul/li[{}]/a".format(index)).get_attribute('href')
                                time.sleep(3)
                                if  "https://t.me" in website:
                                    dictionary['Telegram'].append(website)
                                    break
                            else:
                                dictionary['Telegram'].append('')
                            
# =============================================================================
#                             Website
# =============================================================================
                            for index in range(1,len(websites)+1):
                                WebDriverWait(tokenSitesDriver,100).until(lambda d: d.find_elements_by_xpath("//*[@id='root']/div[2]/div/div[1]/div[2]/div[1]/div/div[1]/div[2]/div[2]/ul/li[{}]".format(index)))
                                website=tokenSitesDriver.find_element(By.XPATH,"//*[@id='root']/div[2]/div/div[1]/div[2]/div[1]/div/div[1]/div[2]/div[2]/ul/li[{}]/a".format(index)).get_attribute('href')
                                
                                if  not 'jpg' in website and not 'png' in website and not 'svg' in website and not "t.me" in website and not "instagram" in website and not "twitter" in website and not "reddit" in website and not "facebook" in website and not "discord" in website and not "github" in website:
                                    dictionary['Website'].append(website)
                                    break
                            else:
                                dictionary['Website'].append('')
                            
                            dictionary['Number'].append(dictionary['Number'][-1]+1)
                            dictionary['CookieSale Link'].append(tokenSites)
                            dictionary['BlockChain'].append(network)
# =============================================================================
#                             Print
# =============================================================================
                            message=""
                            for key in [
                                        #"Presale Address :",
                                            "Telegram :",
                                            "Token Name :",
                                            #"Decimal :",
                                            "Token Address :",
                                            #"Total Supply :",
                                            #"Token For Presale :",
                                            #"Token For Liquidity :",
                                            "Presale Rate :",
                                            "Listing Rate Data :" ,
                                            "Soft Cap :",
                                            "Hard Cap :",
                                            #"Unsold Tokens :",
                                            "Presale Start Time :",
                                            "Fair Launch Start Time :",
                                            "Presale End Time :",
                                            "Fair Launch End Time :",
                                            #"Listing On :",
                                            "Liquidity Percent :",
                                            "Liquidity Lockup Time :",
                                            "BlockChain :",
                                            "CookieSale Link :"]:
                                
                                if key[:-2] in dictionary :
                                    if dictionary[key[:-2]][-1]!='':
                                        if key=="Token Address :":
                                            message+=f"<b>{key}</b> <a href='{tokenSites}'>{dictionary[key[:-2]][-1]}</a>\n"    
                                        elif key=="Token Name :":
                                            message+=f"<b>{key}</b>{dictionary[key[:-2]][-1]} ({dictionary['Token Symbol'][-1]})\n"
                                            
                                        elif key=="CookieSale Link :":
                                            message+=dictionary[key[:-2]][-1]+'\n'
                                        else:
                                            message+="<b>"+key+"</b>"+dictionary[key[:-2]][-1]+'\n'
                                    
                            await bot.send_message(channel_id,message)    
                        except Exception as e:
                            print('[E]1',e)
                        finally:
                            try:
                                tokenSitesDriver.close()
                            except Exception as e:
                                print('[E]2',e)
                
                        
                
        except Exception as e:
            print('[E3]',e)
        finally:
            try:
                if New:
                    json.dump({'CookieSale Link':dictionary['CookieSale Link']}, open("log.bin",'w'))
                driver.close()
            except Exception as e:
                print('[E]4',e)
        
    await asyncio.sleep(INTERVAL)
    
              
                            
def init():
    

    global dictionary, networks, types, chrome_path, chrome_options,dp,INTERVAL,channel_id,bot,df,New,driver,tokenSitesDriver
    New=False
    channel_id='-781239365'
    try:
        with open('log.bin') as f:
            dictionary = {'Number':[0],'Telegram':[],'Website':[],'CookieSale Link':[],'BlockChain':[]}
            dictionary['CookieSale Link']=json.load(open("log.bin"))['CookieSale Link']
            
    except:
        print("File not accessible")
        dictionary = {'Number':[0],'Telegram':[],'Website':[],'CookieSale Link':[],'BlockChain':[]}
        
    networks=['BSC','POLYGON','AVALANCHE','BSCTESTNET']
    types=['presales']
    chrome_path = 'chromedriver.exe'
    chrome_options = Options()
    chrome_options.add_argument("--headless") 
    bot = Bot(token='5108355601:AAEhtIxjAtv1Q_nf7gFCsCwRG628_puosLI', parse_mode=ParseMode.HTML)
    dp = Dispatcher(bot)



async def on_bot_start_up(dispatcher) -> None:
    asyncio.create_task(startBot())



init()
executor.start_polling(dp, skip_updates=True, on_startup=on_bot_start_up)
    



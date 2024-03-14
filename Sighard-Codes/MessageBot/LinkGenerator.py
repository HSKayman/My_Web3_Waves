# -*- coding: utf-8 -*-
"""
Created on Mon Aug 29 01:19:09 2022

@author: HSK
"""

import asyncio
from aiogram import Bot
from aiogram.types import ParseMode
from aiogram.utils import executor
from datetime import datetime,timedelta
import nest_asyncio
import random
nest_asyncio.apply()
bot: Bot




bot = Bot(token='5555577607:AAEadcXdUIBtQFXo6EnJL84pjHE2ydVxZa0', parse_mode=ParseMode.HTML)#reel
time= expire_date = datetime.now() + timedelta(weeks=1)
x =  await bot.create_chat_invite_link(channel_id,member_limit=1,expire_date=time)
print(x['invite_link'])
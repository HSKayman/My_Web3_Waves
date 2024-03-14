# -*- coding: utf-8 -*-
"""
Created on Tue Sep 27 11:36:25 2022

@author: HSK
"""

import pandas as pd
import numpy as np
import json
df=pd.read_csv("Aetherius Holders Final.csv")
df['HolderAddress']
df['HolderAddress'] =df['HolderAddress'].drop(list(df['HolderAddress'][df['HolderAddress'].str.contains('E+')==True].index),axis=0)
df['HolderAddress'] =df['HolderAddress'].drop(list(df['HolderAddress'][df['HolderAddress'].str.contains('E-')==True].index),axis=0)  
df

k=df['Balance']
k=k.apply(lambda x: "".join(x.replace(',',''))).astype(np.longdouble)
df['Balance']=k
#df['Balance']=df['Balance'].values.dtypes(int)
#df['Balance'].values.dtypes(float).sum()
df=df.dropna(axis=0)
array={}
count=0
for i,j in df.values:
    if i in array:
        array[i]+=j  
    else:
        array[i]=j
    count+=1
for i in array:
    array[i]=str(array[i])
print(count)


r = json.dumps(array)
json.dump(r.replace("\\",""), open("balance.txt",'w'))




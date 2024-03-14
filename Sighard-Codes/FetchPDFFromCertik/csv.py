import os
import pandas as pd


dictionary={}
dictionary['id']=[]
dictionary['Name']=[]
dictionary['link']=[]
dictionary['text']=[]

for index,i in enumerate(os.listdir("./text/")):
    print(index)
    dictionary['id'].append(index)
    dictionary['Name'].append(i[:-11])
    dictionary['link'].append("https://certik-public-assets.s3.amazonaws.com/"+i[:-11]+".pdf")
    
    file = open("./text/"+i, 'r',encoding="utf-8")
    lines = file.readlines()
    file.close()
    t=""
    for j in lines:
        t+=j.replace(";", "").replace('\n', "").replace('\t',"").replace('\r', '')
    dictionary['text'].append(t)
    
df=pd.DataFrame.from_dict(dictionary)
df.to_csv('certic.csv')  


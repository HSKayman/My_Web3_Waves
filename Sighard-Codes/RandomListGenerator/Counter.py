
import json

number={}
lock={}
for i in range(0,10):
    number[i]=0
    lock[i]=[]


with open('Variant.json') as f:
    Input=json.load(f)
    
    
    
for index,i in enumerate(Input["variant"]):
    flag=True
    for k in range(1,10):
        c=0
        for j in i:
            if j==k:
                c+=1
        if c==3:
            number[k]+=1
            lock[k].append(index)
            flag=False
    if flag:
        number[0]+=1
        lock[0].append(index)
        
    
        
        
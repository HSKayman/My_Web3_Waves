

import random
import json


GeneratingList=[]

for j in range(569):#Burasi
    k=0
    element=[1,2,3,4,5,6,7,8,9]
    countList=[0,0,0,0,0,0,0,0,0,0]
    OneElement=[]
    while k<9:
        randomint = random.randint(0,len(element)-1)
        if (countList[element[randomint]]==2):
            element.remove(element[randomint])
            continue
        OneElement.append(element[randomint])
        countList[element[randomint]]+=1
        k+=1
    random.shuffle(OneElement)
    GeneratingList.append(OneElement)

    
Probality={7:1,3:30,1:50,4:150,9:200}#Burasi
i=0
for j in Probality:
    i=0
    while(i<Probality[j]):
        element=  [1,2,3,4,5,6,7,8,9]
        countList=[0,0,0,0,0,0,0,0,0,0]
        OneElement=[]
        OneElement.extend([j,j,j])
        countList[j]=3
        element.remove(j)
        k=3
        while k<9:
            randomint = random.randint(0,len(element)-1)
            if (countList[element[randomint]]==2) :
                element.remove(element[randomint])
                continue
            OneElement.append(element[randomint])
            countList[element[randomint]]+=1
            k+=1
        random.shuffle(OneElement)
        GeneratingList.append(OneElement)
        i+=1


    
Output={}
Output["variant"]=GeneratingList
json.dump(Output,open("Variant.json",'w'))
    

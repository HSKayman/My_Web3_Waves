import json


count=0
link=[]
for k in range(1,22):
    with open('{}.json'.format(k),encoding="utf8") as f:
        a=json.load(f)
        
    if k==1:
        for i in a["pageProps"]["top100OnboardedProjects"]:
            
            for j in i["audits"]:
                try:
                    print(count,j['reportLink'])
                    link.append(j['reportLink'])
                except:
                    print(j['id'])
                count+=1
    else:   
        for i in a["results"]:
            for j in i["audits"]:
                try:
                    print(count,j['reportLink'])
                    link.append(j['reportLink'])
                except:
                    print(j['id'])
                count+=1
print(count)
count=0
with open('links.txt', 'w',encoding="utf8") as f:
    for item in link:
        try:
            f.write("%s\n" % item)
        except:
            print(count,item)
            count+=1
            pass



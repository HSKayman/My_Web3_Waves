import urllib.request

def download_file(download_url, filename):
    response = urllib.request.urlopen(download_url)    
    file = open("D:\\Work&Study\\Jobs\\Checker\\Sighard-Contracts\\FetchPDFFromCertik\\pdfs\\"+filename[:-2] + ".pdf", 'wb')
    file.write(response.read())
    file.close()
 
with open('links.txt',encoding="utf-8") as f:
    lines = f.readlines()

for index, pdf_path in enumerate(lines[265:]):
    try:
        print(265+index,pdf_path)
        download_file(pdf_path, pdf_path.split("/")[-1])
    except:
        print(pdf_path)

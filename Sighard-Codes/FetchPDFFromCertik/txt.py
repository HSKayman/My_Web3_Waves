# -*- coding: utf-8 -*-
"""
Created on Sun Jul  3 18:42:58 2022

@author: suca
"""
import PyPDF2 
import os

for index,i in enumerate(os.listdir("./pdfs/")):
    try:
        print(i)
        pdfFileObj = open("./pdfs/"+i, 'rb') 
        text=""
        
        pdfReader = PyPDF2.PdfFileReader(pdfFileObj) 
        for j in range(pdfReader.numPages):
            pageObj = pdfReader.getPage(j) 
            text += pageObj.extractText()+"\n"
        print(index)
        file = open("./text/"+i+".txt", 'w',encoding="utf-8")
        file.write(text)
        file.close()
        
    except:
        pass
    
    


'''
Emma Schumacher
Katzlab
10/01/2021

Code to find repeated 10 digit codes in every file in a folder and copy
Only the measurement with the highest coverage value to a filtered file
Reference: https://biopython.org/docs/1.75/api/Bio.SeqRecord.html
'''

from Bio import SeqIO
import sys
import os

#path to the folder you are keeping the files in- PLEASE EDIT FOR YOUR DEVICE
path = "/Users/emmaschumacher/Desktop/fasta"
os.chdir(path)

#loops through the files in the directory just opened
for filename in os.listdir():
    #checks all the files parsed are fasta types
    if filename.endswith(".fasta"):
    
        #turns all the lines into a list of genome objects called records
        records = list(SeqIO.parse(filename, 'fasta')) 

        #initializes filtered_records dictionary to contain non-duplicated objects
        filtered_records = {}
        final_records = {}

        #reads through records object by object
        for line in records: 
            #gets the 10 digit code name and the coverage number
            name = line.id[0:10]  
            cov = int(line.id[line.id.index("_Cov")+4:line.id.index("_OG5")])
            
            #if the name is shared with a previously seen object
            if name in filtered_records: 
                #if new instance has a higher coverage, replaces the old coverage value
                if cov > filtered_records[name]:
                    filtered_records[name] = cov 
                    final_records[name] = (line)
            #if the name is not shared with a previously seen object, updates dictionary
            else: 
                filtered_records.update({name:cov})
                final_records.update({name:(line)})
                
        #creates filtered file with final list objects
        filestarter = filename[:filename.index('.fas')]
        for code in final_records.values():
            #edits the name of each file produced by adding _filtered to the old name
            with open(filestarter + "_filtered.fasta", "a") as final_file:
                final_file.write(code.format("fasta") + "\n")
    
                 
# python3 remove_duplicates_multi.py



# Emma Schumacher
# Katzlab
# SURF 2022
# Last run 11/17/23
# Code to create one fasta from Taylor's hand curated xlsx
# Corrected for new naming and repeat errors

import pandas as pd  # used to convert a .tsv 
from Bio import SeqIO
import sys
import os
from openpyxl import Workbook

def writeto(myfasta, filtertaxa): 
    
    try: 
        listed = [f'>{i.id}\n{i.seq}\n' for i in SeqIO.parse(myfasta, 'fasta')  if filtertaxa in i.id]
    
        with open('SortaHandCurated.fas', 'a+') as fas:
            fas.write(''.join(listed) + '\n') 
    
    except:
        print(f'Cannot open {myfasta} please check the spreadsheet and folder.\n')
        
#does the filtering
def filters(fn, folder, filtertaxa): 
    # Workbooks are created 
    #if '.DS_Store' not in fn:
    rdf = pd.read_excel(fn, engine='openpyxl')  # source of data
    rdf.head()
    
    # filters  
    
    rdf_filtered1 = rdf[(rdf['Tip_Count'] == 1) & (rdf['Description'].isnull())]
    rdf_filtered2a = rdf[(rdf['Tip_Count'] == 2) & (rdf['Description'].astype(str).str.startswith('Am_t', na = False))]
    rdf_filtered2b = rdf[(rdf['Tip_Count'] == 2) & (rdf['Description'].astype(str).str.contains('paralog', na = False))]
    
    
    # Makes filtered spreadsheet 
    name = str(fn[:-5]) + "_Fltr.xlsx"
    print(name)
    
    # troubeshoot
    with pd.ExcelWriter(name, engine='openpyxl', mode = 'w+') as writer:  
        rdf_filtered1.to_excel(writer, sheet_name = 'Filtered Table 1')
        rdf_filtered2a.to_excel(writer, sheet_name = 'Filtered Table 2a')
        rdf_filtered2b.to_excel(writer, sheet_name = 'Filtered Table 2b')

    #makes a file for the fastas
    #fasta = open('shrunkfasta.fas', 'w+')
    
    simple_tip_list = rdf_filtered1['OG'].tolist() + rdf_filtered2b['OG'].tolist()
    print(simple_tip_list)
    
    open('SortaHandCurated.fas', 'w').close()
    
    #gets single file 
    for myfile in simple_tip_list: 
        #cheap fix
        myfile = myfile.replace('_clade_', '_preguidance_') 
        
        myfasta = f'{folder}/{myfile}.fas_filtered_NTD.fasta'
        writeto(myfasta, filtertaxa)
        
        
    specific_tip_list = dict(zip(rdf_filtered2a['OG'], rdf_filtered2a['Description']))
    
    for myfile, seqns in specific_tip_list.items(): 
        #cheap fix
    	myfile = myfile.replace('_clade_', '_preguidance_') 
        myfasta = f'{folder}/{myfile}.fas_filtered_NTD.fasta'
        writeto(myfasta, seqns)

    
# main function for coding hygeine
if __name__ == "__main__":
    ### USER INPUT HERE ###
    
    # Name of the excel sheet you want to filter
    fn = sys.argv[1] #'ExampleTable.xlsx' 
    folder = sys.argv[2] #'/Users/katzlab32/Desktop/taylor/Preguidance_final_NTDs'
    filtertaxa = sys.argv[3] #'Hp03'
    filters(fn, folder, filtertaxa)
    


        
 
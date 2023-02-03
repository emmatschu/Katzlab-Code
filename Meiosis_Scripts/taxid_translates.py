"""
Translate taxids in fasta files into the ncbi taxon names
Written by Caitlin Timmons, updated by Emma Schumacher May 2021
"""

from Bio import SeqIO
from ete3 import NCBITaxa

ncbi = NCBITaxa()
#used for initial install on a computer, otherwise a waste of time
#ncbi.update_taxonomy_database() 

#does the translation
def main(original_file, corrected_file):

    with open(original_file) as original, open(corrected_file, 'w') as corrected:
        records = SeqIO.parse(original_file, 'fasta')
        
        for record in records:
            taxid = record.id.split(".")
            gene_name = taxid[1].split("_")[-1]
            translated_id = ncbi.get_taxid_translator([taxid[0]])
            record.id = str(list(translated_id.values())[0])  + " gene " + str(gene_name)
            record.description = ""
            SeqIO.write(record, corrected, 'fasta')

#preps file to be translated (" " --> "_")
def check(original_file): 
    
    with open(original_file, "rt") as of:
        contnts = of.read() 
        contnts = contnts.replace(' ', '_')
        
    with open(original_file, "wt") as of:
        of.write(contnts) 
            

if __name__ == '__main__':
    
    ### USER INPUT HERE ###
    original_file = "combined_spo11taxid.fasta"

    #automates renaming, optionals
    corrected_file = original_file.split(".fas")[0] + "translated.fasta"

    #preps file to be translated (" " --> "_")
    check(original_file)

    #does the translation
    main(original_file, corrected_file)    

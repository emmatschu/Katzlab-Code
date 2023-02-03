# AUTHOR: Caitlin Timmons and Emma Schumacher
# Purpose: BLAST against Katzlab hook database to identify best hit OGs for a protein sequence
# Usage: python iqtree_automate.py <folder with alignments>

import os
import sys

#does the translation
def main(folder, alignment):    
	
	# USER input: 
	
	# makes folders to store the diamond output
	if not os.path.exists('treefiles'):
		os.makedirs('treefiles') 
		
	os.system('iqtree -s ' + folder+"/"+alignment + " -m LG+G") 


def automate(folder):
	tranfiles = []
	path = os.getcwd() + '/' + folder
	for file in os.listdir(path):
		if not file.startswith('.'):
			if file.endswith("fas"):  
				tranfiles.append(file)
	
	for alignment in tranfiles:  
		main(folder, alignment)
	


if __name__ == '__main__':
	input_folder = sys.argv[1]
	automate(input_folder)
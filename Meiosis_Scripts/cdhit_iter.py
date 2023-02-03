"""
Run cdHit on all the fastas in a folder for meiosis genes specifications
Meant to be run after length_bar_violin_plots_combo_iter.py
By Emma Schumacher
SURF 2022
"""

from Bio import SeqIO
from ete3 import NCBITaxa
import os

ncbi = NCBITaxa()
#used for initial install on a computer, otherwise a waste of time
#ncbi.update_taxonomy_database() 

#does the translation
def main(folder, fasta, c = 0.95, n = 5):    
	# makes folders to store the cdHit stuff and output folders so it doesn't get cluttered
	if not os.path.exists('cdHit'):
		os.makedirs('cdHit') 
	
	
	outfast = 'cdHit/' + fasta + '.cdHit'
	os.system('cd-hit-est -i ' + folder + '/' + fasta + ' -o ' + outfast + ' -c ' + str(c) + ' -n ' + str(n)) 
	# deletes cluster file (we don't use)
	os.system('rm -r ' + outfast + '.clstr')

	# renames CD Hit file
	os.rename(outfast, str(outfast[:-12] + '.cdHit.fasta'))

def automate(folder):
	tranfiles = []
	path = os.getcwd() + '/' + folder
	for file in os.listdir(path):
		if not file.startswith('.'):
			if file.endswith("fasta"):  
				tranfiles.append(file)
	
	for thing in tranfiles:  
		main(folder, thing)
	


if __name__ == '__main__':
	automate('random_subsamps')

#cd-hit-est -G 0 -c 0.97 -aS 1.0 -aL 0.005 -i translated/Hormad1Euktranslated.fasta -o cdHit/Hormad1Euktranslated.fasta.cdHit

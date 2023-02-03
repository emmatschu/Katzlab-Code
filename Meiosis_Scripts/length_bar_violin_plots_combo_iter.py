"""Produce size tsvs but no plots"""
# Katzlab SURF 2022
# Created by Emma Schumacher 05/17/22
# Updated by ETS 05/12/22
# Meant to be run after taxid_translates_iter.py

#Import statements...
from Bio import SeqIO
import matplotlib 
matplotlib.use('TkAgg') #so i dont have to change to backend 
import matplotlib.pyplot as plt #matplot
import pandas as pd
import seaborn as sns
from random import sample
import pathlib
from pathlib import Path
import os
import shutil


'''used to get size of sample (20 % unless the sample is <100 seq or if the sample is >500)'''
def get_sampsize(og_fasta_file):
	# count up sequences
	i = 0
	with open(og_fasta_file) as f:
		for line in f:
			if line.startswith(">"):
				i += 1
	# makes sure the sample is big enough
	if (i > 100):
                # sample would be too big (>500)
                if (i > 2500):
                        s_size = 500
                
                else:
                        s_size = int(i * 0.2)
	else:
		s_size = i 

	print(og_fasta_file[(og_fasta_file.index('ated/') + 5):(og_fasta_file.index('_tran'))] + " " + str(s_size) + " " + str(i)) 
	
	return (s_size)
	

'''used to randomly sample some number of OGs from fasta to make stuff run better'''
def get_random(og_fasta_file, ssize, multi = None):
	#ogpath = Path(og_fasta_file).parent.absolute()
	#print(ogpath)
		
	if not multi:
		name = 'random_subsamps/' + og_fasta_file[og_fasta_file.index('lated/') + 5:og_fasta_file.index(".fasta")] + "smallerseq.fasta"
	else:
		name = 'random_subsamps/' + og_fasta_file[og_fasta_file.index('lated/') + 5:og_fasta_file.index(".fasta")] + str(multi) + "smallerseq.fasta" 

	#open(name, "w") #str(Path(og_fasta_file).parent) + name
	corrected_file = name
	
	with open(og_fasta_file, "r") as original, open(corrected_file, 'w') as corrected:
		seqs = SeqIO.parse(og_fasta_file, "fasta")
		
		for seq in sample(list(seqs), ssize):
			SeqIO.write(seq, corrected, 'fasta')
			
	return(corrected_file)

# Provide a FASTA file of sequences, along with an OG number, to make a quick
# table of sequence lengths (note this is per OG).
def get_sizes(fasta_file, og_number): 
	# Snag the sequence names and their lengths from a given FASTA file.
	# Note that you can convert the dictionary into a dataframe, but that is
	# more of a pain...
	seq_sizes = {i.id:len(i.seq) for i in SeqIO.parse(fasta_file,'fasta')}
		
	# Save the data as a spreadsheet with Tab-Separated-Values (TSV)
	with open(f'size_tsv/{og_number}.SeqLength.tsv','w+') as w:
		w.write('OG\tSequence_Name\tLength\tDomain\n')

		for k, v in seq_sizes.items():
			# Add in the taxonomic "domains" when possible! This is mostly for
			# fancy plotting. 
			if k[:2] == 'Ba':
				w.write(f'{og_number}\t{k}\t{v}\tBacteria\n')

			elif k[:2] == 'Za':
				w.write(f'{og_number}\t{k}\t{v}\tArchaea\n')

			else:
				w.write(f'{og_number}\t{k}\t{v}\tEukaryota\n')
		return('size_tsv/' + og_number + ".SeqLength.tsv")

#used to call size tsvs for multiple files 
def make_multiple_OGs_sizes(fasta_files, og_number, runs):
	all_OG_tsvs = []
	
	if not os.path.exists('size_tsv'):
		os.makedirs('size_tsv')
		
	if (runs == 1):
		# Calls function to make a tsv for next function
		get_sizes(fasta_files.pop(), og_number)
		all_OG_tsvs.append(og_number + ".SeqLength.tsv")
	else:
		for i in range(0,runs):
			get_sizes(fasta_files.pop(), (og_number + "run_" + str(i)))
			all_OG_tsvs.append(og_number + "run_" + str(i) + ".SeqLength.tsv")
	return (all_OG_tsvs)

#used to call multiple random samples, great for seeing if distributions are consistent
def make_multiple_randoms(file, runs, size):
	all_samples = []
	if (runs == 1):
		# Calls function to make a tsv for next function
		fn = get_random(file, size)
		all_samples.append(fn)
		
	if not os.path.exists('random_subsamps'):
		os.makedirs('random_subsamps')
		
	else:
		for i in range(0, runs):
			fn = get_random(file, size, multi = i)
			all_samples.append(fn)
	return (all_samples) 
 
def automate(path, og_number, runs):
	myfiles = [] 
	folder = pathlib.PurePath(path)
	for file in os.listdir(path):
		if not file.startswith('.'):
			if file.endswith("fasta"):  
				myfiles.append(str(folder) + '/' + file)
	
	for thing in myfiles:  
		main(thing, og_number.pop(), runs)

'''main function, does sample size finding and then calls functions'''
def main(og_fasta_file, og_number, runs):
	if (runs == 0):
		get_sizes(og_fasta_file, og_number) 
	
	else:
		#gets sample size
		size = get_sampsize(og_fasta_file)
		
		#gets a random sample
		fasta_files = make_multiple_randoms(og_fasta_file, runs, size)
		
		# Calls function to make a tsv for next function
		all_OG_tsvs = make_multiple_OGs_sizes(fasta_files, og_number, runs) 
 
'''main main function, where user input goes'''
if __name__ == '__main__':
	## EDIT HERE: Put your fasta files into an input folder and add the path
	path = os.getcwd() + "/translated/"
	
	## EDIT HERE: Modify this so it is whatever label you want on your X axis, if you want to run
	# multiple different use a list of names []
	og_number = [] 
	for file in os.listdir(path):
		if not file.startswith('.'):
			if file.endswith("fasta"): 
				og_number.append(str(file[:file.index('_trans')]))
				 
				
	## EDIT HERE: However many random samples you want (if none, 0)
	runs = 3
	
	if len(og_number) > 1:
		automate(path, og_number, runs)
	else:
		main(thing, og_number.pop(), runs)


	
	









	

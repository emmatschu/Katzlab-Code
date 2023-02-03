'''
Code to run Hisat2 for FPRE & RPE files
Written by Emma Schumacher & Angela Jiang
06/01/22
'''

import os
import subprocess
import sys
from Bio import SeqIO 

#documentation:
#run database first
#make a folder. within that folder create a folder called sequences with all the trimmed reads
#in terminal, type python3 pythonclub6.py (directory of folder with sequences folder in it, with / at the end)

''' Does file work '''
def main(direc):
	# inititlaizes dictionaries
	fpe = {}
	rpe = {} 
	
	# gets all the .gz files in a list
	rpe =  {i[:i.index('_')] : i for i in os.listdir(direc) if ((os.path.splitext(i)[1] == '.gz') & ('RPE' in i))}
	fpe =  {i[:i.index('_')] : i for i in os.listdir(direc) if ((os.path.splitext(i)[1] == '.gz') & ('FPE' in i))}

	# checks for stupid mistakes
	if len(rpe) != len(fpe):
		raise Exception("You do not have an FPE for every RPE in this folder- please correct this and try again")
	
	#iterates through dictionaries
	for key in rpe:
		actualwork(fpe.get(key), rpe.get(key), key, direc)

''' Runs the hisat 2 stuff '''
def actualwork(forward, reverse, name, direc):
	# check the files look right
	print('forward sequence file: ' + forward) 
	print('reverse sequence file: ' + reverse)
	
	# makes a folder
	try:
		if os.path.isdir(os.getcwd() + '/' + name + "_output") == False:
			os.mkdir(os.getcwd() + '/' + name + "_output")
	except:
		os.mkdir(sys.argv[1] + name + "_output")
	
	# runs a bunch of stuff in terminal 
	os.system("hisat2 -x " + "Index -1 sequences/" + forward + " -2 sequences/" + reverse + " -S sample.sam --mp 2,1 --all") 
	os.system("samtools view -bS sample.sam > sample.bam")
	os.system("samtools fixmate -O bam sample.bam  fixmate_sample.bam")
	os.system("samtools sort -O bam -o sorted_sample.bam fixmate_sample.bam")
	os.system("sambamba markdup -r sorted_sample.bam sorted_sample.dedup.bam")
	os.system("samtools view -h -b -q 40 sorted_sample.dedup.bam > sorted_sample.dedup.q40.bam")
	os.system("samtools view -h -b -q 20 sorted_sample.dedup.bam > sorted_sample.dedup.q20.bam")
	os.system("samtools view -h -F 4 -b sorted_sample.dedup.bam > onlymapped_sample.dedup.bam")
	
	
	#for i in ["sample.sam", "sample.bam", "fixmate_sample.bam", "sorted_sample.bam", "sorted_sample.dedup.bam", "sorted_sample.dedup.q40.bam", "sorted_sample.dedup.q20.bam", "onlymapped_sample.dedup.bam"]:
	# All the outputs have sample in the name so it should also work to just move ones with the name sample
	for i in os.listdir(os.getcwd()): 
		if 'sample' in i:
			os.rename(i, name + "_output/" + i)

''' Deals with your database if you want '''
def makedatabase():
	# gets user input
	fasta = input('what is the name of your reference fasta? ')
	# runs a command
	os.system('hisat2-build ' + fasta + ' Index') 

''' Coding hygeine '''	
if __name__ == '__main__':
	# makes a database if you want
	check = input("Do you want me to make your database? [y/n] ")
	if check == 'y':
		makedatabase()
	elif check != 'n':
		print("invalid input, please enter 'y' or 'n'")
		check = input("Do you want me to make your database? [y/n] ")
		
	# calls main function with the path to your folder of FPE & RPE files
	main(sys.argv[1])
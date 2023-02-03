# Emma Schumacher
# Katzlab
# SURF 2022
#
# Last updated 05/17/22 by ETS 
# Takes a MAS.MAFFT file of scores and a fasta file to filter out low-quality sequences
# after each guidance iteration 

from Bio import SeqIO  # deal with fastas
import sys  # take on file stuff

# does the filtering
def main(fasta_file, mafft): 
	mafftscores = [] #queue of scores
	fltr = list() # list of sequences that have good scores
	removedcount = 0 #count of how much was removed
	
	with open(mafft, "r") as scores: 
		# turns each line of scores into an item in a list
		scores = list(scores) 
		
		# takes the scores from each line and preps/queues them
		for score in scores[1:-1]:
			score = score.rstrip()
			row = score.split('\t')
			mafftscores.append(row[1])
	
	# if the score is sufficient, appends the seq
	for seq in SeqIO.parse(fasta_file,'fasta'): 
		if (float(mafftscores.pop(0)) > 0.3):
			fltr.append(seq)
		else:
			removedcount += 1
	
	# names and then writes output fils
	f_out = 'Filtering_' + fasta_file	
	r = SeqIO.write(fltr, f_out, 'fasta')
	
	print("Filtering complete, " + str(removedcount) + " sequences failed to meet our specifications")

	
# main function  
if __name__ == "__main__":
	## USER INPUT HERE ##
	
	fasta_file = 'GEX1COMBINEDtranslatedsmallerseq2clustered09.fasta'
	mafft = 'MSA.MAFFT.Guidance2_res_pair_seq.scr_with_Names'
	
	main(fasta_file, mafft)

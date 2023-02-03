# Phylogenetic work on meiosis/ploidy toolkit genes
Written by Caitlin Timmons
***
## Workflow overview 

1. Collect protein sequences from the EggNog database for genes associated with meiosis/ploidy in a literature search
2. Translate NCBI IDs into taxonomic names to make more usable

*Make sure the following is installed to use SeqIO and ete3 in the script*

From command line: 
      conda install -c anaconda biopython
			conda install -c etetoolkit ete3
      conda activate ete3
      conda install -c etetoolkit ete3 ete_toolchain
      ete3 build check

This script called length_bar_violin_plots_combo.py combines the following tasks into one (this was built upon taxid_translate.py, redoagain.py that can be found in the same folder):
* Removes underscores in the fasta files and convert the NCBI taxon IDs to taxon names 
* Subsampling: selects random sample of 20% of the total number of the sequences is below the threshold of 500 sequences with >100 sequences, otherwise keep all ~100ish sequences (3 times)

Place in your folder, edit the file path to your fasta file and the OG name
From the command line: python length_bar_violin_plots_combo.py
This will output a fasta file and tsv file 
(Please keep track of lengths in this spreadsheet here)

3. **SKIP (Optional visualizations)**

The tsv file can be used to plot length distribution of the sequences using this R script called LenDistPlots.Rmd
If you’d like a visualization to view multiple gene families, you can use this script called combo_script_model_length.py but you must first convert the NCBI taxon IDs to taxon names using the taxid_translates.py script.

4. **Possibly analyze the outlier sequences**

What is the taxonomic distribution?
Evaluate the taxonomy of outliers by BLAST against nr

5. **Cluster sequences with translated IDs using CD-Hit**

**Make sure CD-HIT is installed**

From command line: 
* conda install -c bioconda cd-hit

Cluster the translated and subsampled Euk, Prok, and Combined fastas at 90% or 95% sequence identity using CD-HIT and the fasta file output
From command line: 
* cd-hit -i INPUT_FILE.fasta -o OUTPUT_NAME -c SEQ_IDENTITY -n 5

Ex.: cd-hit -i SPO11EukSub.fasta -o SPO11EukSubTransClustered09 -c 0.95 -n 5

This should output two files: .fasta and .fasta.clstr (only use the .fasta moving forward)

6. **Assess sequence homology with GUIDANCE**

Run Pre-Guidance on terminal to further filter low-quality sequences (3 times; removing sequences after each iteration)

Filter out low-quality sequences after each iteration using WeakSpartanPit.py. It reads in the scores data frame and filters so it only has sequences with scores above 0.3.

7. **Identify the corresponding orthologous group (OG) in the OrthoMCL database.** 

BLAST remaining high-quality sequences against the Katzlab hook database using Diamond.

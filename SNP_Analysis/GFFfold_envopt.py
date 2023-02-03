'''
Emma Schumacher
Katzlab
10/26/2022
Script to automate the GFF pipeline (For Taylor)
    Version notes: This script only changes envrionments 3 times, should be much more efficient and easier to read than before
USAGE NOTES: Put script in folder with my associated <environments> folder, your folder of "fasq.gz" files, and your hand curated ".fas" file.
    The script will automatically set up the environments you need- you only need to do this once per device you run it on.
*** You need to hard code your ".fas" file, "fasq.gz" folder, and index name in "main" (line 110). I can change these to command line arguments if you want Taylor
'''

import os
import sys
import subprocess

'''
7. Remove SNPs with read depth less than 10, minimum quality score of 20, maximum allowed missing data of 50%, and a minor allele count of 2 & non-SNPs
'''
def qualfilt2():
    #subprocess.run(f'. $CONDA_PREFIX/etc/profile.d/conda.sh && conda activate taylor', shell=True, executable='/bin/bash')
    os.system(f'vcftools --vcf All_BAM.vcf --max-missing 0.5 --mac 2 --minQ 20 --minDP 10 --recode --recode-INFO-all --out All_BAM_QC')
    os.system(f'vcftools --vcf All_BAM_QC.recode.vcf --remove-indels --recode --recode-INFO-all --out All_BAM_SNPs_only')
    
'''
6. Re-run the variant caller on a combined BAM file for all cells (for population-level comparison)
'''
def combobam(key):
    #subprocess.run(f'. $CONDA_PREFIX/etc/profile.d/conda.sh && conda activate taylor', shell=True, executable='/bin/bash')
    #First column is the bam file name
    #Column 2 is the LKH name (plus sample location, but this might not be necessary)
    #Column 3 is the LKH number
    if not os.path.exists('bamRG.txt'):
        with open('bamRG.txt', 'w+') as merged:
            merged.write('BAM\tID\tSM\n')
            #merged.write('BAM\tID\tSM\tLB\tDS\tPU\tPI\tCN\tDT\tPL\n')
    with open('bamRG.txt', 'a') as merged:
        merged.write(f'{key}_output/sorted_{key}.dedup.q20.bam\t{key}\t{key}\n')


'''
5. Quality filter SNPs
'''
def qualfilt(key, fpath):
    #subprocess.run(f'. $CONDA_PREFIX/etc/profile.d/conda.sh && conda activate taylor', shell=True, executable='/bin/bash')
    # filter
    os.system(f'bcftools filter {key}_output/{key}.vcf -i \'FMT/DP>=5\' -Ov -o {key}_output/{key}_minDP10.vcf')
    os.system(f'bcftools filter {key}_output/{key}_minDP10.vcf -i \'QUAL>=20\' -Ov -o {key}_output/{key}_minDP10_q20.vcf')
    os.system(f'vcftools --vcf {key}_output/{key}_minDP10_q20.vcf --remove-indels --recode --recode-INFO-all --out {key}_output/{key}_SNPs_only')
    
    # Adds each filtered file to combobam
    combobam(key)
'''
4. Calculate basic stats about the mapped reads & variant Calling with freebayes
'''
def calcstats(key, fpath):
    #subprocess.run(f'. $CONDA_PREFIX/etc/profile.d/conda.sh && conda activate taylor', shell=True, executable='/bin/bash')
    # Calculate the stats
    os.system(f'samtools idxstats {key}_output/sorted_{key}.dedup.q20.bam |awk \'$1 != "*"\'|sort> {key}_output/{key}_idx.txt')
    os.system(f'bedtools genomecov -ibam {key}_output/sorted_{key}.dedup.q20.bam |awk -F\'\t\' \'$2==0\'|awk -F\'\t\' \'$1 != "genome"\'|sort> {key}_output/{key}_perc_coverage.txt')
    os.system(f'bedtools genomecov -ibam {key}_output/sorted_{key}.dedup.q20.bam |head -200 |grep -v ^genome |awk -F\'\t\' \'BEGIN{{x = 0; y = 0}}{{x += $2*$3; y+=$3}}END{{print x/y}}\' > {key}_output/{key}_avg_coverage.txt')
    # Create one output table for each sample
    os.system(f'paste {key}_output/{key}_idx.txt {key}_output/{key}_perc_coverage.txt {key}_output/{key}_avg_coverage.txt > {key}_output/{key}_finalstats.txt')
    # Variant Calling with freebayes
    os.system(f'freebayes -f {fpath} {key}_output/sorted_{key}.dedup.q20.bam > {key}_output/{key}.vcf')

    qualfilt(key, fpath)

'''
3. Pairs reads (forward/reverse file)
'''
def bowtie2read(fpath, indxname, sfolder, forward, reverse, key):
    #run_env(f'bowtie2-build {fpath} {indxname} && bowtie2 -x {indxname} -1 {sfolder}/{forward} -2 {sfolder}/{reverse} -S {key}_output/{key}.sam && samtools view -S -b -h {key}_output/{key}.sam > {key}_output/{key}.bam && samtools sort {key}_output/{key}.bam -o {key}_output/{key}.sorted.bam', 'taylor')
    run_env(f'sambamba markdup -r {key}_output/{key}.sorted.bam {key}_output/sorted_{key}.dedup.bam', 'samb')
    
    print('outie')
    # now that sambamba is done, we can just run in Taylor for the rest of the program
    subprocess.run(f'source activate taylor', shell=True, executable='/bin/bash')
    os.system(f'samtools view -h -b -q 20 {key}_output/sorted_{key}.dedup.bam > {key}_output/sorted_{key}.dedup.q20.bam')
    os.system(f'samtools view -h -b -q 20 {key}_output/sorted_{key}.dedup.bam > {key}_output/sorted_{key}.dedup.q20.bam')
    os.system(f'samtools index {key}_output/sorted_{key}.dedup.q20.bam')
    
    calcstats(key, fpath)

'''
3.5. Just run sambamba
'''
def run_env(commnd, enviro):
    #print(enviro)
    subprocess.run(f'. $CONDA_PREFIX/etc/profile.d/conda.sh && conda activate {enviro} && {commnd} && conda deactivate', shell=True, executable='/bin/bash')

'''
2. Pairs reads (forward/reverse file), also calls steps 3-6 iteratively on each pair
'''
def bowtie2readcommands(fpath, indxname, sfolder):
    # builds a bowtie2 index for ref file, change based on scratch loc
    run_env(f'bowtie2-build {fpath} {indxname}', 'taylor')
        
    # collect all the forward and reverse .gx files into dictionaries
    rpe =  {i[:i.index('_')] : i for i in os.listdir(sfolder) if ((os.path.splitext(i)[1] == '.gz') & ('RPE' in i))}
    fpe =  {i[:i.index('_')] : i for i in os.listdir(sfolder) if ((os.path.splitext(i)[1] == '.gz') & ('FPE' in i))}
     
    # check if they are obviously not matched right
    if len(rpe) != len(fpe):
        raise Exception("You do not have an FPE for every RPE in this folder- please correct this and try again")
    if (len(rpe) < 2):
        print("You do not have enough LKHs to create a merged bam- I will not create a merged bam")
        merge = False
    else:
        merge = True
        
    # for each LKH/file in reverse dic MAYBE SKIP
    for key, val in rpe.items():
        # make an ouput folder if there isn't one
        if os.path.isdir(f'{key[:6]}_output') == False:
            os.mkdir(f'{key[:6]}_output')
            reverse = val
            try:
                forward = fpe.get(key)
                print(f'{key} for: {forward} rev: {reverse}')
                # run bow tie2 commands for it
                bowtie2read(fpath, indxname, sfolder, forward, reverse, key)
                # deletes the sam files because they are large and useless
                os.system(f'rm {key}_output/{key}.sam')
                
            except:
                print(f'You dont have an FPE file for {key}')
    
    # tells main to bother merging or not
    return(merge)
    
'''
1.5 Makes GFF file

Column 1- Contig name after the '>' in the fasta file
Column 2- . (all rows)
Column 3- CDS (all rows)
Column 4- 1 (all rows)
Column 5- Sequence length (unique to each contig, number after Len)
Column 6- . (all rows)
Column 7- . (all rows)
Column 8- . (all rows)
Column 9- ID=(Contig name);Name=(Contig name)
'''
def turn_fas_2_GFF(fpath):
    #subprocess.run(f'. $CONDA_PREFIX/etc/profile.d/conda.sh && conda activate taylor', shell=True, executable='/bin/bash')
    # collect all the fastas in the reference (i take out the part before the XX because it annoys me) ???
    with open(fpath, 'r') as myfast:
        seqns = [line[line.index('_XX_') + 4:line.index('\n')] for line in myfast.readlines() if '>' in line]
        
    # defines name of file (i assume that everything in the fasta is going to have the same LKH so I only check one) ???
    LKH = seqns[1][seqns[1].index('LKH'):seqns[1].find('_', seqns[1].index('LKH'))]
    
    # writes it down
    with open(f'contig_{LKH}_Filtered.Final.NTD.ORF.all.gff', 'a+') as merged:
        for seqn in seqns:
            merged.write(f'{seqn}\t.\tCDS\t1\t{seqn[seqn.index("_Len")+4:seqn.index("_Cov")]}\t.\t.\t.\tID={seqn};Name={seqn}\n')
    
'''
1. Main func: Variables, writing GFF file, calling bowtie
'''
def main():
    '''
    Declare your variables
    '''
    fpath = 'SortaHandCurated_071422.fas'
    # DO NOT CHANGE THE 'INDEXES/' PART. ONLY CHANGE THE SECOND STRING
    indxname = 'Indexes/' + 'Am_tu_Hp03'
    sfolder = 'drive-download-20220930T033612Z-001'
    
    # I hate having my indexes floating so I put them all in a folder, ??? Note to self keep that in mind if I change params
    if os.path.isdir(f'Indexes') == False:
        os.mkdir(f'Indexes')
        
    # writes that GFF file (ask about the LKH)
    turn_fas_2_GFF(fpath)
    # Does the complicated stuff
    merge = bowtie2readcommands(fpath, indxname, sfolder)

    # Step 6.5, merges bam file and runs freebayes on it if there are enough files
    if (merge):
        subprocess.run(f'. $CONDA_PREFIX/etc/profile.d/conda.sh && conda activate taylor', shell=True, executable='/bin/bash')
        run_env(f'bam mergeBam -v --log --ignorePI --list bamRG.txt --out allSeqs.bam && freebayes -f {fpath} allSeqs.bam --gvcf -g 1000 > All_BAM.vcf', 'taylor')
        # quality filter
        qualfilt2()
'''
0. Does package set up if the user has not run this script before, this is where the "environments" folder comes in
taylor - name of main environment used
sam - only has sambamba, which for some reason will not run if there are any other environments
'''
def setuppackages():
    strt = input('Have I set up the conda environments <taylor> and <samb>? [y/n] ')
    while(strt != 'y' and strt != 'n'):
        strt = input('Have I set up the conda environments <taylor> and <samb>? Please enter either "y" or "n" [y/n] ')
    # no evironments check
    if strt == 'n':
        os.system(f'conda env create --name samb --file=evironments/sambambagffenv.yml')
        os.system(f'conda env create --name taylor --file=evironments/maingffenv.yml')
    print('Please make sure youre in the <base> environment!')

'''
Coding hygeine
'''
if __name__ == "__main__":
    setuppackages()
    main()

# Germline-Soma Model
Takes readmapped data from ciliate genomes and visualizes it, performs statistical analysis, and flags suspicious or otherwise noteworthy data. 
***
## 1. Running the model
To run these scripts you need to import the following libraries:
* matplotlib
* pandas
* logging
* xlwt
* Openpyxl

  a. Run this in a folder containing all 3 scripts (main.py, seqclass.py, makefig.py) & either a tsv or xls/xlsx spreadsheet of germline/soma data
  b. In terminal, cd into your folder and then call “python3 mainms.py <spreadsheet name>”
***
## 2. Interpreting your results
  a. every transcript that meets the following criteria will have a png visualizing it
    * contained >2 segments
    * >80% mapped
    * >100 bp in length
      - Every unmapped transcript, and the reason it did not map, will print to the terminal
  b. Each png should be named and titled according to the transcript and germline pairing. The image will contain 2 lines, one labeled "S:" (soma) and the other labeled "G:" (germline). These lines will be made up of offset arrows, which represent separate segments. 
    * purple tinted arrows that point -> are read in a forward direction
    * teal tinted arrows that point <- are read in the reverse direction
    * if the same nuclei contains both puple and green arrows, the genome is scrambled
  c. Other features marked in the images
    * Pointer sequences, which are segments that overlap, are shown by orange lines
    * Irregular soma gaps (>20 bp) are indicated by a yellow line between the segment arrows on the somatic nucleus
    * IESs (any gap on the germline) are indicated by a red line between the segment arrows on the germline nuclei
  d. Spreadsheets (data summaries)
    * Each data summary has 2 sheets:
      1. “Transcripts data”, which contains data for whole transcripts
      2. “Segments data”, contains data for each individual segment
    * “Transcripts data” contains the following information:
      1. TRANSCRIPT: name of the transcript
      2. GERMLINE: name of the germline
      3. TOTAL LENGTH: tells you the total length of the germline segments
      4. IRREGULAR SOMA GAP: tells you if there are any irregular soma gaps in the transcript
      5. SOMA REVERSAL: tells you if any segment on the soma was mapped in reverse
      6. GERMLINE REVERSAL: tells you if any segment on the germline was mapped in reverse
      7. % MAPPED: tells you how much of the germline is not gaps
      8. AVE LENGTH	: the average length of all the germline segments in the transcript
      9. # SEGMENTS: the number of segments in the transcript
      10. MAPPED: indicates whether the transcript was deemed worth mapping or not
      11. SOMA SCRAMBLED: tells you if the soma was scrambled
      12. GERMLINE SCRAMBLED: : tells you if the germline was scrambled
    * “Segments data” contains the following information:
      1. TRANSCRIPT: name of the transcript
      2. GERMLINE: name of the germline
      3. TOTAL LENGTH: tells you the total length of the germline segment
      4. IRREGULAR SOMA GAP: tells you if there was an irregular soma gap between this segment and the next segment
      5. SOMA REVERSAL: tells you if the segment on the soma was mapped in reverse
      6. GERMLINE REVERSAL: tells you if the segment on the germline was mapped in reverse
      7. S start: start coordinate for soma segment
      8. S end: end coordinate for soma segment
      9. G start: start coordinate for germline segment
      10. G end: end coordinate for germline segment
      11. UNUSUAL GAP LEN: if there was an IRREGULAR SOMA GAP,  gives you the length of that gap, if not, has “N/A”
  e. Log file
    * This log file contains suspicious transcript data you should take a second look at. Each entry tells you the name of a suspicious cell and the reason why it was flagged




  

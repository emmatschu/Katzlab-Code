'''
Emma Schumacher
Katzlab
11/17/2021
Updated 06/27/22
Script to filter OGs that are not included in the PhyloTOL database out of
the OG list used to make out phylogenetic tree
'''

import sys

def main(filename): 
    try:
        #opens the text file containing the OGs recognized by the PhyloTOL database as a set(as of Nov 2021)
        databasefile = set(open('Hook_DB.txt').read().split())
    except IOError:
        print('\nHook_DB.txt cannot be opened, make sure it is downloaded and in the same folder as this script or this program cannot run')
        print('Hook_DB.txt can be found here: https://drive.google.com/drive/folders/1Fo5YQtEqABh9hEKPqzdtvbzSOOTrGHB_?usp=sharing')
        print('Make sure its up to date!\n')
        exit()
   
    #opens the text file containing your OGlist OGs to read as a set
    OGlist = set(open(filename).read().split()) 
     
    #returns a set containing the overlap between out 2 files
    included = databasefile.intersection(OGlist)
    #returns a set containing the things in OGlist that arent in databasefile
    removed = OGlist.difference(databasefile)
    print(removed)
     
    
    #gets name of file so names based on it can be made
    filestarter = filename[:filename.index('.')]
    
    #opens a new file for my filtered output named after the original OG list
    with open(filestarter + '_filtered_list.txt', 'w') as final_file:
        #writes the contents of the included set into the new file
        for line in included:
            #this is the stuff that you will use in the tree
            final_file.write(line + '\n')

    #opens a new file for my list of removed OGs named after the original OG list
    with open(filestarter + '_not_included.txt', 'w') as extra_file:
        #writes the contents of the included set into the new file
        for line in removed:
            #this is the stuff that we removed from the tree file
            extra_file.write(line + '\n')


if __name__ == "__main__":
    #throws function if the database to be filtered is not included in the command line argument
    if len(sys.argv) != 2:
        print('\nYou need to enter the name of the list to be filtered (ex: python3 filter_OGslist.py final_uniquified_OGs.txt)\n')
        exit()
    #gets the OG5 list filename from commandline argument
    main(sys.argv[1])

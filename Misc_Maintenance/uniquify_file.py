
'''
Emma Schumacher
Katzlab
11/17/2021
Script to add the string "OG5_1" to the start of every number in the file

'''

import sys
import os 
import fileinput

def main(filename):
    
    #gets the name of the file
    fileToSearch = filename  
    #opens the file weare searching
    tempFile = open( fileToSearch, 'r+' )
    myFile = open( "uniquifiedFile.txt", 'w' )

    for line in tempFile.readlines():
        #myFile.truncate(0)
        myFile.write( "OG5_1" + line[1:] ) 

        #line.replace(line[0], textToReplace)
        #tempFile.truncuate()

    tempFile.close()
    myFile.close()    


if __name__ == "__main__":
    #gets the OG5 list filename from commandline argument
    main(sys.argv[1])

'''
Emma Schumacher
Katzlab
Spring 2022

Code to visualize germline soma sequences by creating graphs
'''

import sys #commandline arguments
#import matplotlib 
#matplotlib.use('TkAgg') #so i dont have to change to backend 
import matplotlib.pyplot as plt #matplot
import numpy as np #make sets and stuff
import seqclassms


def graph(seglist):
    ### SETUP
    
    # initialized some variables 
    fig, ax = plt.subplots()
    gxcoo = []
    gxcooreal = []
    gycoo = []
    sxcoo = []
    sxcooreal = []
    sycoo = []
    #???
    
    #germline total over soma total
    g_scale = float(((max(x.end for x in seglist[0]))-(seglist[0][0].get_start()))/((max(x.end for x in seglist[1]))-(seglist[1][0].get_start()))) #???
    
    #finds longest line
    if ((max(x.end for x in seglist[1]))-(seglist[1][0].get_start())) > ((max(x.end for x in seglist[0]))-(seglist[0][0].get_start())):
        maxx = (max(x.end for x in seglist[1]))-(min(x.start for x in seglist[1]))
    else:
        maxx = (max(x.end for x in seglist[0]))-(seglist[0][0].get_start())

    
    ### GRAPH AND GATHER COORDINATES/MAX
    
    #Calls the general mapping function on the germline list, returns updated coordinate lists and max value
    if (seglist[0][0].get_flip() == True):
        seglist[0].reverse()
    gxcoo, gxcooreal, gycoo = graphit(seglist[0], 2, gxcoo, gxcooreal, gycoo, 0, gs = None)


    #Calls the general mapping function on the some list, returns updated coordinate lists and max value   
    sxcoo, sxcooreal, sycoo = graphit(seglist[1], 5, sxcoo, sxcooreal, sycoo, 20, gs = g_scale)

    
    ### AXIS AND SIZE 
    
    # Sets axis scaled to the graph so the title shows up correctly, based on the largest x coordinate
    ax.axis([-10, maxx + (maxx/10), 0, 8]) 
        
    #turns of axis and creates plot
    ax.axis("off") 

    ### TEXT (COORDINATES AND TITLE)

    #marks which line is the germline and which is the soma
    plt.text(-(maxx/20), 4.8, '{}'.format("S: "), fontsize= 10)
    plt.text(-(maxx/20), 1.8, '{}'.format("G: "), fontsize= 10)
    
    #Plots x coordinates for each segments' beginning and ending (also unscales the printed coordinates)
    for k, l, j in zip(sxcoo, sxcooreal, sycoo): #loops through my arrays of somatic x coordinates and y coordinates
        if (j == 5): #if the segment is staggered up, moves up further
            plt.text(k, j + 0.5, '{}'.format(l), fontsize=7)
        else: #if the segment is staggered down, moves down up further
            plt.text(k, j - 0.5, '{}'.format(l), fontsize=7)
    for k, l, j in zip(gxcoo, gxcooreal, gycoo): #loops through my arrays of germline x coordinates and y coordinates
        if (j == 2): #if the segment is staggered up, moves up further
            plt.text(k, j + 0.5, '{}'.format(l), fontsize=7)
        else: #if the segment is staggered down, moves down up further
            plt.text(k, j - 0.5, '{}'.format(l), fontsize=7)
 
    #gets the name of the transcript
    name = seglist[len(seglist)-1][0].get_name()
    #adds the germline name to the transcript
    name = name + " x " + seglist[0][0].get_germ()
    #plots the title 
    plt.title(name, ha='center', va='center') 

    ### BIG REVEAL
    
    # OPTIONAL: IF YOU SHOW PLOT, IT WONT SAVE THE PNG BUT YOU WILL GET A POPUP OF EACH FIGURE THAT YOU CAN EXPAND TO YOUR LIKING
    #plt.show()

    #saves png as "Transcript000xGerm000.png" by stripping white space from name
    plt.savefig(name.replace(" ", ""))
    plt.cla()
    plt.clf()
    plt.close(fig)
    

### this function plots the segment arrows, takes into account whether they are reversed ot not
def reversedarrows(my, strt, fin, rev, flip):
    if(rev == True): #if this segment was scrambled (turqouise arrow)
        plt.arrow(x = fin, y = my, dx = strt-fin, dy = 0, width= 0.01, color = "green", head_width=0, head_length=0.4, zorder = 10) 
        plt.annotate("", xy=(fin, my), xytext=(strt, my), color = "green", arrowprops=dict(arrowstyle="<-"),  zorder = 200)
        
    else: #if this segment was not scrambled (purple arrow)
        plt.arrow(strt, my, fin-strt, 0, width= 0.01, length_includes_head = False, color = "mediumpurple", head_width=0, head_length=0, zorder = 10, overhang = 3)
        plt.annotate("", xy=(fin, my), xytext=(strt, my), color = "mediumpurple", arrowprops=dict(arrowstyle="->"),  zorder = 10)
     
### does the math to make my coordinates graphable (starting at 0, proportional) or undoes said math
def scale(x, g_s = None): 
    #if it is making my coordinates graphable
    #if there is a g_scale (soma math)
    if (g_s):
        x = x * g_s 
    #if there is no g_scale (germline math)
    else:
        x = x
     
    return(x)
    
# Generic graphing function, gets coordinates and calls line functions for each transcript
def graphit(mlist, y, xcooreal, xcoofake, ycoo, check, gs = None):

    #goes through every segment in the transcript list
    for i in range (len(mlist)):
        if (i == 0):
            m1s = 0
            m1f = scale(mlist[i].get_size(), g_s = gs) 
        elif ((i != 0) & (mlist[i].get_flip() == False)):
            m0f = m1f
            m1s = m1f + scale(mlist[i].get_gaplen(), g_s = gs) #end of prev + length of gap or overlap
            m1f = m1s + scale(mlist[i].get_size(), g_s = gs) # start of this one + length of this one ???
        else:
            m0f = m1f
            m1s = m1f + scale(mlist[i - 1].get_gaplen(), g_s = gs) #end of prev + length of gap or overlap
            m1f = m1s + scale(mlist[i].get_size(), g_s = gs) # start of this one + length of this one ???
         
        #staggers the transcripts, every other segment is .01 higher
        if (i%2 == 0):
            my = y 
        else:
            my = y - 0.1

        ### PLOTS SEGMENT
         
        #gets & scales the germline start and finish values for the current segment being read  
        xcoofake.extend([m1s, m1f])
        if (mlist[i].get_flip() == False):
            xcooreal.extend([mlist[i].get_start(), mlist[i].get_end()])
        else:
            xcooreal.extend([mlist[i].get_end(), mlist[i].get_start()]) #??? REV TOO? NO BUT EXPLAIN
        ycoo.extend([my, my]) 
        
        # plots arrow for segment
        reversedarrows(my, m1s, m1f, mlist[i].get_rev(), mlist[i].get_flip())  #??? may check space before instead of after?? 
        
        # only runs if current segment is not the last sequence of our list 
        if (i != 0):
            if (mlist[i].get_flip() == False):
                spacefuncs(mlist[i].get_gaplen(), check, my, m1s, m0f)
            else:
                spacefuncs(mlist[i - 1].get_gaplen(), check, my, m1s, m0f)
                
    #returns updated coordinate lists and largest point in transcript
    return(xcoofake, xcooreal, ycoo)


#### if there is overlap between the segment and the next segment, plots it ????
def overlap(y, m1s, m0f):
	#plt.arrow(m1s, y, m1s-m0f, 0, width= 0.08, length_includes_head = True, color = "orange", zorder = 1) 
	plt.plot([m1s, m0f], [y, y], color = "orange", zorder = 50)
        

#### if there is a weird spcae between the segment and the next segment, plots it ???
def spacefiller(y, m1s, m0f, col):
    plt.plot([m0f, m1s], [y, y], color = col, zorder = 10)

#### space stuff in case of flip
def spacefuncs(gap, check, my, m1s, m0f):
    #if space is over a certain length, it needs to be marked ??? FLIPPED
    if (gap > check):
        #ies
        if (check == 0): #for germline, I mark any space that exists (>0) ???
            spacefiller(my, m1s, m0f, "red")
        #soma gap
        elif (check == 20): #for soma, I mark unusually large spaces (>20)
            spacefiller(my, m1s, m0f, "gold")

    #if there is overlap (a space less than 0) and the space has ???
    elif (gap < 0): 
        overlap(my, m1s, m0f) #???


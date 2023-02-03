'
Week 2 R Learning Club Skeleton Code
By Emma Schumacher
SURF 2022
Teaches boxplots in ggplot2
'

'
1. R needs to be run line by line, so click on the line you want and type "command + enter".  

'

'
2. Install any packages you do not have yet
'
install.packages("tidyverse")
install.packages("ggplot2")

'
3. Load the packages- this gives you access to certain functions you need for this script
'
library(ggplot2)
library(tidyverse)


' 
4. Create/pick a folder on your desktop to be your "working directory". Put your tsv files in this folder.
Once you have chosen it, drag the folder into a terminal window to get the file path. 
Using the "setwd" command allows you to assign that folder as your working directory. This tells R that the things 
it wants to access will all be in this directory. 
Please update the line below with your folder path, make sure to have quotation marks around the path so R knows
it is meant to be read as text.
' 
setwd("/Users/emmaschumacher/Desktop/lengthplots/")

' 
5. To check that this worked, run the command below and check the path printed to the CONSOLE on the bottom of the
screen.
' 
getwd()

'
6. Read your tsv into a "dataframe". You can change the name of this dataframe to anything you like.
The "read.table" command tells R to turn your tsv into digital information that it can handle. Update 
the name in quotations to the name of one of your tsv files. 

sep = "\t" and header = T both help R understand how to read your file, which is a Tab Separated Value, 
meaning the columns are separated by tabs (\t), and tells it the first row is a header.

After running, your dataframe should appear in the Environment on the upper left side of your screen. 
This shows you what active data structures you have 
'
Eukdataframe <- read.table("SPO11Eukaryote.tsv", sep = "\t", header=T)

' 
7a. To check that this worked, run the command below and check the path printed to the CONSOLE on the bottom of the
screen. This will print out the contents of your dataframe. (!!! make sure to update dataframe name if changed)
' 
head(Eukdataframe)


'
7b. You can also check by "viewing" the dataframe, which will open it in a new window
'
View(Eukdataframe)


'
8. make a basic bbox plot for your dataframe using the code below. 
Change the "data = " to your dataframe, to tell R what it is mapping. 
mapping = aes(x = OG, y = Length) tells R what should be on the x and y axises, and the ending
"+ geom_boxplot()" tells R what kind of plot to make. 
We will be able to make several other plots using this same code structure by changing that ending. 
' 
lengthBoxPlot = ggplot(data = Eukdataframe, mapping = aes(x = OG, y = Length)) + geom_boxplot()

'
9. Call your box plot in order to view it. It should appear in the bottom right of your screen 
'
lengthBoxPlot


# Congrats! You've made your first boxplot!
'
So what does this plot tell you?
This is a "box and whisker plot", and it shows you the distribution of your data. You get an idea of how close your values are to 
each other, and numbers tend to show up. 

The box of your plot should contain 50% of your data. It covers the Inter Quartile range (IQR), which is covers the 
area that 25% (Q1) of the data should be below and the area that 75% (Q3) of the data should be above. The line in the middle
of the boxplot is the median. 
The whiskers of your boxplot is 1.5*IQR from the Q3 and Q1, and theoretically should contain all of your data. The ends of the
whiskers are called the minimum and maximum, which are not actually the smallest and largest values of your data. Anything
larger or smaller than these ends is considered an outlier. 
Outliers can provide important information, since we need to know if some of our data looks significantly different from others. 

   
   *       <-- Outliers (values smaller than the minimum)
  ---      <-- Minimum (Not the smallest number, calculated by Q1 - 1.5*IQR)
   |
   |
---------  <-- Q1 First Quartile (the median between the smallest number and the median of your data)
|       |
|       |
---------  <-- Median of your data (the middle number if you were to one by one delete the largest and smallest values)
|       |
|       |
---------  <-- Q3 Third Quartile (the median between the largest number and the median of your data)
   |
   |
  ---      <-- Maximum (Not the largest number, calculated by Q3 + 1.5*IQR)
  
   *       <-- Outliers (also values larger than the maximum)    
   *     
'

'
10. For this project, we want to map 2 datasets on the same graph. Using the same code structure as in steps 6 and 7,
read your second .tsv file into a new dataframe and check it to see if it loaded correctly using head() or View()
'
### TYPE HERE ###

Prokdataframe <- read.table("SPO11Prokaryote.tsv", sep = "\t", header=T)

head(Prokdataframe)

'
11. We can combine these two separate dataframes into one, so all the information can be viewed and graphed together, with the 
rbind command. Update the names in the code below and then check if it looks right using a method from step 7. 
'
SPO11dataframe <- rbind(Eukdataframe, Prokdataframe)

### TYPE HERE ### 

head(SPO11dataframe)

'
12. Now, using the same code structure as in steps 8 & 9, make a new boxplot with your updated dataframe and call it 
'
### TYPE HERE ###

lengthBoxPlot = ggplot(data = SPO11dataframe, mapping = aes(x = OG, y = Length)) + geom_boxplot()

lengthBoxPlot
 
'
13. We should make our axis labels more descriptive. Usog the code below, you can the title, y axis label, and x axis label manually.
'
print(lengthBoxPlot + labs(title = "Gene Length Box Plot", y = "Length of Sequence (bp)", x = "Name of Gene"))

' 
14. Add some color to your boxplot to make it more pleasant to look at! This will look similar to the code we have use previously to make plots, 
but you will add one more parameter into mapping = aes(). This parameter, "fill", tells R what variable to base color changes on. 
Then, call the plot to see it. Your axis labels will go away, because they are not coded into the plot itself, but printed over it. When a new plot
is drawn "on top" of the previous one and its labels, the new axis titles are no longer visible. 
Your labels can be harcoded into the call of the plot by adding + labs() to your plot call. 
Update the label names and then call your plot to see it. 
'

lengthBoxPlot = ggplot(data = SPO11dataframe, mapping = aes(x = OG, y = Length, fill = OG)) + geom_boxplot() + labs(fill = "Domain", title = "Gene Length Box Plot", y = "Length of Sequence (bp)", x = "Name of Gene")

lengthBoxPlot

'
14. You can change it to specific colors. pick your two favorite colors and update the code below. If the name of the color is not recognized, 
google hex codes and then enter the one that matches your color of choice into the ""
'
lengthBoxPlot + scale_fill_manual(values = c("#E0BBE4", "#FEC8D8")) 

 
'
15. To finish, lets get summary statistics for our data. We cannot use our combined dataframe for this, because it will pool both of our plots and not
provide information for the separate files. 
While we do have two separate dataframes for our files, you might want to divide up a dataframe in the future that you do not have separate files for, so
we will practice that here. 
Using the "subset" command, you can collect onnly the values of your dataframe that have a certain value for a variable, in this case ones that have an
OG named "MAD2Eukrun_2". Modify the code below for your files. 
'

Euk <- subset(SPO11dataframe, OG == "SPO11Euk")

'
16. Now, call summary() on your newly created subset. It should print to your console.
'
summary(Euk)

'
17. If you call summary() on the subset in general like we did above, it will try to run calculations on every column. This is not necessary for most 
of our columns. Instead, you can specify a single variable using "$". Use the code below as an example. 
'
summary(Euk$Length)

'
18 Now, using the code from steps 15-17, get summary statistics for your other file. 
'

### TYPE HERE ###

Prok <- subset(SPO11dataframe, OG == "SPO11Prok")
summary(Prok$Length)

'
Please prepare any takeaways you get from looking at these plots and their data. For example:
Which file has a higher concentration of data?
Which file tends to be larger? 
Which file has more outliers? What could this mean?
What is the minimum and maximum for these boxplots? (1.5 * IQR - minimum/+ maximum)
Is this a good representation of the data?
'



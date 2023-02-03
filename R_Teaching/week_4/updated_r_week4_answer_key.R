'
Week 4 R Learning Club Skeleton Code
By Angela Jiang & Emma Schumacher
SURF 2022
Teaches heatmaps in plotly
'

'
1. Load the libraries we need- this week we will be using plotly, a different grahing library. 
Install it if you do not have it yet using the same code as we did in Week 2 Step 2
'

library(plotly)
library(tidyverse) 

'
2. set your working directory to a folder containing the downloaded "dataset_week_4.csv" as you did in step 4 week 2
'
### TYPE HERE ###
#setwd("/Users/emmaschumacher/Desktop/lengthplots/")

'
3. Read your gene count table "dataset_week_4.csv" into a dataframe. 
This week, we are working with a csv, or Comma Separated Values document. This means that your "sep" variable should
use commas instead of tabs, like we did with the tsvs. This document also has a column of "row names" in addition
to the row of column names (the "header=T"), so we will add an extra parameter to tell R not to consider row 1
data like it does the other rows ("row.names = 1")
'
og_data_0 <- read.table("/Users/angela/Documents/Spring2022/dataset_r_learning_club.csv", header=T, row.names =1, sep =",")

'
DATA WRANGLING
For the following tasks, we are using functions from the dplyr library (part of the tidyverse collective).
This library is used for manipulating the data in our dataframe in many ways. 
'

'
4. Take a look at your new dataframe using the View function as we did previously. 
The rows of this datagrame are OGs (orthologous groups), while the columns are taxa (species). 
The numbers in the table represent how many times a taxas sequence has appeared in the corresponding OG
'
### TYPE HERE ###
View(og_data_0)

'
5. You probably notices that here are some suspicious things going on with our data!
First of all, OG8 appears to have only have "NA" values across all taxa, indicating this group is not present in 
our database at all! We cannot work with this suspisious and non-numeric data, so we should remove it.

Using the filter function, we can tell R to look at the value in the "HP1" column for each row as a filter criteria. 
If the OG row has a value that "is.na" in the HP1 column, it is filtered out. If not, it is kept for our new dataframe.

In code, the "!" is an operator symbol that means "NOT". Anything after it will be considered negated. 
In this case, our filter is only keeping items that are NOT "na" in the HP1 column.

Use the following code to calculate the average number of counts for each OG row, then look at the dataframe to
see your altered dataframe.
' 
og_data_1 <- og_data_0 %>%
  filter(!is.na(Hp1))

#View(og_data_1)

'
6a. Now that we removed all of our non-numeric data, we should calculate summary statistics to tell us more. 

Using the mutate function, we can create a new row called "average" that contains the mean value of each row.  

Use the following code to calculate the average number of counts for each OG row, then look at the dataframe to
see your new row.
' 
og_data_1 <- og_data_1 %>%
  mutate(average = rowMeans(.))

#View(og_data_1)

'
6b. The mutate function can be used to with different calculations, for example the sum of each row with "rowSums".
Based on our code in Step 6a, write a fucntion to make a column that calculates the sum of counts for each OG row. 

Then, look at your dataframe to see if it worked. 
' 

### TYPE HERE ### 
#exclude average
og_data_1 <- og_data_1 %>%
  mutate(sums = rowSums(select(., -average)))

View(og_data_1)

'
7. Oh no! There are more suspicious things going on with our data!
The sum and average for OG7 is 0, which means that it does not appear in any of our taxa. 
Clearly, this OG should be discarded from our study, since it is not significant. 

Using the filter function, we can tell R to look at the value in the "average" column for each row as a filter criteria. 
If the OG row has a value that is not ">0" in the average column, it is filtered out. 
If is is ">0", it is kept for our new dataframe. 

Use the following code to filter this row out of our data, then look at the dataframe to see your altered dataframe.

'  
og_data_2 <- og_data_1 %>%
  filter(average > 0)

View(og_data_2)

'
8a. While the average was useful, we do not want to include it in our actual heatmap. 

Using the select function, we can select a column by name to remove from our dataframe and then update our original dataframe.

Use the following code to take the average column out of our data, then look at the dataframe to see your altered dataframe.
'
og_data_2 <- select(og_data_2, -average)

og_data_2

'
8b. Using the code from step 8a as an example, also remove our sums column from our dataframe. 
'
### TYPE HERE ###
og_data_2 <- select(og_data_2, -sums)

og_data_2

'
9. For this study, Angela is only interested in papilio data (even though ciliates are superior!).
To help her out, use the "select" function to create a subset of your data only containing the papilio. 
To do this, we put a filter condition that only keeps columns whos names contain the substring "Hp".

Use the following code to filter certain species from our data, then look at the dataframe to see your altered dataframe.
' 
hp_data <- og_data_2 %>%
  select(contains("Hp"))

View(hp_data)

'
10a. Laura wants your data to be in alphabetical order by their number. 
To sort your taxa columns, you can nest several functions to order certain parts of our data. 

'
hp_data <- hp_data %>%
  select(order(colnames(hp_data)))

View(hp_data)

'
10b. To put the the rows in alphabetical order as well, you can use similar code to what we step 10a.
However, instead of "colnames", you want to look at the "rownames". 

Use step 10a as a model and write code to organize your OG rows as well. 
'
### TYPE HERE ### 

hp_data <- hp_data %>%
  select(order(rownames(hp_data)))

View(hp_data)

'
11. Our data is almost ready to be turned into a heatmap! First, we need to turn our "dataframe" into a "matrix".
A matrix is just a slightly different data structure. It still uses rows and columns to organize data, but unlike
a dataframe, it only holds data of the same "type", in this case integers. 

Use the code below to turn our papillio data into a matrix.
' 
data <- as.matrix(hp_data)


'
12a. Now we want to label our axis. Create a variable to represent your y axis. We can not call the first row of our
dataframe by name, because it is unlabeled. However, since we specified that we wanted it to be our "row.names" in 
step 3, we can call it based on that characteristic. 
' 
y = rownames(hp_data) 

'
12b. Using the code in Step 12a, set a variable representing your x axis as equal to the "colnames" of our data. 
' 
### TYPE HERE ###

x = colnames(hp_data) 

'
13. Now, we can finally make a heatmap using our matrix and the axis information! 
Feel free to change the colors and such by playing with your variables. 

Create the plot by calling its name! The reason we use plotly for heatmaps is it makes them interactive.
If you hover your cursor over the sequares you will get information about the data there!
' 
heatmap_Hp <- plot_ly(z = data, y= y, x= x, colors = colorRamp(c("white", "red")), type = "heatmap") %>% #changing the colors!
  layout( plot_bgcolor='#e5ecf6',
          yaxis = list(
            gridcolor = 'e5ecf6'))#generate an interactive heat map

heatmap_Hp  

'
14. As a challenge, make a heatmap for another sub group in our dataset (start from step 9, for an extra challenge consider 
using a modified version of steps 6-8 to filter out blank rows)
' 
### TYPE HERE ###
# Load in filtered data
rh_data <- og_data_2 %>%
  select(contains("Rh"))

View(rh_data)

# Challenge 
rh_data <- rh_data %>%
  mutate(average = rowMeans(.))

rh_data <- rh_data %>%
  filter(average > 0)

rh_data <- select(rh_data, -average)

View(rh_data)

# Order
rh_data <- rh_data %>%
  select(order(colnames(rh_data)))

rh_data <- rh_data %>%
  select(order(rownames(rh_data)))

# Heatmap
data <- as.matrix(rh_data) 

y = rownames(rh_data) # a way of doing naming that doesn't require fighting with extra text file 

x = colnames(rh_data) # a way of doing naming that doesn't require fighting with extra text file

#adding title and axis labels!
heatmap_Rh <- plot_ly(z = data, y= y, x= x, colors = colorRamp(c("pink", "cornflowerblue")), type = "heatmap") %>% #changing the colors!
  layout( plot_bgcolor='#e5ecf6',
          title = "Rhizaria Heatmap",
          yaxis = list( title = "Orthogroup",
            gridcolor = 'e5ecf6'),
          xaxis = list(title = "Taxa"
              ))

heatmap_Rh  



'
Please prepare any takeaways you get from looking at these plots and their data. For example:
What kind of data could you use this heat map for?
What are the advantages of this visualization?
What kind of customizations would you want to add to this graph?
'



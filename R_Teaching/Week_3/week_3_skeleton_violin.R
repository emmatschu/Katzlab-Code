'
Week 3 R Learning Club Skeleton Code
By Emma Schumacher
SURF 2022
Teaches violin plots in ggplot2
'
 
'
1. Repeat steps 2-7 from last week to prepare your libraries, upload your files, and set up your working directory. 
'
### TYPE HERE ### 


'
2. Now, we will make a basic violin plot for your dataframe using the code below. 
Change the "data = " to your dataframe, to tell R what it is mapping. 
mapping = aes(x = OG, y = Length) tells R what should be on the x and y axises, and the ending
"+ geom_violin()" tells R what kind of plot to make, in this case a violin plot. 
You may notice that this is the same code structure as we used in the box
' 
lengthViolinPlot = ggplot(data = doubledataframe, mapping = aes(x = OG, y = Length)) + geom_violin()
lengthViolinPlot


# Congrats! You've made your first violin plot! 
'
So what does this plot tell you?
This is a "violin plot", and it shows you the distribution of your data, similarly to a boxplot. Unlike a boxplot, 
the violin plot shows you the sensity of your data. The horizontal width of the plot shows you how many datapoints
have a certain value. 

For example, if you made a violin plot of a set of numbers like this: [1, 3, 3, 4, 4, 5, 5, 5, 5, 7], it might look
like this:
                 _
1                V        <-- 1 is only in the set once, so there is a very small width
2                |        <-- 2 is not in the set, so there is no horizontal width there
3              _/ \_
4             ﹊\ /﹊
5          ____/   \____  <-- 5 is the most abundant number, and corresponds to widest part of the violin
6            ﹊﹊|﹊﹊
7                ∧        <-- 7 is only in the set once, so there is a very small width
                 -

Violin plots are often paired with another plot to give additional information about the data. We will get to that
later. 
'

'
3. For this project, we want to map 2 datasets on the same graph. Using the same code structure as we did in 
steps 6 & 7 last week, read your second .tsv file into a dataframe and check it to see if it loaded correctly
'

MAD2dataframe <- read.csv("MAD2SeqLength.tsv", sep = "\t")

doubledataframe <- rbind(HOP1dataframe, MAD2dataframe) 

'
4. Now, using the same code structure as last week, make a new boxplot with your updated dataframe and any other
features you liked (i.e. updated titles and color coding) and then call it to view it
'
### TYPE HERE ###


'
5. If you only want to show some of the graphs, you can use the scale_x_discrete function and enter the name of the
graph(s) you want to see based on their label on the x axis
'
lengthViolinPlot + scale_x_discrete(limits=c("HOP1Prok"))

lengthViolinPlot + scale_x_discrete(limits=c("MAD2Euk"))

'
6. You can also use this to change the order in which the graphs appear
'
lengthViolinPlot + scale_x_discrete(limits=c("MAD2Euk", "HOP1Prok"))

'
7. Violin plots are often used together with boxplots in order to have a more complete understanding of how your
data is distributed, both numerically and literally. Add a boxplot to your bar plot with the command + geom_boxplot
The optional "width" parameter inside of it lets you control how wide that boxplot is. You can play with it to 
see what looks best to you. 
'
lengthViolinPlot + geom_boxplot(width=0.1)

'
8a. A box plot will show us the minimum, IQR, median, and maximum of a graph, but what if we want to see other stats, 
like the mean and standard deviation? To do this, use the stat_summary() command.
'
lengthViolinPlot + stat_summary(fun = "mean", geom="pointrange", color="yellow")

'
8b. If you want to see the y summarized at each x, use "fun.data". This can be used with functions like "mean_se",
which show you both your mean and your standard error  ***
'
lengthViolinPlot + stat_summary(fun.data = "mean_se", geom = "errorbar")

'
9a. You can also combine your Violin plot with a dot plot, so you can literally see the distribution of data creating it.
' 
lengthViolinPlot + geom_dotplot(binaxis='y', stackdir='center', dotsize=0.2)

'
9b. The line of dots is somewhat uncomfortable to look at though, so you may prefer to use a jitter plot, which slightly
changes the position of dots so they are not so alligned. The ammount of horizontal disrupt is controlled by the number 
in position_jitter().
' 
lengthViolinPlot + geom_jitter(shape = 16, position = position_jitter(0.1)) 

'
10a. You can also label the points of your dataframe, though you will have to recreate the graph. In the "aes()" function 
of the call, add a parameter called "label" and pick a variable. You also need to add the following to your add ons:
+ geom_point() + geom_text(hjust=0, vjust=0)
' 
lengthViolinPlot = ggplot(data = doubledataframe, mapping = aes(x = OG, y = Length, label = Sequence_Name)) + geom_violin() + 
  geom_point() + geom_text(hjust=0, vjust=0) 

'
10b. It would be more useful for this plot to only know the identities of our extreme values. You can specify when a label
is applied to text by adding a parameter to geom_text called "aes(label = ifelse())". Inside the ifelse(), there are 3 positions. 

First is the condition(s) under which the label is applied. For my data, I wanted a label if the length was either or 
(notated as "|") greater than 300 bp or smaller than 150 bp.  
Second is what happens if the condition is met. In this case, it is labeled "as" the "Sequence_Name".
Third is what happens if the condition is not met. In this case, the label is nothing ('')
'
lengthViolinPlot = ggplot(data = doubledataframe, mapping = aes(x = OG, y = Length, fill = OG, label = Sequence_Name)) + geom_violin() + 
  geom_point() + geom_text(aes(label = ifelse(Length > 300 | Length < 150, as.character(Sequence_Name), '')), hjust=0, vjust=0) 


lengthViolinPlot

'
11 If you are interested in showing multiple features, simply add all of them to the same call. The order in which they
are called affects the order in which they are "stacked" on the plot. Pick your favorite 3 features and add them 
to your plot. 
Keep in mind, most gg_plot plots share code, so if you use the same functions on different "+ geom_xx()" variables, 
you can use these same methods to create a lot of different cool plots. 
'
### TYPE HERE ### 

'
Please prepare any takeaways you get from looking at these plots and their data. For example:
What new information do we get from a violin plot?
When would these plots be most useful?
What can we take away about the distribution of our data from these plots?
What is the most useful feature with a violin plot in your opinion? Why?
'




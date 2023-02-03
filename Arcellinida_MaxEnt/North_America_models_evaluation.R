" 
Author: Emma Schumacher
Description: Based on the MaxEnt Turtorials, adapted to run Arcellinida data on a
  North American shapefile (Canada/US/Mexico)
Last Run: 12/17
" 


" 
Creates the merged shapefile with USA/Mexico/Canada
Writes it to a folder called n_america in layers
" 
######################################################
############ 01A CLIPPING VARS SCRIPT #################
######################################################
'
install.packages("raster")
install.packages("maptools")
install.packages("rgdal") 
install.packages("ggplot2")
install.packages("magrittr")
install.packages("sf")
install.packages("dismo")   
'
# Load libraries
library(raster)
library(maptools)
library(rgdal) 
library(ggplot2)
library(magrittr)
library(sf) 
library(dismo) 

# make shapefile files
setwd("/Users/rgawron/Desktop/ETS_Maxent")

#https://www.worldclim.org/data/bioclim.html 
# Load study area shapefile
shp<-readOGR(file.path(getwd(),"layers/n_america/n_america_stuff.shp"))

######################################################
################ 02 DISMO SCRIPT #####################
######################################################
# Functions tp make files and folders I will need if they don't exist
make_fold <- function(name) {
  ifelse(!dir.exists(name), dir.create(name), FALSE) 
}
make_file <- function(name) {
  ifelse(!file.exists(name), file.create(name), FALSE) 
}

# PREPARING DATA

# Load environmental variables
layers<-list.files(path=file.path(getwd(), "layers/clipped_vars/"),pattern='asc',full.names=TRUE)

# Make the stack 
egv<-stack(layers)
#egv<-egv[[c("bio_04","bio_05","bio_06","bio_07","bio_16","bio_17","bio_19")]] #***

# Check egv structure
print(egv) 
# Descriptive statistics for environmental layers
summary(egv) 
# Check egv structure
print(egv)  

# Load species records
data.sp<-read.csv(file.path(getwd(), "/Arcellinida_Geo.csv"),sep=",",header=T) 
# Plot species records on geographical space
plot(data.sp)
 
# Split species records in training and testing data
## Using sample function
## 0.3 corresponds to testing proportion
## 30% as test points  
indexes = sample(1:nrow(data.sp),size=round(0.3*nrow(data.sp)))
## Split data in training and testing
data.train = data.sp[-indexes,]
data.test = data.sp[indexes,] 
# Extract background data
# Create a cloud of random points
backgr<-as.data.frame(randomPoints(egv,500))

# makes necessary files/folders if they don't exist
make_fold("dismo")
make_file("dismo/arcel_data.train.txt")
make_file("dismo/arcel_data.test.txt")
make_file("dismo/arcel_data.backgr.txt")

# Export training, test, and background data
write.table(data.train,file=file.path(getwd(), "dismo/arcel_data.train.txt"),sep='')
write.table(data.test,file=file.path(getwd(), "dismo/arcel_data.test.txt"),sep='')
write.table(backgr,file=file.path(getwd(), "dismo/arcel_data.backgr.txt"),sep='')
 
###################################################### INTERLUDE ***

# Plot environmental variables on geographical space 

# get info 
points <- st_as_sf(SpatialPoints(data.sp[,c("Y","X")],proj4string=CRS("+proj=longlat +datum=WGS84")))
points %>%  sf::st_set_crs(st_crs(shp))

plot(shp)
plot(points,col="red",pch=5, cex=1,add=T)

###################################################### INTERLUDE ***

# Plot training, test, and background data on geographical space

# makes necessary files/folders if they don't exist
make_fold("plot") 

# Reformat points to plot better
test_points <- st_as_sf(SpatialPoints(data.test[,c("Y","X")],proj4string=CRS("+proj=longlat +datum=WGS84")))
test_points %>%  sf::st_set_crs(st_crs(shp))

# Reformat points to plot better
train_points <- st_as_sf(SpatialPoints(data.train[,c("Y","X")],proj4string=CRS("+proj=longlat +datum=WGS84")))
train_points %>%  sf::st_set_crs(st_crs(shp))

# Reformat points to plot better 
bg_points <- st_as_sf(SpatialPoints(backgr[,c("x","y")],proj4string=CRS("+proj=longlat +datum=WGS84")))
bg_points %>%  sf::st_set_crs(st_crs(shp))

# Plot all 3 
tiff(file="plot/test_train_bg_points.tiff",
     width=3584, height=2066, units="px", res=300)
# Reset par function
par(mfrow=c(1,3))

plot(shp, main = "Test Points")
plot(test_points,col="blue",pch=5, cex=1, add=T)

plot(shp, main = "Train Points")
plot(train_points,col="#ff8c00",pch=5, cex=1, add=T)

plot(shp, main = "Background Points") 
plot(bg_points, col="darkgreen", pch=5, cex=1, add=T)

dev.off()

par(mfrow=c(1,1))
######################################################
# BIOCLIM

# Fix for insufficient data error
data.train <- data.train[, c("Y", "X")]
nrow(data.train)

# Calculate model 
bc<-bioclim(x = egv, p = data.train)
bc 

# Plot presence and pseudo-absence (background) data
# Colinearity in the environmental data
# X11()
tiff(file="plot/pair_train_bc.tiff",
     width=3584, height=2066, units="px", res=300)
pairs(bc)
dev.off()
# make pretty correlation matrix ??? ***

# Project the model ***
p.bc<-predict(bc,egv)
p.bc
# Plot the model in the geographical space 
plot(p.bc) 
# ***
r <- response(bc)
# Plot variable response curves
# X11()
tiff(file="plot/response_bc.tiff",
     width=28, height=16, units="in", res=300)
response(bc)
dev.off()
# Export Bioclim model
# check raster formats available to export the results
#?writeFormats
writeRaster(p.bc,file.path(getwd(), "dismo/bc_arcel"),format="HFA",overwrite=TRUE)

# Fix for insufficient data error 
data.test <- data.test[, c("Y", "X")]
# Evaluate the model 
e.bc<-dismo::evaluate(data.test,backgr,bc,egv)

# Check the evaluation results
str(e.bc)

# Save box and density plots for bioclim
tiff(file="plot/box_dens_bc_pa.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,2))
# Boxplot of presence and absence suitable values
# blue are absences, red are presences
# X11()
boxplot(e.bc,col=c('blue','red'), notch = FALSE)
# Density plot of presence and absence suitable values
# blue are absences, red are presences
# X11()
density(e.bc)
dev.off()

# Evaluation plots
# manually compute F1 score
f1 = 2*((e.bc@FPR*e.bc@TPR)/(e.bc@FPR+e.bc@TPR))
f1[is.na(f1)] <- 0
f1
# make main plots
tiff(file="plot/evaluation_bc.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(2,3))
# ROC
plot(e.bc,'ROC', pch = 19, cex = 1.5 )
# CCR: Correct classification rate
plot(e.bc,'CCR', pch = 19, cex = 1.5 )
# kappa: Cohen’s kappa
plot(e.bc,'kappa', pch = 19, cex = 1.5 )
# TPR: True positive rate
plot(e.bc,'TPR', pch = 19, cex = 1.5 )
# PPP: Positive predictive power
plot(e.bc,'PPP', pch = 19, cex = 1.5 )
# F1 score 
plot(e.bc@t,f1, pch = 19, cex = 1.5, col = "red", xlab = 'threshold', main = 'F1 Score - max at: 0')
lines(e.bc@t,f1, pch = 19, cex = 1.5, col = "red")
dev.off() 

# Extra evaluation plots
tiff(file="plot/conf_evaluation_bc.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(2,3))
# TPR: True positive rate
plot(e.bc,'TPR', pch = 19, cex = 1.5 )
# FPR: False positive rate
plot(e.bc,'FPR', pch = 19, cex = 1.5 )
# NPP: Negative predictive power
plot(e.bc,'NPP', pch = 19, cex = 1.5 )
# TNR: True negative rate
plot(e.bc,'TNR', pch = 19, cex = 1.5 )
# FNR: False negative rate
plot(e.bc,'FNR', pch = 19, cex = 1.5 )
# PPP: Positive predictive power
plot(e.bc,'PPP', pch = 19, cex = 1.5 )

dev.off() 


# Obtain the threshold
# kappa: the threshold at which kappa is highest ("max kappa")
# spec_sens: the threshold at which the sum of the sensitivity (true positive rate) and specificity (true negative rate) is highest
# no_omission: the highest threshold at which there is no omission
# prevalence: modeled prevalence is closest to observed prevalence
# equal_sens_spec: equal sensitivity and specificity
# sensitivity: fixed (specified) sensitivity
tr.b<-threshold(e.bc,'spec_sens')
# Get the value of the threshold
tr.b
# Calculate the thresholded model
tr.bc<- p.bc>tr.b
tr.bc
# Plot the p/a model in the geographical space
plot(tr.bc)
# Export p/a model
writeRaster(tr.bc, file.path(getwd(), "dismo/tr_bc_arcel"), format="HFA", overwrite=TRUE)

# Plot raw and p/a models
# X11(width = 10,height = 6)
tiff(file="plot/bc_v_pa.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,2))
plot(p.bc,main='(a) Bioclim, raw values')
points(data.train,pch='+')
plot(tr.bc,main='(b) Threshold, presence/absence')
points(data.train,pch='+')
dev.off()

# Reset par function
par(mfrow=c(1,1)) 
######################################################
# DOMAIN

# Calculate the model
dm<-domain(egv,data.train)
dm
# Plot presence and absence (background) data
# Colinearity in the environmental data
# X11()
tiff(file="plot/pair_train_dm.tiff",
     width=3584, height=2066, units="px", res=300)
pairs(dm)
dev.off()
# Project the model
p.dm<-predict(egv,dm)
p.dm
# Plot the model in the geographical space
plot(p.dm)
# Plot variable response curves
# X11()
tiff(file="plot/response_dm.tiff",
     width=28, height=16, units="in", res=300)
response(dm)
dev.off()

#?writeRaster  
# Export Domain model
writeRaster(p.dm, file.path(getwd(), "dismo/dm_arcel"),format="HFA",overwrite=TRUE)
# Evaluate the model
e.dm<-dismo::evaluate(data.test,backgr,dm,egv)
e.dm
# Check the evaluation results
str(e.dm)


# Save box and density plots for bioclim
tiff(file="plot/box_dens_dm_pa.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,2))
# Boxplot of presence and absence suitable values
# blue are absences, red are presences
# X11()
boxplot(e.dm,col=c('blue','red'), notch = FALSE)
# Density plot of presence and absence suitable values
# blue are absences, red are presences
# X11()
density(e.dm)
dev.off()

# Evaluation plots
# manually compute F1 score
f1 = 2*((e.dm@FPR*e.dm@TPR)/(e.dm@FPR+e.dm@TPR)) 
f1[is.na(f1)] <- 0
f1
# make main plots
tiff(file="plot/evaluation_dm.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(2,3))
# ROC
plot(e.dm,'ROC', pch = 19, cex = 1 )
# CCR: Correct classification rate
plot(e.dm,'CCR', pch = 19, cex = 1 )
# kappa: Cohen’s kappa
plot(e.dm,'kappa', pch = 19, cex = 1 )
# TPR: True positive rate
plot(e.dm,'TPR', pch = 19, cex = 1 )
# PPP: Positive predictive power
plot(e.dm,'PPP', pch = 19, cex = 1 )
# F1 score 
plot(e.dm@t,f1, pch = 19, cex = 1, col = "red", xlab = 'threshold', main = 'F1 Score - max at: 0')
lines(e.dm@t,f1, pch = 19, cex = 1, col = "red")
dev.off() 

# Extra evaluation plots
tiff(file="plot/conf_evaluation_dm.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(2,3))
# TPR: True positive rate
plot(e.dm,'TPR', pch = 19, cex = 1.5 )
# FPR: False positive rate
plot(e.dm,'FPR', pch = 19, cex = 1.5 )
# PPP: Positive predictive power
plot(e.dm,'PPP', pch = 19, cex = 1.5 )
# TNR: True negative rate
plot(e.dm,'TNR', pch = 19, cex = 1.5 )
# FNR: False negative rate
plot(e.dm,'FNR', pch = 19, cex = 1.5 )
# NPP: Negative predictive power
plot(e.dm,'NPP', pch = 19, cex = 1.5 )
dev.off() 

# reset par
par(mfrow=c(1,1))

# Obtain the threshold
# kappa: the threshold at which kappa is highest ("max kappa")
# spec_sens: the threshold at which the sum of the sensitivity (true positive rate) and specificity (true negative rate) is highest
# no_omission: the highest threshold at which there is no omission
# prevalence: modeled prevalence is closest to observed prevalence
# equal_sens_spec: equal sensitivity and specificity
# sensitivty: fixed (specified) sensitivity
tr.d<-threshold(e.dm,'spec_sens')
# Get the value of the threshold
tr.d
# Calculate the thresholded model
tr.dm<-p.dm>tr.d
tr.dm
# Plot the p/a model in the geographical space
# X11()
plot(tr.dm)
# Export p/a model
writeRaster(tr.dm, file.path(getwd(), "/dismo/tr_dm_arcel"),format="HFA",overwrite=TRUE)

# X11(width = 10,height = 6)
# Plot raw and p/a models
tiff(file="plot/dm_v_pa.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,2))
plot(p.dm,main='(a) Domain, raw values')
points(data.train,pch='+')
plot(tr.dm,main='(b) Threshold, presence/absence')
points(data.train,pch='+')
dev.off()
# Reset par function
par(mfrow=c(1,1))
 
######################################################

# Plot Bioclim and Domain
# X11()
tiff(file="plot/bc_v_dm.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,2))
plot(tr.bc,main='Bioclim')
plot(tr.dm,main='Domain')
dev.off()
# Reset par function
par(mfrow=c(1,1)) 

######################################################
# ENSEMBLE MODELS

# Mean raw model
avg<-((p.bc+p.dm)/2)
# X11()
plot(avg)

# Mean p/a model
avg2<-((tr.dm+tr.bc)/2)
plot(avg2)

# Mean model weighted by AUC values
avg3<-(((p.bc*e.bc@auc)+(p.dm*e.dm@auc))/2)
plot(avg3)  
# Plot mean models
tiff(file="plot/avg3_bc_dm.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,3))
plot(avg, main = "(a) Mean Raw Predictive Model")
plot(avg2, main = "(b) Mean Presence/Absence Threshold Model")
plot(avg3, main = "(c) Mean Predictive Model Weighted by AUC Values")
dev.off()

# Difference between p/a models
diff.m<-abs(tr.dm-tr.bc)
tiff(file="plot/pa_diff_bc_dm.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,3))
plot(tr.bc,main='Bioclim')
plot(tr.dm,main='Domain')
plot(diff.m, main = "Difference between Domain and Bioclim")
dev.off()
######################################################
# PROJECTING MODELS TO OTHER SCENARIOS

# Load environmental variables for 2050
layers2050<-list.files(path=file.path(getwd(), "/layers/clipped2050/"),pattern='asc',full.names=TRUE)
# Make the stack
egv2050<-stack(layers2050)
# Check egv structure
print(egv2050)
# Descriptive statistics for environmental layers
summary(egv2050)
# Select variables to include in the model
names(egv2050)
#egv2070<-egv2050[[c("bio_04","bio_05","bio_06","bio_07","bio_16","bio_17","bio_19")]] #***
# Check egv structure
print(egv2050)
# Plot environmental variables on geographical space
plot(egv2050) 


# Load environmental variables for 2070
layers2070<-list.files(path= file.path(getwd(), "/layers/clipped2070/"),pattern='asc',full.names=TRUE)
# Make the stack
egv2070<-stack(layers2070)
# Check egv structure
print(egv2070)
# Descriptive statistics for environmental layers
summary(egv2070)
# Select variables to include in the model
names(egv2070)
#egv2070<-egv2070[[c("bio_04","bio_05","bio_06","bio_07","bio_16","bio_17","bio_19")]] #***
# Check egv structure
print(egv2070)
# Plot environmental variables on geographical space
plot(egv2070)

#########################################
# Project models to future scenarios

# BIOCLIM
# Project the model to 2050
p.bc.50 = predict(egv2050,bc)
p.bc.50
# Plot the model in the geographical space
plot(p.bc.50)
# Export Bioclim 2050 model
writeRaster(p.bc.50,file.path(getwd(), "dismo/bc_arcel_2050"),format="HFA",overwrite=TRUE)

# Project the model to 2070
p.bc.70 = predict(egv2070,bc)
p.bc.70
# Plot the model in the geographical space
plot(p.bc.70)
# Export Bioclim 2070 model
writeRaster(p.bc.70,file.path(getwd(), "dismo/bc_arcel_2070"),format="HFA",overwrite=TRUE)

# Plot Bioclim current and future models
tiff(file="plot/future_bc.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(1,3))
plot(p.bc,main='Bioclim current')
plot(p.bc.50,main='Bioclim 2050')
plot(p.bc.70,main='Bioclim 2070')
dev.off()
# Reset par function
par(mfrow=c(1,1))

# DOMAIN
# Project the model to 2050
p.dm.50 = predict(egv2050,dm)
p.dm.50
# Plot the model in the geographical space
plot(p.dm.50)
# Export domain 2050 model
writeRaster(p.dm.50,file.path(getwd(), "dismo/dm_arcel_2050"),format="HFA",overwrite=TRUE)

# Project the model to 2070
p.dm.70 = predict(egv2070,dm)
p.dm.70
# Plot the model in the geographical space
plot(p.dm.70)
# Export domain 2070 model
writeRaster(p.dm.70,file.path(getwd(), "dismo/dm_arcel_2070"),format="HFA",overwrite=TRUE)

# Plot domain current and future models
tiff(file="plot/future_dm.tiff",
     width=28, height=16, units="in", res=300)
par(mfrow=c(1,3))
plot(p.dm,main='Domain current')
plot(p.dm.50,main='Domain 2050')
plot(p.dm.70,main='Domain 2070')
dev.off()
# Reset par function
par(mfrow=c(1,1))

# Plot bioclim and domain current and future models
tiff(file="plot/future_bc_dm.tiff",
     width=28, height=16, units="in", res=300)
par(mfrow=c(2,3))
plot(p.bc,main='Bioclim current')
plot(p.bc.50,main='Bioclim 2050')
plot(p.bc.70,main='Bioclim 2070')
plot(p.dm,main='Domain current')
plot(p.dm.50,main='Domain 2050')
plot(p.dm.70,main='Domain 2070')
dev.off()
# Reset par function
par(mfrow=c(1,1))

# Threshold all models
tr.bc.50<-p.bc.50>tr.b
tr.bc.70<-p.bc.70>tr.b
tr.dm.50<-p.dm.50>tr.d
tr.dm.70<-p.dm.70>tr.d

# Plot thresholded domain current and future models
tiff(file="plot/thrsh_future_dm.tiff",
     width=28, height=16, units="in", res=300)
par(mfrow=c(1,3))
plot(tr.dm,main='Domain current')
points(data.train,pch='+') 
plot(tr.dm.50,main='Domain 2050') 
plot(tr.dm.70,main='Domain 2070') 
dev.off()

# Plot thresholded bioclim current and future models
tiff(file="plot/thrsh_future_bc.tiff",
     width=28, height=16, units="in", res=300)
par(mfrow=c(1,3))
plot(tr.bc,main='Bioclim current')
points(data.train,pch='+') 
plot(tr.bc.50,main='Bioclim 2050') 
plot(tr.bc.70,main='Bioclim 2070') 
dev.off()

# Plot thresholded bioclim and domain current and future models
tiff(file="plot/thrsh_future_dm_v_bc.tiff",
     width=28, height=16, units="in", res=300)
par(mfrow=c(2,3))
plot(tr.bc,main='Bioclim current')
points(data.train,pch='+') 
plot(tr.bc.50,main='Bioclim 2050') 
plot(tr.bc.70,main='Bioclim 2070') 
plot(tr.dm,main='Domain current')
points(data.train,pch='+') 
plot(tr.dm.50,main='Domain 2050') 
plot(tr.dm.70,main='Domain 2070') 
dev.off()

# Reset par function
par(mfrow=c(1,1))

# plot threshold and predicted domain model
tiff(file="plot/future_dm_vs_pa.tiff",
     width=28, height=16, units="in", res=300)
par(mfrow=c(2,3))
plot(p.dm,main='Domain current')
points(data.train,pch='+')
plot(p.dm.50,main='Domain 2050')
plot(p.dm.70,main='Domain 2070')

plot(tr.dm,main='Domain current')
points(data.train,pch='+')
plot(tr.dm.50,main='Domain 2050')
plot(tr.dm.70,main='Domain 2070')
dev.off()

# plot threshold and predicted bioclim model
tiff(file="plot/future_bc_vs_pa.tiff",
     width=28, height=16, units="in", res=300)
par(mfrow=c(2,3))
plot(p.bc,main='Bioclim current')
points(data.train,pch='+')
plot(p.bc.50,main='Bioclim 2050')
plot(p.bc.70,main='Bioclim 2070')

plot(tr.bc,main='Bioclim current')

points(data.train,pch='+')
plot(tr.bc.50,main='Bioclim 2050')
plot(tr.bc.70,main='Bioclim 2070') 
dev.off()

#####################################

# Mean 2050 raw model
avg50<-((p.bc.50+p.dm.50)/2)
# X11()
plot(avg50)
# Mean 2070 raw model
avg70<-((p.bc.70+p.dm.70)/2)
plot(avg70)

# Mean p/a model
avgt50<-((tr.dm.50+tr.bc.50)/2)
plot(avgt50)
avgt70<-((tr.dm.70+tr.bc.70)/2)
plot(avgt70)
 
# Plot mean models
tiff(file="plot/avg3_bc_dm_future.tiff",
     width=3584, height=2066, units="px", res=300)
par(mfrow=c(2,3))
plot(avg, main = "(a) Mean Raw Predictive Model")
plot(avg50, main = "(a) Mean Raw Predictive Model 2050")
plot(avg70, main = "(a) Mean Raw Predictive Model 2070")
plot(avg2, main = "(b) Mean Presence/Absence Threshold Model") 
plot(avgt50, main = "(b) Mean Presence/Absence Threshold Model 2050") 
plot(avgt70, main = "(b) Mean Presence/Absence Threshold Model 2070") 
dev.off()


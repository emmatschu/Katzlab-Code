"""
Author: Emma Schumacher & <Taylors Teacher>
Description: Based on the MaxEnt Turtorials, adapted to run Arcellinida data on a
  North American shapefile (Canada/US/Mexico)
Last Run: 12/10
"""

'
Creates the merged shapefile with USA/Mexico/Canada
Writes it to a folder called n_america in layers
'
######################################################
############ 01A CLIPPING VARS SCRIPT #################
######################################################
 
library(ggplot2)
library(magrittr)
library(sf)

# cut it down
tmax_data <- getData(name = "worldclim", var = "tmax", res = 10)
gain(tmax_data)=0.1
tmax_mean <- mean(tmax_data)

# make america, mexico, and canada shapefiles
usa_sf <- sf::st_as_sf(maps::map("world", "usa", plot = FALSE, fill = TRUE), xlim = c(-180, -50), ylim = c(13, 72))
mexico_sf <- sf::st_as_sf(maps::map(region = "mexico", plot = FALSE, fill = TRUE))
canada_sf <- sf::st_as_sf(maps::map(region = "canada", plot = FALSE, fill = TRUE))

us_crop <- st_crop(usa_sf, xmin = -180, xmax = -50, ymin = 13, ymax = 72)
plot(us_crop)

# combine them into a big shapefile
n_america_sf = rbind(us_crop, mexico_sf,canada_sf)
plot(n_america_sf)
# make shapefile files
setwd("/Users/emmaschumacher/Desktop/MaxEnt/ARcmap")
sf::st_write(n_america_sf, dsn=file.path(getwd(),"/layers/n_america"),layer="n_america_stuff",driver="ESRI Shapefile")
 
'
1. Loads the shapefiles created previously
2. Dowloads environmental layers from worldclim (averages from 1970-2000 ***) 
and from CMIP5 (predicted layers from 2050 and 2070)
3. Crops those layers down to the areas I am interested in (North America)
4. Saves the cropped layers to subfolder in the folder "layers"
'
######################################################
############ 01B CLIPPING VARS SCRIPT #################
######################################################
#install.packages('geodata')

# Load libraries
library(raster)
library(maptools)
library(rgdal)  
library(geodata)

#https://www.worldclim.org/data/bioclim.html 
# Load study area shapefile
shp<-readOGR(file.path(getwd(),"/layers/n_america/n_america_stuff.shp"))

# path to drop off clipped layers
path2cliplayers<-file.path(getwd(), "/layers/clipped_vars/")
# setting up layers (https://www.rdocumentation.org/packages/raster/versions/3.5-15/topics/getData) https://www.gis-blog.com/r-raster-data-acquisition/
# https://cran.r-project.org/web/packages/geodata/geodata.pdf#page=3&zoom=100,133,273
# https://www.dkrz.de/en/communication/climate-simulations/cmip6-en/the-ssp-scenarios
layers <- cmip6_world("CNRM-ESM2-1", "245", "2021-2040", var="bioc", res=2.5, path="layers/clipped_vars")
layers50 <- cmip6_world("CNRM-ESM2-1", "245", "2041-2060", var="bioc", res=2.5, path="layers/clipped2050")
layers70 <- cmip6_world("CNRM-ESM2-1", "245", "2061-2080", var="bioc", res=2.5, path="layers/clipped2070")

# Join all rasters in a single object
### https://search.r-project.org/CRAN/refmans/geodata/html/cmip6.html
egv<-stack(layers)
egv50<-stack(layers50)
egv70<-stack(layers70)
# check the structure of the rasters
print(egv)
# check descriptive statistics of the rasters
summary(egv)
# Plot the stack
#x11() #if the following plot is not represented correctly: with x11 a new window is open
plot(egv) 
plot(egv50)
plot(egv70)

# Plot the shapefile
plot(shp)

#layers<-layers[c(-3,-14,-15)] 

# Loop to clip each raster sequentially
for (j in 1:nlayers(layers)) { # look for each ascii file in layers
  # the raster to be clipped; the clipping feature; snap determines in which direction the extent should be aligned
  # to the nearest border, inwards or outwards
  clip.r <-crop(egv[[j]], shp, snap="in") 
  
  # manually names them
  if (j < 10) {
    names(clip.r) <- paste(c("bio_0", j), collapse = "")
  }
  else{
    names(clip.r) <- paste(c("bio_", j), collapse = "") 
  }
    
  # plot the clipped raster 
  plot(clip.r,main=clip.r@data@names)
  
  #mask raster with the shapefile to create NoData
  mask.r<-mask(clip.r, shp)
  # plot the masked raster 
  plot(mask.r,main=mask.r@data@names)
  # Get name of the band
  name<-mask.r@data@names
  print(name)
  # export the raster to a folder using paste
  writeRaster(mask.r,paste(path2cliplayers,name,sep=''),format="ascii", overwrite=TRUE)
}
for (j in 1:nlayers(layers50)) { # look for each ascii file in layers
  # the raster to be clipped; the clipping feature; snap determines in which direction the extent should be aligned
  # to the nearest border, inwards or outwards
  clip.r <-crop(egv50[[j]], shp, snap="in") 
  
  # manually names them
  if (j < 10) {
    names(clip.r) <- paste(c("bio_0", j), collapse = "")
  }
  else{
    names(clip.r) <- paste(c("bio_", j), collapse = "") 
  }
  
  # plot the clipped raster 
  plot(clip.r,main=clip.r@data@names)
  
  #mask raster with the shapefile to create NoData
  mask.r<-mask(clip.r, shp)
  # plot the masked raster 
  plot(mask.r,main=mask.r@data@names)
  # Get name of the band
  name<-mask.r@data@names
  print(name)
  # export the raster to a folder using paste
  writeRaster(mask.r,paste(file.path(getwd(), "/layers/clipped2050/"),name,sep=''),format="ascii", overwrite=TRUE)
}
for (j in 1:nlayers(layers70)) { # look for each ascii file in layers
  # the raster to be clipped; the clipping feature; snap determines in which direction the extent should be aligned
  # to the nearest border, inwards or outwards
  clip.r <-crop(egv70[[j]], shp, snap="in") 
  
  # manually names them
  if (j < 10) {
    names(clip.r) <- paste(c("bio_0", j), collapse = "")
  }
  else{
    names(clip.r) <- paste(c("bio_", j), collapse = "") 
  }
  
  # plot the clipped raster 
  plot(clip.r,main=clip.r@data@names)
  
  #mask raster with the shapefile to create NoData
  mask.r<-mask(clip.r, shp)
  # plot the masked raster 
  plot(mask.r,main=mask.r@data@names)
  # Get name of the band
  name<-mask.r@data@names
  print(name)
  # export the raster to a folder using paste
  writeRaster(mask.r,paste(file.path(getwd(), "/layers/clipped2070/"),name,sep=''),format="ascii", overwrite=TRUE)
}

# plot all clipped variables
files<-list.files(path=path2cliplayers,pattern='asc',full.names=TRUE)
# Join all rasters in a single object
clips<-stack(files)
# Plot the stack
plot(clips)

install.packages("raster")
install.packages("GADMTools")
install.packages("rgdal")
library(tidyverse)
library(raster)
library(rgdal)
library(GADMTools)
r <- raster(ext=extent(14.12288, 24.14578, 49.00204, 54.83642), res=c(.014,.014))
ncell(r)
mapPOL <- gadm.loadCountries("POL", basefile = "./")
plotmap(mapPOL)
mapPOL
p <- rasterToPolygons(r)
mapPol.df <- fortify(mapPOL$spdf)
p.df <- fortify(p)
ggplot(data=mapPol.df) +
  geom_polygon(data=p.df, aes(x=long,y=lat, group=group),colour="purple")+
 geom_path(aes(x=long, y=lat, group=group))
p@polygons

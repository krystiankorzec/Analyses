#if(!requireNamespace("devtools")) install.packages("devtools")
#devtools::install_github("dkahle/ggmap", ref = "tidyup", force=TRUE)
#library(ggmap)
#ggmap::register_google(key = "")

cde<- get_map(location = c(lon = 21.2149435, lat = 52.2463433),
                         color = "color",
                         source = "google",
                         maptype = "satellite",
                         zoom = 19)



ggmap(cde,
      extent = "device",
      ylab = "Latitude",
      xlab = "Longitude")

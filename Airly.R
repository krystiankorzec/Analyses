setwd("c:/users/kkorze01/desktop/traffic")
library(tidyverse)
library(httr)
library(jsonlite)
req <- GET("https://airapi.airly.eu/v2/measurements/nearest?lat=50.062006&lng=19.940984&maxDistanceKM=5", 
           authenticate("user", "pass", type = "basic"),
           add_headers(auth_appkey = "TneT08fQ2LFRpTYINqsg6AkDKUP4m6TD"))
req

req <-GET(url = adres, query = list(api_key = "TneT08fQ2LFRpTYINqsg6AkDKUP4m6TD"))

apikey <- "TneT08fQ2LFRpTYINqsg6AkDKUP4m6TD"
adres1 <-"https://airapi.airly.eu/v2/installations/nearest?lat=52.2326046&lng=20.7803207&maxDistanceKM=20&maxResults=-1"
adres2 <-"https://airapi.airly.eu/v2/measurements/nearest?lat=52.2326046&lng=20.7803207&maxDistanceKM=5"
req <- GET(paste0(adres1,"&apikey=",apikey))
req.json <- content(req,'text')
req.df <- fromJSON(req.json, simplifyDataFrame = TRUE)
req.df$location$latitude





library(mapview)
library(sp)
airly.spdf <- SpatialPointsDataFrame(coords = data.frame("Long" = req.df$location$longitude,
                                                "Lat"=req.df$location$latitude),data = data.frame("Sponsor" = req.df$sponsor$name,
                                                                                                  "ID"=req.df$id))

airly.spdf@proj4string <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

mapview(airly.spdf)
get_data = function(url) {
  busy.get = GET(url =url)
  return(busy.get)
}
# get_data2() is a get_data() function with error handling
get_data2 <- purrr::possibly(get_data, otherwise = NA)
apikey <- "TneT08fQ2LFRpTYINqsg6AkDKUP4m6TD"
ids <- req.df$id
adres <-"https://airapi.airly.eu/v2/measurements/installation?installationId="
y<-paste0("START","id_",ids)
output <- list()
for(i in 1:length(ids)){
  print(i)
  url <-paste0(adres,ids[i],"&apikey=",apikey)
  x<-get_data2(url)
  output$wynik <- x
  names(output) <- y[1:i]
  Sys.sleep(time = 1.25)
  } 
  y<- append(y,paste0(Sys.time(),"id_",ids))
  
  
test.json <- content(output$STARTid_2593,'text')
test.df <- fromJSON(test.json, simplifyDataFrame = TRUE)
test.df$history$values

###################################################################################
#Pobieranie danych
#setwd("c:/users/kkorze01/desktop/traffic")
#install.packages("tidyverse")
library(tidyverse)
library(httr)
library(jsonlite)
api_key <- "aebedc5b-2c7e-479c-95dd-45c259ced7b9"
url_bus <- "https://api.um.warszawa.pl/api/action/busestrams_get/?resource_id="
resource_id <- "%20f2e5503e-%20927d-4ad3-9500-4ab9e55deb59"
busy.get = GET(url = paste0(url_bus, resource_id,"&apikey=",api_key,'&type=1'))

get_data = function(url) {
    busy.get = GET(url =url)
  return(busy.get)
}
get_data2 <- purrr::possibly(get_data, otherwise = NA)

url_busy = paste0(url_bus, resource_id,"&apikey=",api_key,'&type=1')
output2 <- list()
y<-"START"
while(Sys.time() < "2018-10-09 08:45:00 CEST"){
  timestamp()
  x<-get_data2(url = url_busy)
  output2$wyniki <- x
  names(output2) <- y
  y<- append(y,paste0(Sys.time()))
  Sys.sleep(time = 30)
}
##########################################################################################
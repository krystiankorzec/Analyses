#################################################################################
###############     Pobieranie danych z api.um.warszawa.pl       ################
#################################################################################
#setwd("c:/users/kkorze01/desktop/traffic")
#install.packages("tidyverse")
library(tidyverse)
library(httr)
library(jsonlite)
library(sf)
api_key <- "aebedc5b-2c7e-479c-95dd-45c259ced7b9"
url_bus <- "https://api.um.warszawa.pl/api/action/busestrams_get/?resource_id="
resource_id <- "%20f2e5503e-%20927d-4ad3-9500-4ab9e55deb59"
# Get posiotion of all buses in Warsaw; for trams change type to 2.
busy.get = GET(url = paste0(url_bus, resource_id,"&apikey=",api_key,'&type=1'))

#Function to get data in json format
get_data = function(url) {
  busy.get = GET(url =url)
  return(busy.get)
}
# get_data2() is a get_data() function with error handling
get_data2 <- purrr::possibly(get_data, otherwise = NA)

url_trams = paste0(url_bus, resource_id,"&apikey=",api_key,'&type=2')
url_busy = paste0(url_bus, resource_id,"&apikey=",api_key,'&type=1')
output2 <- list()
y<-"START"
# While loop returns a list named output. Name of each element of output list
# is named using time stamp of its request.
while(Sys.time() < "2018-10-12 13:03:00 CEST"){
  timestamp()
  x<-get_data2(url = url_busy)
  output2$wyniki <- x
  names(output2) <- y
  y<- append(y,paste0(Sys.time()))
  Sys.sleep(time = 30)
}
##########################################################################################
########################          Przetwarzanie danych          ##########################
##########################################################################################
# Funkcja zwraca ramke danych z 5 kolumnami Lat, Long, Time, Lines, Brigade
get_bus <- function(response){
  if(is.na(response)){
    return("Error")
  }
  if(content(response) == "Błędna metoda lub parametry wywołania" ||
     is.null(content(response)) ){
    return("Error")
  }
    wynik <-  toJSON(content(response),digits=10) %>% fromJSON() 
    wynik <- wynik$result
    wynik <- apply(wynik,2,function(x) unlist(x)) %>% as_tibble()
    wynik$Time <- parse_datetime(wynik$Time)
    wynik[,c("Lat","Lon","Lines", "Brigade")] <- 
    apply(wynik[,c("Lat","Lon","Lines", "Brigade")],2, 
        function(x) parse_double(x)) %>% as_tibble()
return(wynik)
}

bus <- function(response){
  k=1
  print(paste0(k,"/",length(response)))
  wynik <- get_bus(response[[1]])
  for(i in response[-1]){
    k=k+1
    print(paste0(k,"/",length(response)))
    out <- get_bus(i)
    
    if(is.null(out)){
      next
      }
    if(class(out)=="character"){
      out <- data.frame(NA,NA,NA,NA,NA)
      colnames(out) <- c("Lat","Lon","Time","Lines","Brigade")
    }
    wynik <- rbind(wynik, out)
    
  }
  return(wynik)  
}
#############################################################
############        Main      ###############################
#############################################################
bus <- bus(response=output2)

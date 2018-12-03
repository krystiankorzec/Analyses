library(tidyverse)
library(httr)
library(jsonlite)
apikey <- "08x6sSF4ibdLggBLGrWS6TfpWIdVovPv"
apikey2 <- "TneT08fQ2LFRpTYINqsg6AkDKUP4m6TD"
adres1 <-"https://airapi.airly.eu/v2/installations/nearest?lat=52.2326046&lng=20.7803207&maxDistanceKM=35&maxResults=-1"
adres2 <-"https://airapi.airly.eu/v2/measurements/installation?installationId="

response <- GET(paste0(adres1,"&apikey=",apikey))
sensors <- content(response, 'text') %>% fromJSON()
ids <- sensors$id
best_sensors <- list()
for(i in ids){
  test <- GET(paste0(adres2,i,"&apikey=",apikey))
  test_df <- content(test,'text') %>% fromJSON()
  war <- test_df$history$values[[1]] %>% nrow() 
  try(if(war == 6){
    best_sensors<- append(best_sensors,i)
  })
  Sys.sleep(time=2)
}
best_sensors <- unlist(best_sensors)
sensors_df <- data_frame(ID= sensors$id,
                         Longitude = sensors$location$longitude,
                         Latitude = sensors$location$latitude)

sensors_best <- filter(sensors_df, ID %in% best_sensors)
######################################################################
##########          Data in tidy format       ########################
######################################################################
test <- GET(paste0(adres2,best_sensors[1],"&apikey=",apikey))
test_df <- content(test,'text') %>% fromJSON()
pomiary <- matrix(ncol=8, nrow=1)
colnames(pomiary) <- c("ID","Time",test_df$history$values[[1]][,1])
pomiary[1,1]<-best_sensors[1]  
pomiary[1,2]<-test_df$history$fromDateTime[[1]]  
pomiary[1,3:8]<-test_df$history$values[[1]][,2]
for(l in 2:24){
  out <- matrix(ncol=8, nrow=1)
  colnames(out) <- c("ID","Time",test_df$history$values[[1]][,1])
  out[1,1]<- best_sensors[1] 
  out[1,2] <- test_df$history$fromDateTime[[l]]  
  out[1,3:8]<-test_df$history$values[[l]][,2]
  pomiary <- rbind(pomiary, out)
}

k=1
for(i in best_sensors[-1]){
  print(paste0("Pozostało: " , length(best_sensors[-1])-k))
  test <- GET(paste0(adres2,i,"&apikey=",apikey))
  test_df <- content(test,'text') %>% fromJSON()
  for(m in 1:24){
    out <- matrix(ncol=8, nrow=1)
    colnames(out) <- c("ID","Time",test_df$history$values[[1]][,1])
    out[1,1]<- i
    out[1,2] <- test_df$history$fromDateTime[[m]]  
    if(nrow(test_df$history$values[[m]])< 6){
      out[1,3:8]<-rep(NA, 6)
      pomiary <- rbind(pomiary, out)
      next
    }
    out[1,3:8]<-test_df$history$values[[m]][,2]
    pomiary <- rbind(pomiary, out)
  }
  k=k+1
  Sys.sleep(time=5)
}
pomiary <- as_data_frame(pomiary)
pomiary$ID <- as.numeric(pomiary$ID)
pomiary <- left_join(pomiary, sensors_best, by="ID")

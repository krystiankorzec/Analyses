library(tidyverse)
library(haven)
library(httr)
library(jsonlite)

GET("https://bdl.stat.gov.pl/api/v1/subjects?format=json&page-size=100",
    config = add_headers(.headers = c("X-ClientId"="777f5e42-d273-4124-4dd5-08d681e23da9"))) %>% content("text") %>%
  fromJSON()

GET("https://bdl.stat.gov.pl/api/v1/subjects?parent-id=K18&format=json&page-size=100",
    config = add_headers(.headers = c("X-ClientId"="777f5e42-d273-4124-4dd5-08d681e23da9"))) %>% content("text") %>%
  fromJSON()

GET("https://bdl.stat.gov.pl/api/v1/subjects?parent-id=G240&format=json&page-size=100",
    config = add_headers(.headers = c("X-ClientId"="777f5e42-d273-4124-4dd5-08d681e23da9"))) %>% content("text") %>%
  fromJSON()

GET("https://bdl.stat.gov.pl/api/v1/Variables?subject-id=P3443&format=json&page-size=100",
    config = add_headers(.headers = c("X-ClientId"="777f5e42-d273-4124-4dd5-08d681e23da9"))) %>% content("text") %>%
  fromJSON()

get_gus <- function(var,lvl){
  output <- list()
  dane <- GET(paste0("https://bdl.stat.gov.pl/api/v1/data/by-variable/",var,"?format=json&unit-level=",lvl,"&page-size=100&page=0"),
              config = add_headers(.headers = c("X-ClientId"="777f5e42-d273-4124-4dd5-08d681e23da9"))) %>% 
    content("text") %>% fromJSON()
  ind <- dane$totalRecords %/% 100
  print(ind)
  for(i in 0:ind){
    dane <- GET(paste0("https://bdl.stat.gov.pl/api/v1/data/by-variable/",var,"?format=json&unit-level=",lvl,"&page-size=100&page=",i),
              config = add_headers(.headers = c("X-ClientId"="777f5e42-d273-4124-4dd5-08d681e23da9"))) %>% 
      content("text") %>% fromJSON()
    data_list <- Map(cbind, dane$results$values, region=dane$results$name)  
    data_list2 <- Map(cbind, data_list, id=dane$results$id)
    out <- Map(cbind, data_list2, zmienna=var) %>% bind_rows() 
    nazwa <- paste0("str_",i,"/var=",var)
    output[[nazwa]] <- out
}
return(output)
}
# list of list of data frames to list of data frames
# unlist(dane_gus, recursive = F)
dane_gus<-list(get_gus(var=563224,lvl=6),
          get_gus(var=563225,lvl=6),
          get_gus(var=563226,lvl=6),
          get_gus(var=563227,lvl=6),
          get_gus(var=563228,lvl=6),
          get_gus(var=563229,lvl=6),
          get_gus(var=563230,lvl=6),
          get_gus(var=415,lvl=6)) 

create_df <- function(df_list){
  dane <-  df_list %>% bind_rows() %>% 
    mutate(teryt_gminy = paste0(substr(id,3,4),substr(id,8,12)),
         rodzaj=case_when(substr(id,12,12)== 1 ~ "gmina miejska",
                   substr(id,12,12)== 2 ~ "gmina wiejska",
                   substr(id,12,12)== 3 ~ "gmina miejsko-wiejska",
                   substr(id,12,12)== 4 ~ "miasto",
                   substr(id,12,12)== 5 ~ "obszar wiejski",
                   substr(id,12,12)== 8 ~ "dzielnica",
                   substr(id,12,12)== 9 ~ "delegatura"))
  return(dane)
}

dict <- data_frame(zmienna = c(415,
                               563224,
                               563225,
                               563226,
                               563227,
                               563228,
                               563229,
                               563230),
                   opis = c("mieszkania ogó³em",
                            "bezrobotni mezczyzni",
                            "bezrobotne kobiety",
                            "bezrobotni ogolem",
                            "bezrobotni dlugotrwale",
                            "bezrobotni > 50 roku",
                            "bezrobotni < 25 roku",
                            "bezrobotni < 30 roku"))



#######################################################################################
#################################    Testy    #########################################
#######################################################################################


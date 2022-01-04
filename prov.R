library(osmdata)
library(tidyverse)
buech.bb <- getbb('buech')
zone_map <- ggmap::get_stamenmap(bbox = buech.bb,
                                 zoom = 14)
sisteron <- data.frame(lat= 44.1947, lon = -5.9432,
                    text = 'Sisteron')
zone_map %>%
  ggmap::ggmap() +
  geom_point(data = sisteron, aes(x= lon, y = lat), col = 'red')

library(sf)



f <- list.files("/home/metienne/ownCloud/shp/IGN", recursive = TRUE, full.names = TRUE)
dir <- tibble(filename= f) %>%   filter(str_detect(filename, pattern = "COURS_D_EAU.shp") ) %>%mutate(filename = str_remove(filename, "/COURS_D_EAU[:print:]+")) %>% pull()


## definition bassin versant buech
buech.bv.list <- lapply(dir, function(d){
  dep <- st_read(dsn = d,
                  layer = "BASSIN_VERSANT_TOPOGRAPHIQUE")   
  buech.bv <- dep %>% 
    filter(str_detect(TOPONYME, "Buëch")) 
})

buech.bv  <-  do.call("bind_rows", buech.bv.list) %>% st_union()
p1 <- buech.bv %>% ggplot() + geom_sf()


### Le cours d'eau pricipal
buech.list <- lapply(dir, function(d){
  dep <- st_read(dsn = d,
                 layer = "COURS_D_EAU")   
  dep %>% 
    filter(str_detect(TOPONYME, "Buëch")) 
  buech
})

buech  <-  do.call("bind_rows", buech.list) %>% st_union()


p1 + geom_sf(data=buech) 

top <- st_read(dsn=d, layer = "TOPONYMIE_HYDROGRAPHIE") 
top %>% filter(str_detect(GRAPHIE, "Buëch"))


top.list <- lapply(dir, function(d){
  top <- st_read(dsn = d,
                  layer = "TOPONYMIE_HYDROGRAPHIE")  
  top %>% filter(str_detect(GRAPHIE, "buëch"))
})  



top.site <- lapply(dir, function(d){
  top <- st_read(dsn = d,
                 layer = "TOPONYMIE_HYDROGRAPHIE")  
  top %>% filter(str_detect(GRAPHIE, "(^riou froid)|(le lunel)|(l'aiguebelle)|(agnielles)|(petit buëch)|(channe)|(^riou$)|(chauranne)|(blème)|(blaisance)|(céans)|(^la méouge)|(clarescombes)|(veragne)"))
})  
do.call("bind_rows",top.site)

buech.id  <- do.call("bind_rows",top.list) %>% 
  select(ID) %>% st_drop_geometry() %>% 
  pull() %>% unique()


## Noeud NOEUD_HYDROGRAPHIQUE

affluent.id.list <- lapply(dir, function(d){
  noeud <- st_read(dsn = d,
                 layer = "NOEUD_HYDROGRAPHIQUE")  
  noeud %>% filter(ID_CE_AVAL %in% buech.id) %>% select(ID_CE_AMON, ID_CE_AVAL) %>% 
    mutate(name = str_remove(ID_CE_AMON, pattern = glue::glue("/?{ID_CE_AVAL}/?"))) %>% 
    select(name)
})  


affluent.id <- do.call("bind_rows", affluent.id.list ) %>% st_drop_geometry() %>% pull()

affluent.list <- lapply(dir, function(d){
    dep <- st_read(dsn = d,
                 layer = "COURS_D_EAU")   
  dep %>% 
    filter(ID %in% affluent.id) 
})

affluent <- do.call("bind_rows", affluent.list)


buech <- buech %>% mutate(type="Buëch")
affluent <- affluent %>% mutate(type="affluent") %>% bind_rows(buech)

p2 <- p1 + geom_sf(data=affluent, aes(col= type)) 



## Lieux nommés


dir.hab <- tibble(filename= f) %>%   filter(str_detect(filename, pattern = "ZONE_D_HABITATION.shp") ) %>%mutate(filename = str_remove(filename, "/COURS_D_EAU[:print:]+")) %>% pull()

hab.list <- lapply(dir.hab, function(d){
  hab <- st_read(dsn = d,
                   layer = "ZONE_D_HABITATION") %>% st_intersection(buech.bv)
  hab
})  


hab <- do.call("bind_rows", hab.list) 
hab <- hab %>% filter(IMPORTANCE %in% c("1"))

p2 + geom_sf(data=hab, col="green")

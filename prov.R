
library(tidyverse)
library(sf)

point_rem <- data.frame(lat=   c(44.17,44.20, 44.23, 44.32, 44.34, 44.41, 44.44, 44.53, 44.6, 44.7, 44.63, 44.68, 44.66, 44.64, 44.58, 44.53, 44.50, 44.49, 44.46, 44.44,44.425, 44.418, 44.39, 44.37, 44.34, 44.32, 44.31, 44.30, 44.28, 44.26), 
                        lon =  c(5.94623,5.87, 5.78, 5.74, 5.72, 5.69, 5.70, 5.67, 5.68, 5.7, 5.71, 5.79, 5.75, 5.76, 5.78, 5.75, 5.74, 5.75, 5.73, 5.73, 5.73, 5.76, 5.78, 5.75, 5.78, 5.82, 5.79, 5.85, 5.84, 5.85), 
                        text = c('Sisteron','15', '14.1', '9.3', '9.2', '8.1', '7.1', '5.1', '3.1', "1.2", "3", "1", "2", "1.1", "3.2", "4", "5", "6.1", "6", "7", "8", "8.1", "9.1", "9", "10", "11.1", "B11", "B12", "B13", "B14")) %>% st_as_sf(coords=c(2,1),
                                                    crs = 'epsg:4326') %>% 
  st_transform(crs = 'epsg:2154')




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
})

buech  <-  do.call("bind_rows", buech.list) %>% st_union() %>% st_as_sf(type= "Buech") %>% mutate(geometry=x) 

 


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


affluent <- affluent %>% mutate(type="Affluent") %>% bind_rows(buech) %>% arrange(type )

library(plotly)
p2 <- p1 + geom_sf(data=affluent, aes(col= type))  + 
  geom_sf(data=point_rem[1,], col = "red") + geom_sf_text(data=point_rem, aes(label = text),size=3,family="sans") + scale_color_manual(values = c(  "#0fa4ac", "#0f3773"))

plotly::ggplotly(p2)

ggsave(plot = p2, filename = "buech_map.png")

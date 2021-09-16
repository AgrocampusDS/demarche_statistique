#############################################################
##  
##
##
#############################################################


## Importer 'penguins.csv' pour le stocker dans l'objet penguins
penguins <- read.table('penguins.csv', sep = ';', header = TRUE)
summary(penguins)

library(tidyverse)

penguins <- rename(.data = penguins, longueur_bec = bill_length_mm, 
                   epaisseur_bec = bill_depth_mm)
penguins <- rename(.data = penguins, espece = species, 
                   poids = body_mass_g,
                   longueur_nageoire = flipper_length_mm,
                   sexe = sex, 
                   annee = year,
                   ile = island)


### Visualiser des données

library(ggplot2)

ggplot(data = penguins) + geom_bar(aes(x = espece))

ggplot(data = penguins) + geom_histogram(aes(x = long_bec))

p1 <- ggplot(data = penguins) + geom_histogram(aes(x = long_bec))


ggplot(data = penguins) + geom_histogram(aes(x = long_bec), bins = 10)

ggplot(data = penguins) + geom_histogram(aes(x = long_bec, y=..density..))

p1 + 
  ggtitle('Distribution des longueurs de becs chez les manchots')
  

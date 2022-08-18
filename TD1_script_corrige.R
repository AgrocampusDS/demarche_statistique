#############################################################
##  
##
##
#############################################################

## Importer 'penguins.csv' pour l'afficher à l'écran
read.table('penguins.csv', sep = ',', header = TRUE)

## Importer 'penguins.csv' pour le stocker dans l'objet penguins
penguins <- read.table('penguins.csv', sep = ';', header = TRUE)


summary(penguins)

library(tidyverse)

penguins <- rename(.data = penguins, long_bec = bill_length_mm, 
                   epais_bec = bill_depth_mm)


penguins <- rename(.data = penguins, espece = species, 
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
  

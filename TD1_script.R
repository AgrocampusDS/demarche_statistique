#############################################################
##  
##
##
#############################################################

## Importer 'penguins.csv' pour l'afficher à l'écran
read.table('penguins.csv', sep = ';', header = TRUE)

## Importer 'penguins.csv' pour le stocker dans l'objet penguins
penguins <- read.table('penguins.csv', sep = ';', header = TRUE)

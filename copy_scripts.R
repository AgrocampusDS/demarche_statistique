filenames <- list.files( pattern = '_script.R',
                        full.names = TRUE)

for(f_ in filenames){
  system(glue::glue( 'cp {f_} build/.'))
}

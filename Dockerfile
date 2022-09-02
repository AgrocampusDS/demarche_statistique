FROM rocker/verse:latest
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
 && apt-get install -y pandoc \
    pandoc-citeproc
RUN R -e "install.packages(c('emmeans','kableExtra','car', 'remotes'))"
RUN R -e "install.packages(c('multcomp'))"
RUN R -e "remotes::install_github(repo='haozhu233/kableExtra', ref='a6af5c0')"
RUN R -e "install.packages(c('ggcorrplot', 'GGally'))"
RUN R -e "remotes::install_github('husson/FactoMineR')"

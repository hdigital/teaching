# parent image — R/tidyverse version June 2022
# https://cran.r-project.org/bin/windows/base/old/
FROM rocker/tidyverse:4.2.1

# install dependencies — sf package
RUN apt-get -y update && apt-get install -y  libudunits2-dev libgdal-dev libgeos-dev libproj-dev

# install R packages
RUN install2.r DT markdown sf

WORKDIR /home/rstudio

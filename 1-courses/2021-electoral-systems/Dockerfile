# parent image — R/tidyverse version August 2021
FROM rocker/tidyverse:4.1.1

# install dependencies — sf package
RUN apt-get -y update && apt-get install -y  libudunits2-dev libgdal-dev libgeos-dev libproj-dev

# install R packages
RUN install2.r broom.mixed countrycode DT estimatr ggeffects janitor lme4 lwgeom markdown patchwork sf skimr WDI

WORKDIR /home/rstudio

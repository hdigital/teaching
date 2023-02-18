# parent image — R/tidyverse version specified
# https://cran.r-project.org/doc/manuals/r-release/NEWS.html
FROM rocker/tidyverse:4.2.2

# install Linux dependencies — sf package
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev

# install R packages
RUN install2.r \
    ggeffects \
    patchwork \
    reactable \
    rmarkdown \
    skimr \
    sf

WORKDIR /home/rstudio

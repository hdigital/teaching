# parent image — R/tidyverse version specified
# https://cran.r-project.org/doc/manuals/r-release/NEWS.html
FROM rocker/tidyverse:4.3.0

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

# install Quarto
RUN apt-get -y update && apt-get install -y --no-install-recommends curl gdebi-core
RUN curl -LO https://quarto.org/download/latest/quarto-linux-amd64.deb
RUN gdebi --non-interactive quarto-linux-amd64.deb
RUN install2.r markdown reticulate

WORKDIR /home/rstudio

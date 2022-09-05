library(tidyverse)
library(glue)


## Get data ----

if(FALSE) {
  vdem <- read_csv("2-evolution-v-dem/Country_Year_V-Dem_Full+others_CSV_v11.1/V-Dem-CY-Full+Others-v11.1.csv")
  write_rds(vdem, "2-evolution-v-dem/source__Country_Year_V-Dem_Full-11.1.rds")
}

if(! exists("vdem")) {
  vdem <- read_rds("2-evolution-v-dem//source__Country_Year_V-Dem_Full-11.1.rds")
}

country <- 
  vdem %>% 
  rename(country=country_text_id) %>% 
  group_by(country, country_name) %>% 
  summarise(year_first = min(year), year_last = max(year))

# write.csv(country, 'v-dem_country.csv', na='', fileEncoding = "utf-8", row.names = FALSE)


## Explorative ----

vars <- 
  vdem %>%
  select(country_name, country_text_id, starts_with("e__region"), year, v2x_polyarchy, v2ellocons:v2ellovtsm)

write_csv(vars, '2-evolution-v-dem/vdem-vars.csv')

library(tidyverse)
library(rnaturalearth)

## World data ----

world_raw <- ne_countries(scale = "small", returnclass = "sf")

world <- 
  world_raw %>% 
  filter(! name %in% c("Antarctica", "Seven seas (open ocean)")) %>% 
  select(country = adm0_a3, name, continent)

write_rds(world, "ne-worldmap.rds")


## German states ----

deu_raw <- ne_states(country = "Germany", returnclass = "sf")

deu <- 
  deu_raw %>% 
  mutate(state = substr(iso_3166_2, 4, 5)) %>% 
  select(country = adm0_a3, name)

write_rds(deu, "ne-german-states.rds")

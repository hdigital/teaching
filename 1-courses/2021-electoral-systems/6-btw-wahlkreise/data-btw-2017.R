library(sf)         # plot maps and gespatial tools
library(tidyverse)
# janitor::


csv_source <- "6-btw-wahlkreise/source__data-btw17/btw2017_kerg.csv"

## Read data ----

party_raw <- read_csv("6-btw-wahlkreise/source__data/btw-party.csv")


bw_raw <- 
  read_delim(
    csv_source,
    delim = ";",
    col_names = FALSE,
    skip = 5
  )

bw_w <- 
  bw_raw %>% 
  mutate(
    source = str_remove(csv_source, fixed(".csv")),
    level = case_when(
      X2 == "Bundesgebiet" ~ "federal",
      X3 == "99" ~ "state",
      TRUE ~ "district",
    )
  ) %>%
  relocate(c(source, level), .before = X1)


## Fix variable names ----

var_names <- 
  t(bw_w[1:3, ]) %>% 
  as_tibble(.name_repair = "universal") %>%
  mutate(...3 = if_else(is.na(...3), "Endgültig", ...3)) %>%  # for 1953 election
  fill(everything()) %>% 
  unite("variable", sep = "__")
  
bw_w <- bw_w %>% slice(4:n())
names(bw_w) <- var_names %>% pull(variable)
names(bw_w)[1:2] <- c("source", "level")
names(bw_w)[3:5] <- c("wkr_nr", "wkr_name", "land_nr")


## Clean long data ----

bw_l <- 
  bw_w %>% 
  pivot_longer(! source:land_nr,
               names_to = "unit", values_to = "votes")

bw_l <- 
  bw_l %>% 
  separate(unit, c("unit", "votes_type", "votes_status"), sep = "__") %>% 
  mutate(across(c("wkr_nr", "land_nr", "votes"), as.integer))


## Votes ----

votes_valid <- 
  bw_l %>% 
  filter(unit == "Gültige", votes_status == "Endgültig", ! is.na(votes)) %>% 
  select(wkr_nr, level, votes_type, votes_valid = votes)

bw_out <- 
  bw_l %>% 
  filter(votes_status == "Endgültig", votes > 0, ! is.na(votes)) %>% 
  left_join(votes_valid) %>% 
  mutate(wkr_nr = if_else(level == "district", wkr_nr, NA_integer_),
         land_nr = if_else(level == "district", land_nr, NA_integer_)) %>% 
  select(-votes_status)

write_csv(bw_out, "6-btw-wahlkreise/source__data/btw-2017-results.csv")


## Party share ----

bw_party <- 
  bw_out %>% 
  left_join(party_raw %>% select(-party)) %>% 
  group_by(votes, short, votes_type) %>% 
  mutate(share = round(100 * votes / votes_valid, 2)) %>% 
  rename(party = short) %>% 
  filter(! is.na(party)) %>% 
  relocate(party:share, .before = votes) %>% 
  relocate(votes_type, .before = share) %>% 
  select(-unit)
  
write_csv(bw_party, "6-btw-wahlkreise/source__data/btw-2017-party.csv")


## Geo data districts ----

# sf issue with 1.0 update "Found 1 feature with invalid spherical geometry."
# use Docker image to run this block and store map data as rds

wk_shp_raw <- 
  st_read("6-btw-wahlkreise/source__data-btw17/btw17_geometrie_wahlkreise_geo_shp/",
          quiet = TRUE) %>% 
  janitor::clean_names()

sf::sf_use_s2(FALSE)
wk_shp <- 
  wk_shp_raw %>% 
  mutate(
    area = st_area(geometry),
    area_km2 = (sqrt(area) / 1000) %>% as.integer() %>% round(),
    coord_y = wk_shp_raw %>% st_centroid() %>% st_coordinates() %>% as_tibble() %>% pull(Y),
    land_nr = as.integer(land_nr)
  )

write_rds(wk_shp, "6-btw-wahlkreise/source__data/btw17-districts-geometry.rds")
wk_ctr <- st_centroid(wk_shp)
write_rds(wk_ctr, "6-btw-wahlkreise/source__data/btw17-districts-centroid.rds")

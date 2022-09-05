library(sf)         # for sf join
library(WDI)        # Worldbank data
library(tidyverse)


## V-Dem ----

vdem_raw <- read_rds("3-women-representation/source__data//vdem-electoral-system.rds")

vdem <- 
  vdem_raw %>% 
  mutate(democracy = if_else(v2x_polyarchy > 0.5, "yes", "no")) %>% 
  select(country, polyarchy = v2x_polyarchy, democracy, electoral_system) %>% 
  mutate(electoral_rule = case_when(
    str_detect(electoral_system, "First-past-post|Two-round|Block vote") ~ "Majoritarian",
    str_detect(electoral_system, "Parallel|Mixed-member PR") ~ "Mixed",
    str_detect(electoral_system, "List PR") ~ "Proportional",
    TRUE ~ "other"
  ))

## WDI ----

# WDIsearch("parliament")
wdi_raw <- WDI(indicator = "SG.GEN.PARL.ZS", start = 2010, end = 2021, extra = TRUE)

wdi <- 
  wdi_raw %>% 
  filter(! str_detect(iso2c, "\\d")) %>% 
  select(country = iso3c, parliament_share = SG.GEN.PARL.ZS) %>% 
  drop_na(parliament_share) %>% 
  group_by(country) %>% 
  summarise(parliament_share = round(mean(parliament_share, na.rm = TRUE)))


## WhoGov ----

whogov_raw <- read_csv("3-women-representation/source__data/whogov.zip")

whogov_1 <- 
  whogov_raw %>% 
  mutate(country = country_isocode,
         female = if_else(gender == "Female", 1, 0)) %>%
  drop_na(female) %>% 
  group_by(country, year) %>% 
  summarise(government_share = round(100 * sum(female) / n(), 1), .groups = "drop")

whogov_2 <- 
  whogov_1 %>% 
  filter(year >= 2010) %>% 
  group_by(country) %>% 
  summarise(government_share = round(mean(government_share, na.rm = TRUE)))


## Final data ----

women_1 <- 
  vdem %>% 
  full_join(wdi) %>% 
  full_join(whogov_2)

world <- read_rds("3-women-representation/source__data/worldmap.rds")

women_2 <- 
  world %>% 
  left_join(women_1)
  
write_rds(women_2, "3-women-representation/women-representation-data.rds")

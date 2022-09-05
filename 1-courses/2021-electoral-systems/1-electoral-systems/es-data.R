library(countrycode)
library(tidyverse)

## Dataset ----

es_raw <- read_csv("1-electoral-systems/source__es_data-v3/es_data-v3.csv")

es <- es_raw

# recode missing values
es[es == -88] <- NA
es[es == -99] <- NA
# skimr::skim(es, where(is.numeric)) %>% select(skim_variable, numeric.p0)


## Label factor ----

es_code <- read_csv("1-electoral-systems/es-labels.csv")

# label all variables except tier formula
for(var in unique(es_code$variable)) {
  if(var == "formula") {
    next
  }
  fac_label <- es_code %>% filter(variable == var)
  es[[var]] <- factor(es[[var]], fac_label$value, fac_label$label)
}

# label tier formula variables 
fac_label <- es_code %>% filter(variable == "formula")
for(index in 1:4) {
  var <- glue::glue("tier{index}_formula")
  es[[var]] <- factor(es[[var]], fac_label$value, fac_label$label)
}

## Variable clean-up ----

# add variable with short names

fac_label <- es_code %>% filter(variable == "elecrule")
es[["elecrule_short"]] <- factor(as.integer(es[["elecrule"]]), fac_label$value, fac_label$name)

fac_label <- es_code %>% filter(variable == "region3")
es[["region3_short"]] <- factor(as.integer(es[["region3"]]), fac_label$value, fac_label$name)

fac_label <- es_code %>% filter(variable == "formula")
es[["tier1_short"]] <- factor(as.integer(es[["tier1_formula"]]), fac_label$value, fac_label$name)

es1 <- 
  es %>% 
  mutate(
    country_source = country,
    country_name = countrycode(country_source, "country.name", "country.name",
                               custom_match = c("Serbia & Montenegro" = "Serbia",
                                                "Czechoslovakia" = "Czechia")),
    country = countrycode(country_name, "country.name", "iso3c"),
    date_source = date,
    date = lubridate::ymd(paste(year, month, day, sep = "-")),
    type_short = substr(legislative_type, 1, 3)
  )

## Add classification ----

classify <- 
  es_code %>% 
  filter(! is.na(classification)) %>% 
  select(classification, label_merge = label) %>% 
  distinct()

es2 <- 
  es1 %>% 
  mutate(label_merge = if_else(type_short == "Pro", 
                               as.character(tier1_formula),
                               as.character(elecrule))) %>% 
  left_join(classify) %>% 
  select(-label_merge)


## Data final ----

es_out <-
  es2 %>%
  relocate(country_name, .after = country) %>% 
  relocate(classification, type_short, .before = legislative_type) %>% 
  relocate(elecrule_short, .before = elecrule) %>% 
  relocate(tier1_short, .before = tier1_formula) %>% 
  arrange(country, year, date)

write_rds(es_out, "1-electoral-systems/source__es-data-v3.rds")

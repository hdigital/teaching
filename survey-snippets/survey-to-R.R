library(tidyverse)
library(haven)  # read Stata and SPSS files (tidyverse)


# option to recode negative values in labeled variables into missing values
negative_numbers_into_NA <- TRUE


## Read data ----

# prefer SPSS with labelled data -- previously problems with Stata encodings and missings
file_source <- "source__ZA5270/ZA5270_v2-0-0.sav.zip"
files_out <- "source__Allbus-2018"

svy_format <- case_when(
  str_detect(file_source, "dta") ~ "stata",
  str_detect(file_source, "sav") ~ "spss"
)

if(svy_format == "stata") {
  raw_svy <- read_dta(file_source)
  }
if(svy_format == "spss") {
  raw_svy <- read_sav(file_source)
}


## Variable information ----

svy_var <- 
  tibble(
    variable = names(raw_svy),
    tmp_1 = map(variable, ~ attributes(raw_svy[[.x]])[["label"]]),
    label = map_chr(tmp_1, ~ if_else(is.null(.x), "", .x)),
    tmp_2 = map(names(raw_svy), ~ attr(raw_svy[[.x]], svy_format)),
    format = map_chr(tmp_2, ~ if_else(is.null(.x), "", .x)),
    factor = map_int(variable, ~ attributes(raw_svy[[.x]])[["labels"]] %>% max() > 0 )
  ) %>% 
  select(-tmp_1, -tmp_2)


## Variable labels ----

get_svy_labels <- function(svy_var) {
  labels <- attr(pull(raw_svy, svy_var), "labels")
  
  if(! is.null(labels)) {
    tibble(variable = svy_var, label = names(labels), value = as.character(labels))
  } else {
    NULL
  }
}

svy_label <- map_df(names(raw_svy), get_svy_labels)


## R data formats ----

# get names of factor variables
to_factor <- 
  svy_var %>% 
  filter(factor == 1) %>% 
  pull(variable)

svy_dt <- raw_svy

# recode negative values into NA
if(negative_numbers_into_NA == TRUE) {
  svy_dt[svy_dt < 0] <- NA
}

# remove unused factor levels not used and variable labels
svy_dt <- 
  svy_dt %>% 
  mutate(across(any_of(to_factor), ~ as_factor(.x) %>% fct_drop())) %>%
  zap_labels()


## Write data ----

write_rds(svy_dt, paste0(files_out, ".rds"), compress = "gz")
write_csv(svy_var, paste0(files_out, "-variables.csv"), na = "")
write_csv(svy_label, paste0(files_out, "-labels.csv"), na = "")

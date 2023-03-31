# R style guide HD

[The tidyverse style guide](https://style.tidyverse.org/)

pipes — `|>` · 🌬️

+ one line for each step in a pipe
+ first line pipe with name of new object and assignment operator (only)
+ use Base-R pipe `|>` over Tidyverse-R pipe `%>%` for R >= 4.2
  + placeholder `_` (`|>`) instead of `.` (`%>%`)
  + check _Use native pipe operator_ in [RStudio](https://www.rstudio.com/blog/rstudio-v1-4-update-whats-new/)

packages · 📦 // see snippet below

+ load `library(tidyverse)` last
  + [ avoid name conflicts ]
+ brief description why package is loaded
  + `library(broom)  # models // tidy results`
+ order packages loaded by thematic groups
  + _plot_ — patchwork ggrepel
  + _models_ — broom · ggeffects
+ single usage of package with `::`
  + comment below loading packages block // `# janitor::`
  + no comment for usage tidyverse of packages that are not loaded with _library(tidyverse)_ (e.g. glue readxl)
  + [ reduce potential name conflicts and code completion options ]

data · 🔢

+ use coherent prefixes for groups of data // `dt dt_ctry dt_ctz`
+ prefix `raw_` for raw data read into object with

plots · 📊

+ prefix `pl` for plot objects // `pl pl1 pl2`
+ data for plot only into `pl_dt` object

models · 🔬

+ prefix `mo` for model objects // `mo mo_lm mo1`

workflow · ⚙️

+ .gitignore sources with `source__` prefix
  + [ single option to ignore copyright protected, personal or sensible sources ]
+ final checks
  + restart R session and run all
  + check all object names
  + check console messages and warnings
+ reproducible environments with [Rocker](https://rocker-project.org/use/reproducibility.html)
  + see [`Dockerfile`](Dockerfile) and [`docker-compose.yml`](docker-compose.yml) examples

---

## Snippets

Loading packages

```r
library(conflicted) # create errors for function name conflicts
conflicts_prefer(dplyr::filter, .quiet = TRUE)

library(tidyverse)

# order alphabetically in section and provide category with brief description
library(broom)      # models // tidy results
library(ggeffects)  # models // visualize model effects
library(patchwork)  # plots  // arrange plots
library(reactable)  # layout // interactive data tables
library(sf)         # maps   // spatial data tools

# DT:: skimr:: viridis::
```

---

_Note_ — These are my personal best practices for code formatting in Tidyverse R. They have evolved over time and not all my previous code may follow these guidelines.

# R style guide HD

[The tidyverse style guide](https://style.tidyverse.org/)

pipes — `%>%` · 🌬️

+ one line per each step in a pipe
+ first line pipe with name of new object and assignment operator

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

---

## Snippets

Loading packages

```r
library(lme4)       # models // multi-level 
library(broom)      # models // tidy results
library(broom.mixed)
library(ggeffects)  # models // visualize model effects
library(patchwork)  # plots // arrange
library(sf)         # maps
library(tidyverse)  # load last to avoid masking
# DT:: skimr:: viridis::
```

---

_Note_ — These are my personal best practices for code formatting in Tidyverse R. They have evolved over time and not all my previous code my follow these guidelines.

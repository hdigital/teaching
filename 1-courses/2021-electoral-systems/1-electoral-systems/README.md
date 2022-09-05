# Bormann/Golder electoral systems

Summary and visualization of electoral systems in Bormann and Golder (2013).

## Reference

Bormann, Nils-Christian, and Matt Golder. 2013. “Democratic Electoral Systems around the World, 1946–2011.” Electoral Studies 32(2): 360–69. — [doi:10.1016/j.electstud.2013.01.005](https://doi.org/10.1016/j.electstud.2013.01.005)

[Democratic Electoral Systems, 1946-2016 dataset (Version 3.0)](http://mattgolder.com/elections)

## Data clean-up

Conversion of data in [es-data.R](es-data.R) with additional information in [es-labels.csv](es-labels.csv).

+ convert numeric classification codes into factors with labels
+ add classification based on Figure 2
+ recode missing values into _NA_
+ add short name versions for some variables
+ harmonize country codes to ISO 3166-1 alpha-3

## Quiz

Anonymized and randomized version of parameters electoral systems.

Give only the quiz to students. Provide solution at the bottom by setting `eval = TRUE` in snippet.

In a longer version, you may provide table entries in chunks to increase the difficulty.

---

![](z-electoral-systems-map.png)
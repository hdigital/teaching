library(callr)
library(fs)
library(purrr)

# run all R/Rmd scripts in subfolders
r_scripts <- dir_ls(".", glob = "*/*R", recurse = 1) 
map(r_scripts, rscript, spinner = TRUE)

rmd_scripts <- dir_ls(".", glob = "*/*Rmd", recurse = 1)
map(rmd_scripts, rmarkdown::render)

# add session information
session_info <- paste(capture.output(sessionInfo()), collapse = "\n")
write_lines(session_info, file = "z-run-all_session-info.md", append = FALSE)

# remove Rplots created with print()
if(file_exists("Rplots.pdf")) {
  file_delete("Rplots.pdf")
}

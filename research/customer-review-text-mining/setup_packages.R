packages <- c("readr", "dplyr", "tidyr", "tidytext", "ggplot2", "topicmodels", "textdata")
missing <- setdiff(packages, rownames(installed.packages()))
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
} else {
  message("All required packages are installed.")
}

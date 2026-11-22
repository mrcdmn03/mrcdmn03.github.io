# Run once in R or RStudio to install required packages.
required_packages <- c("readxl", "dplyr", "ggplot2", "tidyr",
                       "stringr", "forecast", "tseries")
missing_packages <- setdiff(required_packages, rownames(installed.packages()))
if (length(missing_packages) > 0) {
  install.packages(missing_packages, repos = "https://cloud.r-project.org")
} else {
  message("All required packages are already installed.")
}
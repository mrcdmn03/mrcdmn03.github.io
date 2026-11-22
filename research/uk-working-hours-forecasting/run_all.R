# Run this file from the repository root, after installing dependencies.
required_packages <- c("readxl", "dplyr", "ggplot2", "tidyr",
                       "stringr", "forecast", "tseries")
missing_packages <- setdiff(required_packages, rownames(installed.packages()))
if (length(missing_packages) > 0) {
  stop("Install packages first: ",
       paste(missing_packages, collapse = ", "),
       "\nRun: source('setup_packages.R')")
}
dir.create("data_clean", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)

cat("Running data preparation...\n")
source("scripts/01_data_loading_cleaning.R", local = FALSE)
cat("Running time-series analysis (may take some time)...\n")
source("scripts/02_stationarity_analysis.R", local = FALSE)
cat("Analysis scripts completed. Review tables/ and figures/.\n")
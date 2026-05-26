# ============================================================
# 00_packages.R
# Load packages for the PDF/OCR/API reporting pipeline
# ============================================================

packages <- c(
  "tidyverse",
  "stringr",
  "lubridate",
  "openxlsx",
  "jsonlite"
)

new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]

if (length(new_packages) > 0) {
  install.packages(new_packages)
}

lapply(packages, library, character.only = TRUE)

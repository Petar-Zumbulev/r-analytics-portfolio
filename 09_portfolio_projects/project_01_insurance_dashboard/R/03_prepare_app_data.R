# ============================================================
# 03_prepare_app_data.R
# Prepare clean data for the Shiny insurance dashboard
# ============================================================

project_dir <- file.path(
  "09_portfolio_projects",
  "project_01_insurance_dashboard"
)

# This makes the script work even if you run it from inside the project folder
if (!dir.exists(project_dir)) {
  project_dir <- "."
}

source(file.path(project_dir, "R", "00_packages.R"))

clean_file <- file.path(project_dir, "data_processed", "clean_claims_data.rds")
output_file <- file.path(project_dir, "data_processed", "app_data.rds")

dir.create(file.path(project_dir, "data_processed"), showWarnings = FALSE, recursive = TRUE)

# ------------------------------------------------------------
# Step 1: Create clean_claims_data.rds if it does not exist yet
# ------------------------------------------------------------

if (!file.exists(clean_file)) {
  
  source(file.path(project_dir, "R", "01_generate_sample_data.R"))
  source(file.path(project_dir, "R", "02_clean_data.R"))
  
  if (!exists("generate_sample_insurance_data")) {
    stop("Could not find function generate_sample_insurance_data(). Check 01_generate_sample_data.R.")
  }
  
  if (!exists("clean_insurance_data")) {
    stop("Could not find function clean_insurance_data(). Check 02_clean_data.R.")
  }
  
  raw_data <- generate_sample_insurance_data()
  claims_clean <- clean_insurance_data(raw_data)
  
  saveRDS(claims_clean, clean_file)
  
  cat("Created clean data file:", clean_file, "\n")
  
} else {
  
  claims_clean <- readRDS(clean_file)
  
  cat("Loaded existing clean data file:", clean_file, "\n")
}

# ------------------------------------------------------------
# Step 2: Standardize column names for the Shiny dashboard
# ------------------------------------------------------------

if ("line" %in% names(claims_clean) && !"business_line" %in% names(claims_clean)) {
  claims_clean <- claims_clean %>% 
    rename(business_line = line)
}

if ("report_date" %in% names(claims_clean) && !"claim_date" %in% names(claims_clean)) {
  claims_clean <- claims_clean %>% 
    rename(claim_date = report_date)
}

if ("accident_date" %in% names(claims_clean) && !"claim_date" %in% names(claims_clean)) {
  claims_clean <- claims_clean %>% 
    rename(claim_date = accident_date)
}

if ("claim_cost" %in% names(claims_clean) && !"claim_amount" %in% names(claims_clean)) {
  claims_clean <- claims_clean %>% 
    rename(claim_amount = claim_cost)
}

if (!"claim_count" %in% names(claims_clean)) {
  claims_clean <- claims_clean %>%
    mutate(claim_count = 1)
}

# ------------------------------------------------------------
# Step 3: Check required dashboard columns
# ------------------------------------------------------------

required_cols <- c(
  "claim_date",
  "business_line",
  "region",
  "claim_count",
  "claim_amount",
  "premium"
)

missing_cols <- setdiff(required_cols, names(claims_clean))

if (length(missing_cols) > 0) {
  stop(
    paste(
      "Missing required columns:",
      paste(missing_cols, collapse = ", ")
    )
  )
}

# ------------------------------------------------------------
# Step 4: Create dashboard-ready app data
# ------------------------------------------------------------

app_data <- claims_clean %>%
  mutate(
    claim_date = as.Date(claim_date),
    quarter_date = lubridate::floor_date(claim_date, unit = "quarter"),
    quarter = paste0(
      lubridate::year(claim_date),
      " Q",
      lubridate::quarter(claim_date)
    ),
    business_line = as.character(business_line),
    region = as.character(region),
    claim_count = as.numeric(claim_count),
    claim_amount = as.numeric(claim_amount),
    premium = as.numeric(premium)
  ) %>%
  filter(
    !is.na(claim_date),
    !is.na(business_line),
    !is.na(region),
    !is.na(claim_count),
    !is.na(claim_amount),
    !is.na(premium)
  ) %>%
  arrange(claim_date)

saveRDS(app_data, output_file)

cat("Dashboard data saved to:", output_file, "\n")
cat("Rows:", nrow(app_data), "\n")
cat("Columns:", ncol(app_data), "\n")
# ============================================================
# 03_parse_report.R
# Parse semi-structured report text into structured tables
# ============================================================


# parsing means organizing into dataframes
# Parsing means taking text and extracting meaningful pieces from it into a structured format
extract_single_value <- function(text, pattern, default = NA_character_) {
  
  value <- str_match(text, pattern)[, 2]
  
  if (is.na(value)) {
    return(default)
  }
  
  str_trim(value)
}

parse_report_metadata <- function(clean_text) {
  
  # tibble() makes a dataframe in R
  tibble(
    report_id = extract_single_value(clean_text, "Report ID:\\s*([^\\n]+)"),
    report_date = ymd(extract_single_value(clean_text, "Report Date:\\s*([^\\n]+)")),
    portfolio = extract_single_value(clean_text, "Portfolio:\\s*([^\\n]+)"),
    quarter = extract_single_value(clean_text, "Quarter:\\s*([^\\n]+)"),
    currency = extract_single_value(clean_text, "Currency:\\s*([^\\n]+)"),
    medical_inflation_pct = as.numeric(extract_single_value(clean_text, "Medical inflation assumption:\\s*([0-9.]+)%")),
    recommended_premium_adjustment_pct = as.numeric(extract_single_value(clean_text, "Recommended premium adjustment:\\s*([0-9.]+)%"))
  )
}

parse_claim_lines <- function(clean_text) {
  
  claim_lines <- str_split(clean_text, "\n")[[1]] |>
    str_subset("^Claim ID:")
  
  if (length(claim_lines) == 0) {
    stop("No claim lines found.")
  }
  
  claim_pattern <- paste0(
    "Claim ID:\\s*([^|]+)\\s*\\|\\s*",
    "Policy ID:\\s*([^|]+)\\s*\\|\\s*",
    "Claim Date:\\s*([^|]+)\\s*\\|\\s*",
    "Region:\\s*([^|]+)\\s*\\|\\s*",
    "Business Line:\\s*([^|]+)\\s*\\|\\s*",
    "Claim Amount:\\s*EUR\\s*([0-9.,]+)\\s*\\|\\s*",
    "Status:\\s*([^|]+)"
  )
  
  parsed <- str_match(claim_lines, claim_pattern)
  
  claims_tbl <- tibble(
    claim_id = str_trim(parsed[, 2]),
    policy_id = str_trim(parsed[, 3]),
    claim_date = ymd(str_trim(parsed[, 4])),
    region = str_trim(parsed[, 5]),
    business_line = str_trim(parsed[, 6]),
    claim_amount = as.numeric(str_replace_all(str_trim(parsed[, 7]), ",", "")),
    status = str_trim(parsed[, 8])
  ) |>
    mutate(
      claim_month = floor_date(claim_date, "month"),
      claim_quarter = paste0(year(claim_date), " Q", quarter(claim_date))
    )
  
  claims_tbl
}

simulate_api_enrichment <- function(claims_tbl) {
  
  enriched_tbl <- claims_tbl |>
    mutate(
      severity_band = case_when(
        claim_amount >= 10000 ~ "High",
        claim_amount >= 3000 ~ "Medium",
        TRUE ~ "Low"
      ),
      review_priority = case_when(
        status == "Review" ~ "Manual review required",
        claim_amount >= 10000 ~ "Check large claim",
        status == "Open" ~ "Monitor open claim",
        TRUE ~ "Standard"
      )
    )
  
  api_json <- jsonlite::toJSON(
    enriched_tbl,
    dataframe = "rows",
    auto_unbox = TRUE,
    pretty = TRUE
  )
  
  api_json
}

parse_api_response <- function(api_json) {
  
  jsonlite::fromJSON(api_json) |>
    as_tibble()
}

create_claim_summary <- function(claims_tbl, metadata_tbl) {
  
  claims_tbl |>
    group_by(business_line, region, severity_band) |>
    summarise(
      claim_count = n(),
      total_claim_amount = sum(claim_amount, na.rm = TRUE),
      avg_severity = mean(claim_amount, na.rm = TRUE),
      open_claims = sum(status == "Open", na.rm = TRUE),
      review_claims = sum(status == "Review", na.rm = TRUE),
      .groups = "drop"
    ) |>
    mutate(
      medical_inflation_pct = metadata_tbl$medical_inflation_pct[1],
      recommended_premium_adjustment_pct = metadata_tbl$recommended_premium_adjustment_pct[1],
      inflation_adjusted_total = total_claim_amount * (1 + medical_inflation_pct / 100)
    ) |>
    arrange(desc(total_claim_amount))
}
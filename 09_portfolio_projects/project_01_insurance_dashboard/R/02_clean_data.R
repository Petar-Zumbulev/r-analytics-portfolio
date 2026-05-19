# ============================================================
# 02_clean_data.R
# Clean insurance data
# ============================================================

clean_insurance_data <- function(raw_data) {
  
  clean_data <- raw_data %>%
    mutate(
      report_date = as.Date(report_date),
      report_month = lubridate::floor_date(report_date, unit = "month"),
      report_quarter = paste0(
        lubridate::year(report_date),
        " Q",
        lubridate::quarter(report_date)
      ),
      report_year = lubridate::year(report_date),
      line = as.character(line),
      region = as.character(region),
      claim_count = as.numeric(claim_count),
      claim_amount = as.numeric(claim_amount),
      premium = as.numeric(premium)
    ) %>%
    filter( # filter() keeps only ROWS where ALL conditions are true
      !is.na(report_date), # removes rows with missing or impossible values
      !is.na(line), # the ! means NOT, and the whole line is rows where 'line' is not missing
                    # and since its in the filter() function, it means keep rows where line is not missing
      !is.na(region),
      claim_count >= 0,
      claim_amount >= 0,
      premium > 0
    ) # these ^^ are all a set of conditions for the filter() function
  
  return(clean_data)
}
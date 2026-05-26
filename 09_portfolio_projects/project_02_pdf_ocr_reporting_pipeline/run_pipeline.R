# ============================================================
# run_pipeline.R
# PDF/OCR/API-style structured reporting pipeline
# ============================================================

project_dir <- file.path(
  "09_portfolio_projects",
  "project_02_pdf_ocr_reporting_pipeline"
)

source(file.path(project_dir, "R", "00_packages.R"))
source(file.path(project_dir, "R", "01_create_sample_report.R"))
source(file.path(project_dir, "R", "02_extract_text.R"))
source(file.path(project_dir, "R", "03_parse_report.R"))
source(file.path(project_dir, "R", "04_export_outputs.R"))

# ------------------------------------------------------------
# 1. Create sample semi-structured report
# ------------------------------------------------------------

raw_report_path <- file.path(project_dir, "data", "raw", "sample_claim_report.txt")

create_sample_report(raw_report_path)

# ------------------------------------------------------------
# 2. Extract and clean text
# ------------------------------------------------------------

raw_text <- extract_report_text(raw_report_path)

clean_text <- clean_report_text(raw_text)

clean_text_path <- file.path(project_dir, "data", "processed", "clean_report_text.txt")

save_clean_text(clean_text, clean_text_path)

# ------------------------------------------------------------
# 3. Parse metadata and claim records
# ------------------------------------------------------------

metadata_tbl <- parse_report_metadata(clean_text)

claims_tbl <- parse_claim_lines(clean_text)

# ------------------------------------------------------------
# 4. Simulate API-style enrichment step
# ------------------------------------------------------------

api_json <- simulate_api_enrichment(claims_tbl)

claims_enriched_tbl <- parse_api_response(api_json)

# ------------------------------------------------------------
# 5. Create reporting summary
# ------------------------------------------------------------

summary_tbl <- create_claim_summary(
  claims_tbl = claims_enriched_tbl,
  metadata_tbl = metadata_tbl
)

# ------------------------------------------------------------
# 6. Export outputs
# ------------------------------------------------------------

export_pipeline_outputs(
  metadata_tbl = metadata_tbl,
  claims_tbl = claims_enriched_tbl,
  summary_tbl = summary_tbl,
  output_dir = file.path(project_dir, "outputs")
)

# ------------------------------------------------------------
# 7. Print quick preview
# ------------------------------------------------------------

message("Pipeline completed successfully.")

print(metadata_tbl)
print(claims_enriched_tbl)
print(summary_tbl)


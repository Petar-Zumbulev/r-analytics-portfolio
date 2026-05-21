# ============================================================
# 04_export_outputs.R
# Export structured reporting outputs
# ============================================================

export_pipeline_outputs <- function(metadata_tbl, claims_tbl, summary_tbl, output_dir) {
  
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  
  excel_path <- file.path(output_dir, "structured_claim_report.xlsx")
  claims_csv_path <- file.path(output_dir, "claims_structured.csv")
  summary_csv_path <- file.path(output_dir, "claim_summary.csv")
  
  workbook <- createWorkbook()
  
  addWorksheet(workbook, "metadata")
  addWorksheet(workbook, "claims_structured")
  addWorksheet(workbook, "summary")
  
  writeDataTable(workbook, "metadata", metadata_tbl)
  writeDataTable(workbook, "claims_structured", claims_tbl)
  writeDataTable(workbook, "summary", summary_tbl)
  
  setColWidths(workbook, "metadata", cols = 1:ncol(metadata_tbl), widths = "auto")
  setColWidths(workbook, "claims_structured", cols = 1:ncol(claims_tbl), widths = "auto")
  setColWidths(workbook, "summary", cols = 1:ncol(summary_tbl), widths = "auto")
  
  freezePane(workbook, "claims_structured", firstRow = TRUE)
  freezePane(workbook, "summary", firstRow = TRUE)
  
  saveWorkbook(workbook, excel_path, overwrite = TRUE)
  
  write_csv(claims_tbl, claims_csv_path)
  write_csv(summary_tbl, summary_csv_path)
  
  message("Excel report exported: ", excel_path)
  message("Claims CSV exported: ", claims_csv_path)
  message("Summary CSV exported: ", summary_csv_path)
  
  invisible(
    list(
      excel_path = excel_path,
      claims_csv_path = claims_csv_path,
      summary_csv_path = summary_csv_path
    )
  )
}
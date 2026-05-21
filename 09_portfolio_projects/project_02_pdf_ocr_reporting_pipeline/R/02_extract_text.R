# ============================================================
# 02_extract_text.R
# Extract and clean text from a text or PDF report
# ============================================================

extract_report_text <- function(file_path) {
  
  if (!file.exists(file_path)) {
    stop("File does not exist: ", file_path)
  }
  
  file_extension <- tools::file_ext(file_path)
  
  if (file_extension == "txt") {
    
    raw_text <- readLines(file_path, warn = FALSE) |>
      paste(collapse = "\n")
    
  } else if (file_extension == "pdf") {
    
    if (!requireNamespace("pdftools", quietly = TRUE)) {
      stop("Package 'pdftools' is needed to extract text from PDFs. Install it with install.packages('pdftools').")
    }
    
    raw_text <- pdftools::pdf_text(file_path) |>
      paste(collapse = "\n")
    
  } else {
    
    stop("Unsupported file type. Use .txt or .pdf.")
  }
  
  raw_text
}

clean_report_text <- function(raw_text) {
  
  clean_text <- raw_text |>
    str_replace_all("\r", "\n") |>
    str_replace_all("\u00A0", " ") |>
    str_replace_all("[ ]+", " ") |>
    str_replace_all("\n+", "\n") |>
    str_trim()
  
  clean_text
}

save_clean_text <- function(clean_text, output_path) {
  
  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  
  writeLines(clean_text, output_path)
  
  message("Clean text saved: ", output_path)
  
  invisible(output_path)
}
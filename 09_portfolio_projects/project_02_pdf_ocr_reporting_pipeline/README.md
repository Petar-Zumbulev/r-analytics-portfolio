# PDF/OCR/API to Structured Insurance Report Workflow

## Overview

This project demonstrates a practical R workflow for transforming semi-structured or unstructured insurance document data into structured reporting outputs.

The workflow simulates how an analyst could extract claim information from text/PDF-style documents, clean the extracted content, convert it into structured tables, and export the results for reporting.

This project is inspired by real insurance analytics workflows where important information is often stored in PDFs, reports, spreadsheets, or other semi-structured formats.

## Main Features

- Document-style input processing
- Text extraction and parsing logic
- Cleaning unstructured claim information
- Converting extracted values into structured data frames
- Creating claim-level tables
- Creating summary reporting tables
- Exporting results to CSV and Excel
- Modular R script structure

## Example Outputs

The pipeline creates outputs such as:

- structured claim table
- claim summary table
- Excel workbook with multiple sheets
- CSV files for downstream reporting

Example output files:

```text
outputs/
  structured_claim_report.xlsx
  claims_structured.csv
  claim_summary.csv
  

project_02_pdf_ocr_pipeline/
  README.md
  R/
    00_packages.R
    01_create_sample_documents.R
    02_extract_text.R
    03_parse_claims.R
    04_export_outputs.R
  data/
  outputs/

  
  






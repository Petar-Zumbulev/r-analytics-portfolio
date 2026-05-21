# Day 16 — PDF/OCR/API Mini Workflow for Structured Reporting

## Goal

Today I built the second supporting portfolio project.

The goal was to show how R can take messy or semi-structured information and turn it into a clean reporting table.

## Workflow

The project follows this logic:

1. Start with a semi-structured insurance-style report
2. Extract the text
3. Clean the text
4. Parse important values using stringr and regular expressions
5. Convert the extracted values into data frames
6. Simulate an API-style enrichment step
7. Export clean outputs to Excel and CSV

## Why this matters

The Gen Re role seems to involve practical R work, reporting, Excel integration, Shiny apps, Git, and some PDF/OCR/API workflows.

This project is useful because it shows that I can:

- work with messy text
- extract useful values
- use regex/string cleaning
- create structured data frames
- export clean reporting outputs
- understand the basic idea of an API-style workflow

## Main skills

- stringr
- regex
- data frame parsing
- openxlsx
- jsonlite
- reporting pipeline structure

## Key lesson

Unstructured data is not immediately useful for reporting.

The value comes from turning it into a clean table with clear columns, types, and business meaning.



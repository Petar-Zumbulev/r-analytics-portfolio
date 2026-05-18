# Day 14 Notes — Project 1 Planning

## Main topic

Today I started planning Project 1: an Insurance Reporting Dashboard in R/Shiny.

The goal is not to build the full dashboard yet.

The goal is to create a clean project skeleton so that the dashboard can be built in an organized way.

## Project idea

The project is an interactive Shiny dashboard for insurance reporting.

It will use claims and premium data to calculate KPIs such as:

- claim count
- claim amount
- premium
- severity
- loss ratio

## Why this project is relevant

This project is relevant for a Gen Re-style analyst/coder role because it combines:

- R programming
- tidyverse data cleaning
- Shiny dashboard development
- insurance reporting
- Excel-style business KPIs
- clean project structure

## Data flow

The planned data flow is:

```text
raw data
→ clean data
→ calculate metrics
→ create plots
→ show results in Shiny
→ export reports


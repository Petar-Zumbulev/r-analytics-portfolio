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





Important concept for today: data flow

This is the main thing to understand.

01_generate_sample_data.R
        ↓
02_clean_data.R
        ↓
03_calculate_metrics.R
        ↓
04_create_plots.R
        ↓
app.R







Separating scripts keeps the project clean.

Instead of putting everything into one huge app.R file, each script has one job.

For example:

one script loads packages
one script creates data
one script cleans data
one script calculates KPIs
one script creates plots
one script exports outputs

This makes the project easier to debug, explain, and extend.


^^ This is how I should work in teams in the future

this creates a clean data pipeline


Why do we separate app.R from the scripts in the R/ folder?

So that app.R stays clean. The R scripts handle data generation, 
cleaning, metric calculation, plotting, and exports. This makes the project 
easier to debug and explain






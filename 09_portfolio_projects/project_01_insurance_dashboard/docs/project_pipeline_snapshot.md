# End-to-End Reporting Workflow

A practical path from raw business data to business-ready reporting output.

``` text
Raw data
   ↓
Cleaning and validation
   ↓
KPI calculation
   ↓
Plots and Shiny dashboard
   ↓
Excel / reporting output
```

## Project structure

``` text
project_01_insurance_dashboard/

data_raw/
data_processed/

R/
├── 00_packages.R
├── 01_generate_sample_data.R
├── 02_clean_data.R
├── 03_calculate_metrics.R
├── 04_create_plots.R
└── 05_export_outputs.R

outputs/
├── excel/
└── figures/

docs/
├── data_dictionary.md
└── project_plan.md

app.R
README.md
```

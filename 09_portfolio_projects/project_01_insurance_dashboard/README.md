# Insurance Reporting Dashboard in R/Shiny

## Project overview

This project simulates a practical insurance analytics workflow in R.

The goal is to build an interactive Shiny dashboard that takes claims and premium data, cleans it, calculates important insurance KPIs, visualizes business trends, and exports reporting outputs.

This project is designed as a portfolio project for an R-based analyst/coder role in insurance or reinsurance.

## Main business problem

Insurance analysts often need to understand how claim costs, premium, severity, and loss ratio develop over time.

This dashboard helps answer questions such as:

- How many claims were reported?
- How much premium was earned?
- What is the average claim severity?
- Which business line or region has the highest loss ratio?
- How are claims and premium changing over time?
- Which segments should be monitored more closely?

## Planned features

The dashboard will include:

- synthetic insurance-style claims and premium data
- data cleaning workflow in R
- quarterly reporting logic
- KPI cards
- line and region filters
- severity trend chart
- loss ratio trend chart
- summary table
- Excel export

## Main KPIs

The main KPIs are:

- claim count
- total claim amount
- total premium
- average severity
- loss ratio
- quarterly trend

## Tools used

- R
- tidyverse
- dplyr
- lubridate
- ggplot2
- Shiny
- DT
- openxlsx

## Project structure

```text
project_1_insurance_dashboard/
│
├── app.R
├── README.md
│
├── R/
│   ├── 00_packages.R
│   ├── 01_generate_sample_data.R
│   ├── 02_clean_data.R
│   ├── 03_calculate_metrics.R
│   ├── 04_create_plots.R
│   └── 05_export_outputs.R
│
├── data_processed/
├── outputs/
│   ├── figures/
│   └── excel/
└── docs/
    ├── project_plan.md
    └── data_dictionary.md


Why this project is relevant

This project is relevant for insurance analytics because it combines:

data cleaning
reporting
business KPIs
Shiny dashboard development
Excel export
insurance interpretation

It reflects practical analyst work rather than purely theoretical actuarial modeling.



## R Packages Used

- shiny
- tidyverse
- dplyr
- ggplot2
- lubridate
- DT
- scales
- openxlsx

## How to Run the App

Open the project in RStudio and run:

```r
shiny::runApp("09_portfolio_projects/project_01_insurance_dashboard")
```

Alternatively, open `app.R` and click **Run App** in RStudio.

## Workflow

The app follows this workflow:

```text
Generate sample insurance data
        ↓
Clean and prepare data
        ↓
Calculate insurance KPIs
        ↓
Prepare app-ready dataset
        ↓
Display dashboard in Shiny
        ↓
Export structured report outputs
```

## What This Project Demonstrates

This project demonstrates practical skills in:

- R programming
- tidyverse data wrangling
- Shiny dashboard development
- insurance KPI calculation
- Excel reporting
- modular project organization
- business-oriented data visualization
- GitHub-ready documentation

## Interview Talking Point

This dashboard was built to simulate the type of practical reporting work an 
insurance analyst might do: turning claims and premium data into clean, 
interactive, and exportable business insights.
# Day 15 Notes — Core Insurance Dashboard Build

## Main goal

Today I built the first working version of the insurance reporting dashboard in R/Shiny.

## Core workflow

Clean data is prepared outside the app and saved as:

data_processed/app_data.rds



The Shiny app reads this file and uses it for all dashboard outputs.


## Main Shiny structure


ui = what the user sees  
server = the logic / calculations / reactivity

## Important reactive objects

filtered_data()
- updates whenever the user changes filters

kpi_data()
- calculates claim count, total claims, total premium, average severity, and loss ratio

trend_data()
- calculates quarterly trends

detail_data()
- creates the grouped reporting table



## Important insurance metrics

claim_count = number of claims

total_claim_amount = total cost of claims

total_premium = premium collected

average severity = total claim amount / number of claims

loss ratio = total claim amount / premium



## What I should remember

The dashboard should not do all cleaning inside app.R.

Good structure:

raw data
→ clean data script
→ app_data.rds
→ Shiny app
→ filters / KPIs / plots / table / Excel export

This is close to a real analyst workflow because the app separates data preparation from reporting and display.










# making sure the app is self contained

source(file.path(project_dir, "R", "00_packages.R"))

# The app should use the prepared .rds file.
# If app_data.rds does not exist yet, create it automatically.






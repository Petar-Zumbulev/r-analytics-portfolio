# ============================================================
# app.R
# Insurance Performance Dashboard
#
# app.R Logic:
#
# - load packages
# - check app_data.rds
# - if missing, run 03_prepare_app_data.R
# - read app_data.rds
# - dashboard
#
# The app has 3 layers:
#
# 1. data layer
# 2. reactive filter layer
# 3. output layer
#
# ============================================================

# ------------------------------------------------------------
# Project path
# ------------------------------------------------------------

project_dir <- file.path(
  "09_portfolio_projects",
  "project_01_insurance_dashboard"
)

# If app.R is run from inside project_01_insurance_dashboard,
# use the current folder instead.
if (!dir.exists(project_dir)) {
  project_dir <- "."
}

# ------------------------------------------------------------
# Source project files
# ------------------------------------------------------------

# making sure the app is self contained
source(file.path(project_dir, "R", "00_packages.R"))

# The app should use the prepared .rds file.
# If app_data.rds does not exist yet, create it automatically.
app_data_file <- file.path(project_dir, "data_processed", "app_data.rds")

if (!file.exists(app_data_file)) {
  source(file.path(project_dir, "R", "03_prepare_app_data.R"))
}

app_data <- readRDS(app_data_file)

# ------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------

safe_divide <- function(x, y) {
  ifelse(y == 0 | is.na(y), NA_real_, x / y)
}

choices_with_all <- function(x) {
  c("All", sort(unique(x)))
}

fmt_euro <- function(x) {
  ifelse(
    is.na(x),
    "n/a",
    scales::dollar(
      x,
      prefix = "€",
      accuracy = 1,
      big.mark = ","
    )
  )
}

fmt_number <- function(x) {
  ifelse(
    is.na(x),
    "n/a",
    scales::comma(x, accuracy = 1)
  )
}

fmt_percent <- function(x) {
  ifelse(
    is.na(x),
    "n/a",
    scales::percent(x, accuracy = 0.1)
  )
}

dashboard_theme <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(color = "#6b7280", size = 11),
      axis.title = element_text(color = "#374151"),
      axis.text = element_text(color = "#6b7280"),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position = "bottom",
      legend.title = element_blank()
    )
}

metric_card <- function(icon, label, value, helper_text, accent_class = "accent-blue") {
  div(
    class = paste("kpi-card", accent_class),
    div(class = "kpi-icon", icon),
    div(class = "kpi-label", label),
    div(class = "kpi-value", value),
    div(class = "kpi-helper", helper_text)
  )
}

# ------------------------------------------------------------
# UI
# ------------------------------------------------------------

ui <- fluidPage(
  
  tags$head(
    tags$style(HTML("
      body {
        background: #f3f6fb;
        color: #111827;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
      }

      .container-fluid {
        padding-left: 28px;
        padding-right: 28px;
      }

      .dashboard-page {
        max-width: 1450px;
        margin: 0 auto;
        padding-top: 26px;
        padding-bottom: 36px;
      }

      .hero {
        background: linear-gradient(135deg, #0f172a 0%, #1d4ed8 58%, #2563eb 100%);
        color: white;
        border-radius: 26px;
        padding: 34px 42px;
        margin-bottom: 28px;
        box-shadow: 0 18px 45px rgba(15, 23, 42, 0.18);
      }

      .hero-title {
        font-size: 38px;
        font-weight: 800;
        letter-spacing: -0.6px;
        margin-bottom: 10px;
      }

      .hero-subtitle {
        max-width: 900px;
        color: rgba(255, 255, 255, 0.84);
        font-size: 18px;
        line-height: 1.55;
        margin-bottom: 22px;
      }

      .tag-row {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
      }

      .tag-pill {
        background: rgba(255, 255, 255, 0.16);
        border: 1px solid rgba(255, 255, 255, 0.22);
        color: white;
        padding: 8px 16px;
        border-radius: 999px;
        font-weight: 700;
        font-size: 13px;
        letter-spacing: 0.3px;
      }

      .dashboard-layout {
        display: grid;
        grid-template-columns: 280px minmax(0, 1fr);
        gap: 26px;
        align-items: start;
      }

      .filter-panel {
        background: white;
        border-radius: 22px;
        padding: 24px;
        box-shadow: 0 16px 35px rgba(15, 23, 42, 0.08);
        border: 1px solid #e5e7eb;
        position: sticky;
        top: 18px;
      }

      .filter-title {
        font-size: 19px;
        font-weight: 800;
        margin-bottom: 20px;
      }

      .control-label {
        font-weight: 700;
        color: #374151;
        margin-bottom: 7px;
      }

      .selectize-input {
        border-radius: 12px !important;
        border: 1px solid #d1d5db !important;
        padding: 10px 12px !important;
        box-shadow: none !important;
        min-height: 43px;
      }

      .selectize-input.focus {
        border-color: #2563eb !important;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12) !important;
      }

      #reset_filters {
        width: 100%;
        border-radius: 12px;
        background: #f3f4f6;
        border: 1px solid #d1d5db;
        color: #374151;
        font-weight: 700;
        padding: 10px 12px;
        margin-top: 6px;
      }

      #reset_filters:hover {
        background: #e5e7eb;
      }

      #download_excel {
        width: 100%;
        border-radius: 12px;
        background: #2563eb;
        border: 1px solid #2563eb;
        color: white;
        font-weight: 800;
        padding: 11px 12px;
        margin-top: 12px;
      }

      #download_excel:hover {
        background: #1d4ed8;
        border-color: #1d4ed8;
        color: white;
      }

      .current-view {
        background: #eef5ff;
        border: 1px solid #cfe0ff;
        color: #1e3a8a;
        border-radius: 16px;
        padding: 16px;
        margin-top: 18px;
        font-size: 14px;
        line-height: 1.55;
      }

      .current-view-title {
        font-weight: 800;
        margin-bottom: 6px;
      }

      .main-content {
        min-width: 0;
      }

      .kpi-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(215px, 1fr));
        gap: 20px;
        margin-bottom: 24px;
      }

      .kpi-card {
        background: white;
        border-radius: 20px;
        padding: 24px 24px 22px 24px;
        min-height: 188px;
        border: 1px solid #e5e7eb;
        box-shadow: 0 14px 32px rgba(15, 23, 42, 0.075);
        overflow: visible;
        position: relative;
      }

      .kpi-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 18px;
        right: 18px;
        height: 4px;
        border-radius: 999px;
      }

      .accent-blue::before {
        background: #2563eb;
      }

      .accent-teal::before {
        background: #14b8a6;
      }

      .accent-green::before {
        background: #22c55e;
      }

      .accent-amber::before {
        background: #f59e0b;
      }

      .accent-red::before {
        background: #ef4444;
      }

      .kpi-icon {
        font-size: 27px;
        margin-bottom: 14px;
      }

      .kpi-label {
        font-size: 13px;
        color: #6b7280;
        font-weight: 900;
        letter-spacing: 1.2px;
        text-transform: uppercase;
        margin-bottom: 10px;
        min-height: 32px;
      }

      .kpi-value {
        font-size: clamp(26px, 2.7vw, 36px);
        font-weight: 900;
        color: #111827;
        letter-spacing: -0.9px;
        line-height: 1.05;
        white-space: normal;
        overflow-wrap: anywhere;
        margin-bottom: 12px;
      }

      .kpi-helper {
        color: #6b7280;
        font-size: 14px;
        line-height: 1.45;
      }

      .insight-card {
        background: white;
        border-radius: 22px;
        padding: 26px 30px;
        margin-bottom: 26px;
        border: 1px solid #e5e7eb;
        box-shadow: 0 14px 32px rgba(15, 23, 42, 0.075);
      }

      .insight-title {
        font-size: 22px;
        font-weight: 900;
        margin-bottom: 14px;
      }

      .insight-box {
        background: #f8fafc;
        border-left: 5px solid #2563eb;
        border-radius: 14px;
        padding: 18px 22px;
        color: #374151;
        line-height: 1.6;
      }

      .insight-box ul {
        margin-bottom: 0;
        padding-left: 20px;
      }

      .tab-card {
        background: white;
        border-radius: 22px;
        padding: 24px 28px 30px 28px;
        border: 1px solid #e5e7eb;
        box-shadow: 0 14px 32px rgba(15, 23, 42, 0.075);
      }

      .nav-tabs {
        border-bottom: 1px solid #e5e7eb;
        margin-bottom: 18px;
      }

      .nav-tabs > li > a {
        border-radius: 12px 12px 0 0;
        color: #374151;
        font-weight: 800;
        padding: 12px 18px;
      }

      .nav-tabs > li.active > a,
      .nav-tabs > li.active > a:focus,
      .nav-tabs > li.active > a:hover {
        color: #1d4ed8;
        border-color: #e5e7eb #e5e7eb transparent;
        background: #ffffff;
      }

      .plot-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(380px, 1fr));
        gap: 24px;
      }

      .plot-card {
        background: #ffffff;
        border: 1px solid #edf0f5;
        border-radius: 18px;
        padding: 18px 20px 10px 20px;
      }

      .plot-card-title {
        font-weight: 900;
        font-size: 18px;
        margin-bottom: 2px;
      }

      .plot-card-subtitle {
        color: #6b7280;
        font-size: 13px;
        margin-bottom: 10px;
      }

      .dataTables_wrapper {
        font-size: 14px;
      }

      table.dataTable {
        border-collapse: collapse !important;
      }

      table.dataTable thead th {
        background: #f8fafc;
        color: #374151;
        font-weight: 800;
        border-bottom: 1px solid #e5e7eb !important;
      }

      @media (max-width: 980px) {
        .dashboard-layout {
          grid-template-columns: 1fr;
        }

        .filter-panel {
          position: static;
        }

        .hero-title {
          font-size: 30px;
        }
      }
    "))
  ),
  
  div(
    class = "dashboard-page",
    
    div(
      class = "hero",
      div(class = "hero-title", "Insurance Performance Dashboard"),
      div(
        class = "hero-subtitle",
        "Interactive R/Shiny dashboard for insurance-style reporting: claims cost, premium, severity, loss ratio, quarterly trends, business insights, and Excel export."
      ),
      div(
        class = "tag-row",
        span(class = "tag-pill", "R / Shiny"),
        span(class = "tag-pill", "tidyverse"),
        span(class = "tag-pill", "ggplot2"),
        span(class = "tag-pill", "Excel Reporting"),
        span(class = "tag-pill", "Insurance KPIs")
      )
    ),
    
    div(
      class = "dashboard-layout",
      
      div(
        class = "filter-panel",
        div(class = "filter-title", "Dashboard Filters"),
        
        selectInput(
          inputId = "business_line_filter",
          label = "Business Line",
          choices = choices_with_all(app_data$business_line),
          selected = "All"
        ),
        
        selectInput(
          inputId = "region_filter",
          label = "Region",
          choices = choices_with_all(app_data$region),
          selected = "All"
        ),
        
        selectInput(
          inputId = "quarter_filter",
          label = "Reporting Quarter",
          choices = choices_with_all(app_data$quarter),
          selected = "All"
        ),
        
        actionButton("reset_filters", "Reset filters"),
        
        downloadButton("download_excel", "Download Excel Report"),
        
        uiOutput("current_view")
      ),
      
      div(
        class = "main-content",
        
        uiOutput("kpi_cards"),
        
        div(
          class = "insight-card",
          div(class = "insight-title", "Business Insights"),
          div(class = "insight-box", uiOutput("business_insights"))
        ),
        
        div(
          class = "tab-card",
          tabsetPanel(
            
            tabPanel(
              "Overview",
              br(),
              div(
                class = "plot-grid",
                div(
                  class = "plot-card",
                  div(class = "plot-card-title", "Claims Cost vs Premium"),
                  div(class = "plot-card-subtitle", "Comparison of outgoing claims cost and collected premium by quarter."),
                  plotOutput("claims_premium_plot", height = "360px")
                ),
                div(
                  class = "plot-card",
                  div(class = "plot-card-title", "Loss Ratio by Quarter"),
                  div(class = "plot-card-subtitle", "Dashed line marks an 80% reference threshold."),
                  plotOutput("loss_ratio_plot", height = "360px")
                )
              )
            ),
            
            tabPanel(
              "Severity Trend",
              br(),
              div(
                class = "plot-card",
                div(class = "plot-card-title", "Average Cost per Claim"),
                div(class = "plot-card-subtitle", "Severity is calculated as total claims cost divided by claim count."),
                plotOutput("severity_plot", height = "420px")
              )
            ),
            
            tabPanel(
              "Claim Count",
              br(),
              div(
                class = "plot-card",
                div(class = "plot-card-title", "Claim Count by Quarter"),
                div(class = "plot-card-subtitle", "Shows how claim volume develops over time."),
                plotOutput("claim_count_plot", height = "420px")
              )
            ),
            
            tabPanel(
              "Claims Cost",
              br(),
              div(
                class = "plot-card",
                div(class = "plot-card-title", "Total Claims Cost by Quarter"),
                div(class = "plot-card-subtitle", "Aggregated claims cost in the selected portfolio view."),
                plotOutput("claims_cost_plot", height = "420px")
              )
            ),
            
            tabPanel(
              "Premium",
              br(),
              div(
                class = "plot-card",
                div(class = "plot-card-title", "Premium by Quarter"),
                div(class = "plot-card-subtitle", "Aggregated premium in the selected portfolio view."),
                plotOutput("premium_plot", height = "420px")
              )
            ),
            
            tabPanel(
              "Detail Table",
              br(),
              DT::DTOutput("detail_table")
            )
          )
        )
      )
    )
  )
)

# ------------------------------------------------------------
# Server
# ------------------------------------------------------------

server <- function(input, output, session) {
  
  observeEvent(input$reset_filters, {
    updateSelectInput(session, "business_line_filter", selected = "All")
    updateSelectInput(session, "region_filter", selected = "All")
    updateSelectInput(session, "quarter_filter", selected = "All")
  })
  
  filtered_data <- reactive({
    
    data <- app_data
    
    if (input$business_line_filter != "All") {
      data <- data %>%
        filter(business_line == input$business_line_filter)
    }
    
    if (input$region_filter != "All") {
      data <- data %>%
        filter(region == input$region_filter)
    }
    
    if (input$quarter_filter != "All") {
      data <- data %>%
        filter(quarter == input$quarter_filter)
    }
    
    data
  })
  
  kpi_data <- reactive({
    
    filtered_data() %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(claim_amount, na.rm = TRUE),
        total_premium = sum(premium, na.rm = TRUE),
        avg_severity = safe_divide(total_claim_amount, claim_count),
        loss_ratio = safe_divide(total_claim_amount, total_premium),
        .groups = "drop"
      )
  })
  
  trend_data <- reactive({
    
    filtered_data() %>%
      group_by(quarter_date, quarter) %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(claim_amount, na.rm = TRUE),
        total_premium = sum(premium, na.rm = TRUE),
        avg_severity = safe_divide(total_claim_amount, claim_count),
        loss_ratio = safe_divide(total_claim_amount, total_premium),
        .groups = "drop"
      ) %>%
      arrange(quarter_date)
  })
  
  detail_data <- reactive({
    
    filtered_data() %>%
      group_by(business_line, region, quarter) %>%
      summarise(
        claim_count = sum(claim_count, na.rm = TRUE),
        total_claim_amount = sum(claim_amount, na.rm = TRUE),
        total_premium = sum(premium, na.rm = TRUE),
        avg_severity = safe_divide(total_claim_amount, claim_count),
        loss_ratio = safe_divide(total_claim_amount, total_premium),
        .groups = "drop"
      ) %>%
      arrange(business_line, region, quarter)
  })
  
  output$current_view <- renderUI({
    
    data <- filtered_data()
    
    div(
      class = "current-view",
      div(class = "current-view-title", "Current View"),
      div(paste("Rows:", scales::comma(nrow(data)))),
      div(paste("Business lines:", scales::comma(n_distinct(data$business_line)))),
      div(paste("Regions:", scales::comma(n_distinct(data$region)))),
      div(paste("Quarters:", scales::comma(n_distinct(data$quarter))))
    )
  })
  
  output$kpi_cards <- renderUI({
    
    kpis <- kpi_data()
    
    div(
      class = "kpi-grid",
      
      metric_card(
        icon = "▦",
        label = "Claim Count",
        value = fmt_number(kpis$claim_count),
        helper_text = "Total claims in selected view",
        accent_class = "accent-blue"
      ),
      
      metric_card(
        icon = "€",
        label = "Total Claims Cost",
        value = fmt_euro(kpis$total_claim_amount),
        helper_text = "Aggregated claim amount",
        accent_class = "accent-teal"
      ),
      
      metric_card(
        icon = "▥",
        label = "Total Premium",
        value = fmt_euro(kpis$total_premium),
        helper_text = "Aggregated premium",
        accent_class = "accent-green"
      ),
      
      metric_card(
        icon = "↗",
        label = "Avg Cost per Claim",
        value = fmt_euro(kpis$avg_severity),
        helper_text = "Severity = claims cost / claims",
        accent_class = "accent-amber"
      ),
      
      metric_card(
        icon = "⚖",
        label = "Loss Ratio",
        value = fmt_percent(kpis$loss_ratio),
        helper_text = "Claims cost / premium",
        accent_class = "accent-red"
      )
    )
  })
  
  output$business_insights <- renderUI({
    
    trend <- trend_data()
    
    if (nrow(trend) == 0) {
      return(tags$ul(
        tags$li("No data available for the selected filters.")
      ))
    }
    
    latest <- trend %>%
      arrange(desc(quarter_date)) %>%
      slice(1)
    
    highest_claims <- trend %>%
      arrange(desc(total_claim_amount)) %>%
      slice(1)
    
    latest_loss_ratio <- latest$loss_ratio
    
    loss_ratio_message <- case_when(
      is.na(latest_loss_ratio) ~ "Loss ratio cannot be calculated because premium is missing or zero.",
      latest_loss_ratio >= 0.80 ~ "The selected portfolio has an elevated loss ratio and may require closer review.",
      latest_loss_ratio >= 0.60 ~ "The selected portfolio has a moderate loss ratio.",
      TRUE ~ "The selected portfolio has a relatively low loss ratio."
    )
    
    if (nrow(trend) >= 2) {
      trend_for_change <- trend %>%
        arrange(quarter_date)
      
      latest_cost <- tail(trend_for_change$total_claim_amount, 1)
      previous_cost <- tail(trend_for_change$total_claim_amount, 2)[1]
      
      cost_change <- safe_divide(latest_cost - previous_cost, previous_cost)
      
      movement_text <- paste0(
        "Claims cost changed by ",
        fmt_percent(cost_change),
        " from the previous quarter to the latest quarter."
      )
    } else {
      movement_text <- "Trend movement cannot be calculated because only one quarter is available."
    }
    
    tags$ul(
      tags$li(
        tags$b("Latest quarter: "),
        latest$quarter,
        " with average cost per claim of ",
        fmt_euro(latest$avg_severity),
        "."
      ),
      tags$li(
        tags$b("Highest claims cost quarter: "),
        highest_claims$quarter,
        " with total claims cost of ",
        fmt_euro(highest_claims$total_claim_amount),
        "."
      ),
      tags$li(
        tags$b("Loss ratio view: "),
        loss_ratio_message
      ),
      tags$li(
        tags$b("Trend movement: "),
        movement_text
      )
    )
  })
  
  output$claims_premium_plot <- renderPlot({
    
    trend_long <- trend_data() %>%
      select(quarter_date, quarter, total_claim_amount, total_premium) %>%
      pivot_longer(
        cols = c(total_claim_amount, total_premium),
        names_to = "metric",
        values_to = "value"
      ) %>%
      mutate(
        metric = recode(
          metric,
          total_claim_amount = "Claims Cost",
          total_premium = "Premium"
        )
      )
    
    validate(
      need(nrow(trend_long) > 0, "No data available for the selected filters.")
    )
    
    ggplot(trend_long, aes(x = quarter_date, y = value, color = metric)) +
      geom_line(linewidth = 1.15) +
      geom_point(size = 2.7) +
      scale_y_continuous(labels = scales::dollar_format(prefix = "€")) +
      scale_x_date(date_labels = "%Y-Q%q", date_breaks = "3 months") +
      labs(
        title = NULL,
        x = "Reporting Quarter",
        y = "Amount"
      ) +
      dashboard_theme()
  })
  
  output$severity_plot <- renderPlot({
    
    trend <- trend_data()
    
    validate(
      need(nrow(trend) > 0, "No data available for the selected filters.")
    )
    
    ggplot(trend, aes(x = quarter_date, y = avg_severity)) +
      geom_line(linewidth = 1.15, color = "#2563eb") +
      geom_point(size = 2.8, color = "#2563eb") +
      scale_y_continuous(labels = scales::dollar_format(prefix = "€")) +
      scale_x_date(date_labels = "%Y-Q%q", date_breaks = "3 months") +
      labs(
        title = NULL,
        x = "Reporting Quarter",
        y = "Average Cost per Claim"
      ) +
      dashboard_theme()
  })
  
  output$loss_ratio_plot <- renderPlot({
    
    trend <- trend_data()
    
    validate(
      need(nrow(trend) > 0, "No data available for the selected filters.")
    )
    
    ggplot(trend, aes(x = quarter_date, y = loss_ratio)) +
      geom_hline(yintercept = 0.80, linetype = "dashed", color = "#ef4444") +
      geom_line(linewidth = 1.15, color = "#0f766e") +
      geom_point(size = 2.8, color = "#0f766e") +
      scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
      scale_x_date(date_labels = "%Y-Q%q", date_breaks = "3 months") +
      labs(
        title = NULL,
        x = "Reporting Quarter",
        y = "Loss Ratio"
      ) +
      dashboard_theme()
  })
  
  output$claim_count_plot <- renderPlot({
    
    trend <- trend_data()
    
    validate(
      need(nrow(trend) > 0, "No data available for the selected filters.")
    )
    
    ggplot(trend, aes(x = quarter_date, y = claim_count)) +
      geom_col(fill = "#2563eb", alpha = 0.88, width = 55) +
      geom_text(
        aes(label = scales::comma(claim_count)),
        vjust = -0.45,
        fontface = "bold",
        color = "#374151"
      ) +
      scale_y_continuous(labels = scales::comma, expand = expansion(mult = c(0, 0.14))) +
      scale_x_date(date_labels = "%Y-Q%q", date_breaks = "3 months") +
      labs(
        title = NULL,
        x = "Reporting Quarter",
        y = "Claim Count"
      ) +
      dashboard_theme()
  })
  
  output$claims_cost_plot <- renderPlot({
    
    trend <- trend_data()
    
    validate(
      need(nrow(trend) > 0, "No data available for the selected filters.")
    )
    
    ggplot(trend, aes(x = quarter_date, y = total_claim_amount)) +
      geom_col(fill = "#14b8a6", alpha = 0.88, width = 55) +
      scale_y_continuous(labels = scales::dollar_format(prefix = "€")) +
      scale_x_date(date_labels = "%Y-Q%q", date_breaks = "3 months") +
      labs(
        title = NULL,
        x = "Reporting Quarter",
        y = "Total Claims Cost"
      ) +
      dashboard_theme()
  })
  
  output$premium_plot <- renderPlot({
    
    trend <- trend_data()
    
    validate(
      need(nrow(trend) > 0, "No data available for the selected filters.")
    )
    
    ggplot(trend, aes(x = quarter_date, y = total_premium)) +
      geom_col(fill = "#22c55e", alpha = 0.88, width = 55) +
      scale_y_continuous(labels = scales::dollar_format(prefix = "€")) +
      scale_x_date(date_labels = "%Y-Q%q", date_breaks = "3 months") +
      labs(
        title = NULL,
        x = "Reporting Quarter",
        y = "Total Premium"
      ) +
      dashboard_theme()
  })
  
  output$detail_table <- DT::renderDT({
    
    table_data <- detail_data() %>%
      mutate(
        claim_count = scales::comma(claim_count),
        total_claim_amount = fmt_euro(total_claim_amount),
        total_premium = fmt_euro(total_premium),
        avg_severity = fmt_euro(avg_severity),
        loss_ratio = fmt_percent(loss_ratio)
      ) %>%
      rename(
        `Business Line` = business_line,
        `Region` = region,
        `Quarter` = quarter,
        `Claim Count` = claim_count,
        `Total Claims Cost` = total_claim_amount,
        `Total Premium` = total_premium,
        `Avg Cost per Claim` = avg_severity,
        `Loss Ratio` = loss_ratio
      )
    
    DT::datatable(
      table_data,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        autoWidth = TRUE,
        scrollX = TRUE
      )
    )
  })
  
  output$download_excel <- downloadHandler(
    
    filename = function() {
      paste0("insurance_dashboard_report_", Sys.Date(), ".xlsx")
    },
    
    content = function(file) {
      
      wb <- openxlsx::createWorkbook()
      
      openxlsx::addWorksheet(wb, "KPIs")
      openxlsx::writeData(wb, "KPIs", kpi_data())
      
      openxlsx::addWorksheet(wb, "Quarterly Trend")
      openxlsx::writeData(wb, "Quarterly Trend", trend_data())
      
      openxlsx::addWorksheet(wb, "Detail Table")
      openxlsx::writeData(wb, "Detail Table", detail_data())
      
      openxlsx::saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
}

# ------------------------------------------------------------
# Run app
# ------------------------------------------------------------

shinyApp(ui = ui, server = server)



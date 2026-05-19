# ============================================================
# app.R
# Insurance Reporting Dashboard
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

metric_card <- function(title, value) {
  div(
    style = "
      background-color: #f7f7f7;
      border: 1px solid #dddddd;
      border-radius: 10px;
      padding: 16px;
      margin-bottom: 12px;
    ",
    h4(title, style = "margin-top: 0;"),
    h2(value, style = "font-weight: bold; margin-bottom: 0;")
  )
}

dashboard_theme <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )
}

# ------------------------------------------------------------
# UI
# ------------------------------------------------------------

ui <- fluidPage(
  
  titlePanel("Insurance Reporting Dashboard"),
  
  sidebarLayout(
    
    sidebarPanel(
      h4("Filters"),
      
      selectInput(
        inputId = "business_line_filter",
        label = "Business Line:",
        choices = choices_with_all(app_data$business_line),
        selected = "All"
      ),
      
      selectInput(
        inputId = "region_filter",
        label = "Region:",
        choices = choices_with_all(app_data$region),
        selected = "All"
      ),
      
      selectInput(
        inputId = "quarter_filter",
        label = "Quarter:",
        choices = choices_with_all(app_data$quarter),
        selected = "All"
      ),
      
      actionButton("reset_filters", "Reset filters"),
      
      br(),
      br(),
      
      downloadButton("download_excel", "Download Excel Report")
    ),
    
    mainPanel(
      
      h3("Insurance Reporting Dashboard"),
      
      p("This dashboard summarizes claims, premium, severity, and loss ratio trends from prepared insurance data."),
      
      tabsetPanel(
        
        tabPanel(
          "Overview",
          br(),
          uiOutput("kpi_cards"),
          br(),
          plotOutput("claims_premium_plot", height = "350px")
        ),
        
        tabPanel(
          "Severity Trend",
          br(),
          plotOutput("severity_plot", height = "350px")
        ),
        
        tabPanel(
          "Loss Ratio Trend",
          br(),
          plotOutput("loss_ratio_plot", height = "350px")
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
  
  output$kpi_cards <- renderUI({
    
    kpis <- kpi_data()
    
    fluidRow(
      column(
        width = 4,
        metric_card(
          "Claim Count",
          scales::comma(kpis$claim_count)
        )
      ),
      column(
        width = 4,
        metric_card(
          "Total Claim Amount",
          scales::dollar(kpis$total_claim_amount, prefix = "€")
        )
      ),
      column(
        width = 4,
        metric_card(
          "Total Premium",
          scales::dollar(kpis$total_premium, prefix = "€")
        )
      ),
      column(
        width = 4,
        metric_card(
          "Average Severity",
          scales::dollar(kpis$avg_severity, prefix = "€")
        )
      ),
      column(
        width = 4,
        metric_card(
          "Loss Ratio",
          scales::percent(kpis$loss_ratio, accuracy = 0.1)
        )
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
          total_claim_amount = "Claims",
          total_premium = "Premium"
        )
      )
    
    ggplot(trend_long, aes(x = quarter_date, y = value, color = metric)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_y_continuous(labels = scales::dollar_format(prefix = "€")) +
      labs(
        title = "Claims vs Premium by Quarter",
        x = "Quarter",
        y = "Amount",
        color = "Metric"
      ) +
      dashboard_theme()
  })
  
  output$severity_plot <- renderPlot({
    
    ggplot(trend_data(), aes(x = quarter_date, y = avg_severity)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_y_continuous(labels = scales::dollar_format(prefix = "€")) +
      labs(
        title = "Average Severity Trend",
        x = "Quarter",
        y = "Average Severity"
      ) +
      dashboard_theme()
  })
  
  output$loss_ratio_plot <- renderPlot({
    
    ggplot(trend_data(), aes(x = quarter_date, y = loss_ratio)) +
      geom_line(linewidth = 1.1) +
      geom_point(size = 2) +
      scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
      labs(
        title = "Loss Ratio Trend",
        x = "Quarter",
        y = "Loss Ratio"
      ) +
      dashboard_theme()
  })
  
  output$detail_table <- DT::renderDT({
    
    detail_data() %>%
      mutate(
        total_claim_amount = scales::dollar(total_claim_amount, prefix = "€"),
        total_premium = scales::dollar(total_premium, prefix = "€"),
        avg_severity = scales::dollar(avg_severity, prefix = "€"),
        loss_ratio = scales::percent(loss_ratio, accuracy = 0.1)
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
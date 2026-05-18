# ============================================================
# app.R
# Insurance Reporting Dashboard
# ============================================================

source("R/00_packages.R")
source("R/01_generate_sample_data.R")
source("R/02_clean_data.R")
source("R/03_calculate_metrics.R")
source("R/04_create_plots.R")
source("R/05_export_outputs.R")

# ------------------------------------------------------------
# Prepare data
# ------------------------------------------------------------

raw_data <- generate_sample_insurance_data()
clean_data <- clean_insurance_data(raw_data)
metrics_data <- calculate_insurance_metrics(clean_data)

# ------------------------------------------------------------
# UI
# ------------------------------------------------------------

ui <- fluidPage(
  
  titlePanel("Insurance Reporting Dashboard"),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput(
        inputId = "line_filter",
        label = "Select business line:",
        choices = c("All", sort(unique(metrics_data$line))),
        selected = "All"
      ),
      
      selectInput(
        inputId = "region_filter",
        label = "Select region:",
        choices = c("All", sort(unique(metrics_data$region))),
        selected = "All"
      )
    ),
    
    mainPanel(
      
      h3("Project skeleton"),
      
      p("This is the first skeleton version of the insurance reporting dashboard."),
      
      tabsetPanel(
        
        tabPanel(
          "Summary Table",
          DT::DTOutput("summary_table")
        ),
        
        tabPanel(
          "Severity Trend",
          plotOutput("severity_plot")
        ),
        
        tabPanel(
          "Loss Ratio Trend",
          plotOutput("loss_ratio_plot")
        )
      )
    )
  )
)

# ------------------------------------------------------------
# Server
# ------------------------------------------------------------

server <- function(input, output, session) {
  
  filtered_metrics <- reactive({
    
    data <- metrics_data
    
    if (input$line_filter != "All") {
      data <- data %>%
        filter(line == input$line_filter)
    }
    
    if (input$region_filter != "All") {
      data <- data %>%
        filter(region == input$region_filter)
    }
    
    data
  })
  
  output$summary_table <- DT::renderDT({
    filtered_metrics()
  })
  
  output$severity_plot <- renderPlot({
    create_severity_plot(filtered_metrics())
  })
  
  output$loss_ratio_plot <- renderPlot({
    create_loss_ratio_plot(filtered_metrics())
  })
}

# ------------------------------------------------------------
# Run app
# ------------------------------------------------------------

shinyApp(ui = ui, server = server)
library(shiny)
library(dplyr)
library(readr)
library(sf)
library(leaflet)
library(ggplot2)
library(scales)
library(bslib)
library(htmltools)

# -----------------------------
# Load province-level dashboard data
# -----------------------------
province_data <- read_csv(
  "data/processed/province_dashboard_data.csv",
  show_col_types = FALSE
)

# Harmonize province names to match map
province_data_clean <- province_data %>%
  mutate(
    province_map = case_when(
      province == "Herat" ~ "Hirat",
      province == "Sar-e Pol" ~ "Sar-e-Pul",
      province == "Wardak" ~ "Maidan Wardak",
      province == "Helmand" ~ "Hilmand",
      TRUE ~ province
    )
  )

# -----------------------------
# Load province shapefile
# -----------------------------
afg_provinces <- st_read(
  "data/spatial/afg_admin_boundaries/afg_admin1.shp",
  quiet = TRUE
)

# Join map with dashboard data
afg_map_data <- afg_provinces %>%
  left_join(province_data_clean, by = c("adm1_name" = "province_map"))

# -----------------------------
# Labels
# -----------------------------
indicator_choices <- c(
  "Average Vulnerability Score" = "avg_vulnerability_score",
  "High Vulnerability Rate" = "pct_high_vulnerability",
  "Food Insecurity Rate" = "food_insecurity_rate",
  "Healthcare Access Rate" = "healthcare_access_rate",
  "School Access Rate" = "school_access_rate",
  "Displacement Rate" = "displacement_rate",
  "Average Monthly Income" = "avg_income"
)

indicator_labels <- c(
  avg_vulnerability_score = "Average Vulnerability Score",
  pct_high_vulnerability = "High Vulnerability Rate",
  food_insecurity_rate = "Food Insecurity Rate",
  healthcare_access_rate = "Healthcare Access Rate",
  school_access_rate = "School Access Rate",
  displacement_rate = "Displacement Rate",
  avg_income = "Average Monthly Income"
)

# Vector-safe formatter for map labels, KPIs, and chart labels
format_indicator_value <- function(x, indicator) {
  if (indicator == "avg_income") {
    return(ifelse(is.na(x), "No data", scales::comma(round(x, 0))))
  }

  if (indicator == "avg_vulnerability_score") {
    return(ifelse(is.na(x), "No data", as.character(round(x, 2))))
  }

  return(ifelse(is.na(x), "No data", scales::percent(x, accuracy = 0.1)))
}

# -----------------------------
# Theme
# -----------------------------
app_theme <- bs_theme(
  version = 5,
  bg = "#F7F9FC",
  fg = "#1F2937",
  primary = "#1F4E79",
  secondary = "#6B7280",
  base_font = font_google("Inter"),
  heading_font = font_google("Inter")
)

# -----------------------------
# UI
# -----------------------------
ui <- page_fluid(
  theme = app_theme,

  tags$head(
    tags$style(HTML("
      .app-header {
        background: #1F4E79;
        color: white;
        padding: 18px 24px;
        border-radius: 10px;
        margin-bottom: 18px;
      }
      .app-title {
        font-size: 28px;
        font-weight: 700;
        margin: 0;
      }
      .app-subtitle {
        font-size: 14px;
        opacity: 0.9;
        margin-top: 6px;
      }
      .control-card, .kpi-card, .panel-card {
        background: white;
        border-radius: 12px;
        padding: 16px 18px;
        box-shadow: 0 1px 6px rgba(0,0,0,0.08);
        margin-bottom: 16px;
      }
      .kpi-label {
        font-size: 13px;
        color: #6B7280;
        margin-bottom: 6px;
      }
      .kpi-value {
        font-size: 26px;
        font-weight: 700;
        color: #1F2937;
      }
      .section-title {
        font-size: 16px;
        font-weight: 700;
        margin-bottom: 10px;
        color: #1F2937;
      }
      .leaflet-container {
        border-radius: 10px;
      }
      .footer-note {
        margin-top: 20px;
        padding: 12px 18px;
        background: #ffffff;
        border-radius: 10px;
        font-size: 12px;
        color: #6B7280;
        box-shadow: 0 1px 5px rgba(0,0,0,0.05);
      }
    "))
  ),

  div(
    class = "app-header",
    div(class = "app-title", "Afghanistan Humanitarian Dashboard"),
    div(
      class = "app-subtitle",
      "Multi-province analysis of vulnerability, food insecurity, displacement, and access to services"
    )
  ),

  layout_columns(
    col_widths = c(3, 9),

    # LEFT COLUMN
    div(
      class = "control-card",
      div(class = "section-title", "Dashboard Controls"),
      selectInput(
        "indicator",
        "Indicator",
        choices = indicator_choices,
        selected = "avg_vulnerability_score"
      ),
      selectInput(
        "province_filter",
        "Province Focus",
        choices = c("All Provinces", sort(unique(province_data_clean$province))),
        selected = "All Provinces"
      )
    ),

    # RIGHT COLUMN
    div(
      layout_columns(
        col_widths = c(3, 3, 3, 3),

        div(
          class = "kpi-card",
          div(class = "kpi-label", "Average Vulnerability"),
          div(class = "kpi-value", textOutput("kpi_vulnerability", inline = TRUE))
        ),
        div(
          class = "kpi-card",
          div(class = "kpi-label", "Food Insecurity"),
          div(class = "kpi-value", textOutput("kpi_food", inline = TRUE))
        ),
        div(
          class = "kpi-card",
          div(class = "kpi-label", "Healthcare Access"),
          div(class = "kpi-value", textOutput("kpi_health", inline = TRUE))
        ),
        div(
          class = "kpi-card",
          div(class = "kpi-label", "Displacement Rate"),
          div(class = "kpi-value", textOutput("kpi_displacement", inline = TRUE))
        )
      ),

      div(
        class = "panel-card",
        div(class = "section-title", "Provincial Map"),
        leafletOutput("map", height = 560)
      ),

      div(
        class = "panel-card",
        div(class = "section-title", "Province Comparison"),
        plotOutput("barplot", height = 380)
      )
    )
  ),

  div(
    class = "footer-note",
    strong("Note: "),
    "This dashboard is based on a simulated household dataset covering 20 provinces in Afghanistan. ",
    "Indicators are constructed to reflect typical humanitarian assessment frameworks, including food security, service access, and displacement dynamics. ",
    "The dashboard is intended for analytical demonstration and portfolio purposes only."
  )
)

# -----------------------------
# Server
# -----------------------------
server <- function(input, output, session) {

  filtered_province_data <- reactive({
    if (input$province_filter == "All Provinces") {
      province_data_clean
    } else {
      province_data_clean %>% filter(province == input$province_filter)
    }
  })

  filtered_map_data <- reactive({
    if (input$province_filter == "All Provinces") {
      afg_map_data
    } else {
      afg_map_data %>% filter(adm1_name == filtered_province_data()$province_map[1])
    }
  })

  pal <- reactive({
    colorNumeric(
      palette = c("#FFF7BC", "#FEC44F", "#FE9929", "#D95F0E", "#993404"),
      domain = afg_map_data[[input$indicator]],
      na.color = "#E5E7EB"
    )
  })

  output$kpi_vulnerability <- renderText({
    round(mean(filtered_province_data()$avg_vulnerability_score, na.rm = TRUE), 2)
  })

  output$kpi_food <- renderText({
    percent(mean(filtered_province_data()$food_insecurity_rate, na.rm = TRUE), accuracy = 0.1)
  })

  output$kpi_health <- renderText({
    percent(mean(filtered_province_data()$healthcare_access_rate, na.rm = TRUE), accuracy = 0.1)
  })

  output$kpi_displacement <- renderText({
    percent(mean(filtered_province_data()$displacement_rate, na.rm = TRUE), accuracy = 0.1)
  })

  output$map <- renderLeaflet({
    map_data <- filtered_map_data()

    leaflet(map_data) %>%
      addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
      addPolygons(
        fillColor = ~pal()(get(input$indicator)),
        weight = 1,
        opacity = 1,
        color = "white",
        fillOpacity = 0.9,
        smoothFactor = 0.2,
        highlight = highlightOptions(
          weight = 2,
          color = "#1F2937",
          fillOpacity = 1,
          bringToFront = TRUE
        ),
        label = ~lapply(
          paste0(
            "<strong>Province:</strong> ", adm1_name, "<br/>",
            "<strong>", indicator_labels[[input$indicator]], ":</strong> ",
            format_indicator_value(get(input$indicator), input$indicator)
          ),
          HTML
        )
      ) %>%
      addLegend(
        position = "bottomright",
        pal = pal(),
        values = afg_map_data[[input$indicator]],
        title = indicator_labels[[input$indicator]],
        opacity = 0.95
      )
  })

  output$barplot <- renderPlot({

    plot_data <- filtered_province_data() %>%
      arrange(desc(.data[[input$indicator]]))

    ggplot(
      plot_data,
      aes(
        x = reorder(province, .data[[input$indicator]]),
        y = .data[[input$indicator]]
      )
    ) +
      geom_col(fill = "#1F4E79", width = 0.65) +
      geom_text(
        aes(
          label = format_indicator_value(.data[[input$indicator]], input$indicator)
        ),
        hjust = -0.15,
        size = 3.8,
        color = "#1F2937"
      ) +
      coord_flip() +
      labs(
        title = paste("Provincial Comparison:", indicator_labels[[input$indicator]]),
        subtitle = ifelse(
          input$province_filter == "All Provinces",
          "Comparison across provinces included in the analysis",
          paste("Focused view:", input$province_filter)
        ),
        x = NULL,
        y = NULL
      ) +
      scale_y_continuous(
        expand = expansion(mult = c(0, 0.1))
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold", size = 15),
        plot.subtitle = element_text(size = 11, color = "gray35"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 11, color = "#1F2937"),
        axis.text.x = element_text(size = 10, color = "#4B5563")
      )
  })
}

shinyApp(ui = ui, server = server)

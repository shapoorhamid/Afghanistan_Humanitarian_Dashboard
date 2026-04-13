library(shiny)
library(dplyr)
library(readr)
library(sf)
library(leaflet)
library(ggplot2)
library(scales)

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
# Indicator choices
# -----------------------------
indicator_choices <- c(
  "Average Vulnerability Score" = "avg_vulnerability_score",
  "High Vulnerability Rate" = "pct_high_vulnerability",
  "Food Insecurity Rate" = "food_insecurity_rate",
  "Healthcare Access Rate" = "healthcare_access_rate",
  "School Access Rate" = "school_access_rate",
  "Displacement Rate" = "displacement_rate",
  "Average Income" = "avg_income"
)

# -----------------------------
# UI
# -----------------------------
ui <- fluidPage(
  titlePanel("Afghanistan Humanitarian Dashboard"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        "indicator",
        "Select Indicator",
        choices = indicator_choices,
        selected = "avg_vulnerability_score"
      )
    ),

    mainPanel(
      leafletOutput("map", height = 500),
      br(),
      plotOutput("barplot", height = 350)
    )
  )
)

# -----------------------------
# Server
# -----------------------------
server <- function(input, output, session) {

  # Color palette for selected indicator
  pal <- reactive({
    colorNumeric(
      palette = "YlOrRd",
      domain = afg_map_data[[input$indicator]],
      na.color = "#d9d9d9"
    )
  })

  # Leaflet map
  output$map <- renderLeaflet({

    leaflet(afg_map_data) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(
        fillColor = ~pal()(get(input$indicator)),
        weight = 1,
        opacity = 1,
        color = "white",
        fillOpacity = 0.8,
        smoothFactor = 0.2,
        label = ~paste0(
          "<strong>Province:</strong> ", adm1_name, "<br/>",
          "<strong>Value:</strong> ",
          ifelse(
            is.na(get(input$indicator)),
            "No data",
            ifelse(
              input$indicator == "avg_income",
              comma(round(get(input$indicator), 0)),
              ifelse(
                input$indicator == "avg_vulnerability_score",
                round(get(input$indicator), 2),
                percent(get(input$indicator), accuracy = 0.1)
              )
            )
          )
        ) %>% lapply(htmltools::HTML)
      ) %>%
      addLegend(
        "bottomright",
        pal = pal(),
        values = afg_map_data[[input$indicator]],
        title = input$indicator,
        opacity = 0.9
      )
  })

  # Province comparison chart
  output$barplot <- renderPlot({

    plot_data <- province_data_clean %>%
      arrange(desc(.data[[input$indicator]]))

    ggplot(
      plot_data,
      aes(
        x = reorder(province, .data[[input$indicator]]),
        y = .data[[input$indicator]]
      )
    ) +
      geom_col(fill = "#2F5D8A", width = 0.7) +
      coord_flip() +
      labs(
        title = paste("Province Comparison:", input$indicator),
        x = NULL,
        y = NULL
      ) +
      theme_minimal(base_size = 13)
  })
}

# -----------------------------
# Run app
# -----------------------------
shinyApp(ui = ui, server = server)

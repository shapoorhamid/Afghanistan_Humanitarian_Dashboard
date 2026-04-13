library(dplyr)
library(readr)

# Load dataset with vulnerability
df <- read_csv("data/processed/dashboard_data_with_vulnerability.csv", show_col_types = FALSE)

# -----------------------------
# Aggregate at province level
# -----------------------------
province_data <- df %>%
  group_by(province) %>%
  summarise(

    # Population size
    households = n(),

    # Vulnerability
    avg_vulnerability_score = mean(vulnerability_score, na.rm = TRUE),
    pct_high_vulnerability = mean(vulnerability_category == "High", na.rm = TRUE),
    pct_moderate_vulnerability = mean(vulnerability_category == "Moderate", na.rm = TRUE),

    # Food security
    food_insecurity_rate = mean(food_shortage, na.rm = TRUE),
    low_meals_rate = mean(meals_per_day < 3, na.rm = TRUE),

    # Services
    healthcare_access_rate = mean(healthcare_access, na.rm = TRUE),
    school_access_rate = mean(school_access, na.rm = TRUE),

    # Living conditions
    shelter_adequacy_rate = mean(adequate_shelter, na.rm = TRUE),
    water_access_rate = mean(water_access, na.rm = TRUE),
    electricity_access_rate = mean(electricity, na.rm = TRUE),

    # Coping
    borrowing_rate = mean(borrowed_money, na.rm = TRUE),
    reduced_meals_rate = mean(reduced_meals, na.rm = TRUE),
    asset_sale_rate = mean(sold_assets, na.rm = TRUE),

    # Displacement
    displacement_rate = mean(displacement_status != "Non-displaced", na.rm = TRUE),

    # Economic
    avg_income = mean(monthly_income, na.rm = TRUE),

    .groups = "drop"
  )

# -----------------------------
# Clean for dashboard readability
# -----------------------------
province_data <- province_data %>%
  mutate(
    pct_high_vulnerability = round(pct_high_vulnerability, 3),
    food_insecurity_rate = round(food_insecurity_rate, 3),
    healthcare_access_rate = round(healthcare_access_rate, 3),
    school_access_rate = round(school_access_rate, 3),
    displacement_rate = round(displacement_rate, 3)
  )

# -----------------------------
# Save output
# -----------------------------
write_csv(province_data, "data/processed/province_dashboard_data.csv")

cat("Province-level dataset created for dashboard.\n")

# Quick preview
print(head(province_data))

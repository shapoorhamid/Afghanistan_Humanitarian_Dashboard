library(dplyr)
library(readr)

# Load raw data
df <- read_csv("data/raw/dashboard_data.csv", show_col_types = FALSE)

# Define province tiers
high_dev <- c("Kabul","Herat","Balkh")
mid_dev  <- c("Nangarhar","Kandahar","Bamyan","Samangan","Faryab")

df2 <- df %>%
  mutate(
    dev_tier = case_when(
      province %in% high_dev ~ "high",
      province %in% mid_dev ~ "medium",
      TRUE ~ "low"
    )
  )

# Apply variation
df2 <- df2 %>%
  mutate(

    # Income adjustments
    monthly_income = case_when(
      dev_tier == "high" ~ round(monthly_income * runif(n(), 1.2, 1.5)),
      dev_tier == "medium" ~ round(monthly_income * runif(n(), 0.9, 1.1)),
      dev_tier == "low" ~ round(monthly_income * runif(n(), 0.6, 0.85))
    ),

    # Food insecurity (increase in low-tier)
    food_shortage = case_when(
      dev_tier == "high" ~ rbinom(n(), 1, 0.35),
      dev_tier == "medium" ~ rbinom(n(), 1, 0.5),
      dev_tier == "low" ~ rbinom(n(), 1, 0.7)
    ),

    # Healthcare access
    healthcare_access = case_when(
      dev_tier == "high" ~ rbinom(n(), 1, 0.85),
      dev_tier == "medium" ~ rbinom(n(), 1, 0.65),
      dev_tier == "low" ~ rbinom(n(), 1, 0.45)
    ),

    # School access
    school_access = case_when(
      dev_tier == "high" ~ rbinom(n(), 1, 0.9),
      dev_tier == "medium" ~ rbinom(n(), 1, 0.7),
      dev_tier == "low" ~ rbinom(n(), 1, 0.5)
    ),

    # Shelter quality
    adequate_shelter = case_when(
      dev_tier == "high" ~ rbinom(n(), 1, 0.85),
      dev_tier == "medium" ~ rbinom(n(), 1, 0.65),
      dev_tier == "low" ~ rbinom(n(), 1, 0.5)
    ),

    # Coping behavior
    borrowed_money = case_when(
      dev_tier == "high" ~ rbinom(n(), 1, 0.4),
      dev_tier == "medium" ~ rbinom(n(), 1, 0.55),
      dev_tier == "low" ~ rbinom(n(), 1, 0.7)
    ),

    reduced_meals = case_when(
      dev_tier == "high" ~ rbinom(n(), 1, 0.35),
      dev_tier == "medium" ~ rbinom(n(), 1, 0.5),
      dev_tier == "low" ~ rbinom(n(), 1, 0.7)
    )
  )

# Clean income floor
df2 <- df2 %>%
  mutate(monthly_income = ifelse(monthly_income < 2000, 2000, monthly_income))

# Save
write_csv(df2, "data/processed/dashboard_data_with_variation.csv")

cat("Provincial variation applied.\n")

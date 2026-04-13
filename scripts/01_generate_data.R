set.seed(123)

library(dplyr)
library(readr)

n <- 2000

provinces <- c(
  "Kabul","Herat","Balkh","Nangarhar","Kandahar",
  "Kunduz","Baghlan","Badakhshan","Takhar","Bamyan",
  "Ghazni","Logar","Wardak","Helmand","Uruzgan",
  "Farah","Faryab","Samangan","Jawzjan","Sar-e Pol"
)

df <- tibble(
  household_id = sprintf("HH%04d", 1:n),
  province = sample(provinces, n, replace = TRUE),

  settlement_type = sample(c("Urban","Rural"), n, replace = TRUE, prob = c(0.4,0.6)),

  household_size = sample(3:12, n, replace = TRUE),

  female_headed = sample(c(0,1), n, replace = TRUE, prob = c(0.8,0.2)),

  displacement_status = sample(c("Non-displaced","IDP","Returnee"), n, replace = TRUE, prob = c(0.6,0.25,0.15)),

  monthly_income = round(rnorm(n, 12000, 4000)),

  meals_per_day = sample(1:4, n, replace = TRUE, prob = c(0.1,0.3,0.5,0.1)),

  food_shortage = sample(c(0,1), n, replace = TRUE, prob = c(0.5,0.5)),

  healthcare_access = sample(c(0,1), n, replace = TRUE, prob = c(0.3,0.7)),

  school_access = sample(c(0,1), n, replace = TRUE, prob = c(0.25,0.75)),

  adequate_shelter = sample(c(0,1), n, replace = TRUE, prob = c(0.3,0.7)),

  water_access = sample(c(0,1), n, replace = TRUE, prob = c(0.2,0.8)),

  electricity = sample(c(0,1), n, replace = TRUE, prob = c(0.35,0.65)),

  borrowed_money = sample(c(0,1), n, replace = TRUE, prob = c(0.45,0.55)),

  reduced_meals = sample(c(0,1), n, replace = TRUE, prob = c(0.5,0.5)),

  sold_assets = sample(c(0,1), n, replace = TRUE, prob = c(0.7,0.3))
)

write_csv(df, "data/raw/dashboard_data.csv")

cat("Dataset generated.\n")

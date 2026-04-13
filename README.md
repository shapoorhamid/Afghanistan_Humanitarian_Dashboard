# Afghanistan Humanitarian Dashboard  
**Interactive Analysis of Vulnerability, Food Security, and Access to Services**

---

## Overview

This project presents an **interactive humanitarian dashboard** for Afghanistan, designed to simulate how analysts explore vulnerability, food insecurity, displacement, and access to essential services across provinces.

The dashboard is built using **R Shiny and Leaflet**, combining spatial analysis, indicator construction, and data visualization into a decision-support tool.

---

## Objectives

- Develop a **multi-province analytical dashboard**
- Simulate a **household-level dataset** reflecting humanitarian conditions
- Construct **vulnerability and sectoral indicators**
- Enable **interactive exploration** through maps and charts
- Demonstrate a **policy-oriented data product** aligned with humanitarian workflows

---

## Key Features

### 🗺️ Interactive Provincial Map
- Choropleth map of Afghanistan
- Select indicators dynamically
- Hover to view province-level values
- Grey areas indicate provinces without simulated data

---

### 📊 Province Comparison Chart
- Ranked comparison across provinces
- Dynamic updates based on selected indicator
- Clean, policy-style visualization

---

### 📌 Key Indicators (KPIs)
- Average vulnerability score  
- Food insecurity rate  
- Healthcare access rate  
- Displacement rate  

---

### ⚙️ Dashboard Controls
- Indicator selection (multiple sectors)
- Province focus (filter view)

---

## Indicators Included

- **Average Vulnerability Score**
- **High Vulnerability Rate**
- **Food Insecurity Rate**
- **Healthcare Access Rate**
- **School Access Rate**
- **Displacement Rate**
- **Average Monthly Income**

---

## Methodology

This dashboard is based on a **simulated dataset of 2,000 households** across **20 provinces** in Afghanistan.

### Data Simulation

The dataset includes:

- Demographics and household structure  
- Displacement status (IDP, returnee, non-displaced)  
- Economic conditions (income, debt)  
- Food security indicators  
- Access to services (healthcare, education)  
- Living conditions and coping strategies  

Provincial variation was introduced to reflect realistic differences in:
- service access  
- income levels  
- vulnerability patterns  

---

### Vulnerability Index

A composite vulnerability score was constructed using:

- economic stress  
- food insecurity  
- limited service access  
- inadequate living conditions  
- coping strategies  
- displacement status  

Households are categorized into:
- Low vulnerability  
- Moderate vulnerability  
- High vulnerability  

---

### Aggregation

Household-level data was aggregated to the **province level** to produce:

- rates (e.g., food insecurity, displacement)  
- averages (e.g., income, vulnerability score)  

These indicators feed directly into the dashboard.

---

## Repository Structure
afghanistan-humanitarian-dashboard/

├── app.R
├── data/
│ ├── raw/
│ ├── processed/
│ └── spatial/
├── scripts/
└── README.md


---

## How to Run the Dashboard

1. Clone the repository  
2. Open the project in RStudio  
3. Install required packages:

```r
install.packages(c("shiny","dplyr","readr","sf","leaflet","ggplot2","scales","bslib"))
4. shiny::runApp()

## Tools and Technologies
R
Shiny (interactive dashboard)
Leaflet (mapping)
sf (spatial data handling)
ggplot2 (visualization)
dplyr (data manipulation)

## Important Note

This dashboard is based on simulated data and is intended for:

demonstration
portfolio development
analytical showcase

It does not represent real-world data or official statistics.

## Author

Shapoor Hamid
Research & Data Analyst
Specializing in migration, vulnerability, and humanitarian analytics

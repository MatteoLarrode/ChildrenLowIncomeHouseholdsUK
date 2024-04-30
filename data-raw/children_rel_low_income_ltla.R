# ---- CHILDREN IN RELATIVE LOW INCOME FAMILIES - LOCAL AUTHORITIES ----
# NOTE: Local authorities (called ltla for Lower Tier Local Authorities) - 363
# - England: English local authority districts (309)
# - Wales: Unitary authorities (22)
# - Scotland: Scottish council areas (32)
# - Northern Ireland: District council areas (11)

# ---- Setup ----
library(tidyverse)
library(httr2)
library(readODS)
library(janitor)
library(geographr)
library(sf)
library(readxl)
library(imputeTS)

ltla21 <- geographr::boundaries_ltla21 |>
  st_drop_geometry()

# ---- Number of Children ----
# For age filtering, Children in Low Income Families dataset considers 0-16
# England & Wales - Source: Office for National Statistics
# https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales
url_eng_wales <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2022detailedtimeseries/myebtablesenglandwales20112022v2.xlsx"
download_eng_wales <- tempfile(fileext = ".xlsx")

request(url_eng_wales) |>
  req_progress() |>
  req_perform(download_eng_wales)

population_raw_eng_wales <- read_excel(
  download_eng_wales,
  sheet = "MYEB1 (2021 Geography)",
  range = "A2:Q60244"
)

children_pop_eng_wales <- population_raw_eng_wales |>
  filter(age < 16) |>
  group_by(ladcode21) |>
  summarise(
    population_0_16_2015 = sum(population_2015),
    population_0_16_2016 = sum(population_2016),
    population_0_16_2017 = sum(population_2017),
    population_0_16_2018 = sum(population_2018),
    population_0_16_2019 = sum(population_2019),
    population_0_16_2020 = sum(population_2020),
    population_0_16_2021 = sum(population_2021),
    population_0_16_2022 = sum(population_2022)
  ) |>
  rename(ltla21_code = ladcode21) |>
  pivot_longer(
    cols = starts_with("population_0_16"),
    names_to = "year",
    values_to = "population_0_16"
  ) |>
  mutate(year = as.numeric(str_extract(year, "\\d{4}")))

# Scotland - Source: National Records of Scotland
# https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/mid-year-population-estimates/population-estimates-time-series-data
url_scot <- "https://www.nrscotland.gov.uk/files//statistics/population-estimates/mid-21/mid-year-pop-est-21-time-series-data.xlsx"
download_scot <- tempfile(fileext = ".xlsx")

request(url_scot) |>
  req_progress() |>
  req_perform(download_scot)

population_raw_scot <- read_excel(
  download_scot,
  sheet = "Table_1",
  range = "A6:CR4065"
  )|> 
  clean_names()

children_pop_scot <- population_raw_scot |> 
  filter(between(year, 2015, 2022) & sex == "Persons") |> 
  rowwise() |> 
  mutate(population_0_16 = sum(c_across(x0:x16))) |> 
  select(ltla21_code = area_code,
         year,
         population_0_16) |> 
  filter(ltla21_code != "S92000003")

# Final children population dataset
population_0_16 <- rbind(children_pop_eng_wales, children_pop_scot) |> 
  group_by(ltla21_code) |> 
  ungroup()

# ---- Children in relative low income families - Local Authorities ----
# Source: Department of Work and Pensions (DWP)
# Stat-Xplore - Children in Low Income Families > Relative Low Income
# Geography (residence-based) - UK > Local Authority
children_low_income_ltla_wide <- read_csv("inst/extdata/children_relative_low_income_ltla_14-22.csv") |>
  clean_names() |>
  select(
    ltla21_name = year,
    children_low_income_abs_fye15 = x2014_15,
    children_low_income_abs_fye16 = x2015_16,
    children_low_income_abs_fye17 = x2016_17,
    children_low_income_abs_fye18 = x2017_18,
    children_low_income_abs_fye19 = x2018_19,
    children_low_income_abs_fye20 = x2019_20,
    children_low_income_abs_fye21 = x2020_21,
    children_low_income_abs_fye22 = x2021_22_p
  ) |>
  filter(!ltla21_name %in% c("National - Regional - LA - OAs", "Unknown", "Total")) |>
  mutate(ltla21_name = str_remove(ltla21_name, "\\s*/\\s*.*$")) |>
  left_join(ltla21) |>
  relocate(ltla21_code, .after = ltla21_name)

# Final dataset: 2015-2020
children_low_income_ltla <- children_low_income_ltla_wide |>
  pivot_longer(
    cols = starts_with("children_low_income_abs_fye"),
    names_to = "year",
    values_to = "children_low_income_abs"
  ) |>
  mutate(
    year = as.numeric(paste0("20", str_extract(year, "\\d+"))),
    children_low_income_abs = as.numeric(children_low_income_abs)
  ) |> 
  left_join(population_0_16) |> 
  mutate(children_low_income_perc = (children_low_income_abs / population_0_16) * 100) |> 
  filter(!is.na(children_low_income_perc),
         between(year, 2015, 2020))

# ---- Checks ----
# We exclude Northern Ireland
ltla21_noNI <- ltla21 |> 
  filter(!str_starts(ltla21_code, "N"))

# Step 1: Checking completeness of local authorities
# Checking for local authorities in children_low_income_ltla that are not in ltla21_noNI
unmatched_in_children <- anti_join(children_low_income_ltla, ltla21_noNI, by = "ltla21_code")

if(nrow(unmatched_in_children) > 0) {
  print("Local authorities in the children low income dataset not found in ltla21_noNI:")
  print(unmatched_in_children)
} else {
  print("All local authorities in the children low income dataset match those in ltla21_noNI.")
}

# Checking for local authorities in ltla21_noNI that are not in children_low_income_ltla
# (= missing data)
unmatched_in_ltla21_noNI <- anti_join(ltla21_noNI, children_low_income_ltla, by = "ltla21_code")

if(nrow(unmatched_in_ltla21_noNI) > 0) {
  print("Local authorities in ltla21_noNI not found in the children low income dataset:")
  print(unmatched_in_ltla21_noNI)
} else {
  print("All local authorities in ltla21_noNI are represented in the children low income dataset.")
}

# RESULT: Only Northern Ireland missing

# Step 2: Ensuring there is data for all years 2015-2020 for each local authority
year_coverage <- children_low_income_ltla |> 
  group_by(ltla21_code) |>
  summarize(years_count = n_distinct(year)) |>
  filter(years_count != 6)  # Filter out those with complete data for all 6 years

# Output the results with a message
if(nrow(year_coverage) > 0) {
  print("Local authorities with incomplete data across the years 2015 to 2020:")
  print(year_coverage)
} else {
  print("All local authorities have complete data for each year from 2015 to 2020.")
}

# RESULT: Missing years of data for 4 Scottish LA's (new)

# ---- Save dataset ----
usethis::use_data(children_low_income_ltla, overwrite = TRUE)
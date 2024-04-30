# ---- FINAL DATASETS FOR THE MODELS ----
# ---- Setup ----
# devtools::load_all(".")
library(tidyverse)
library(geographr)
library(lubridate)

ltla21_noNI <- geographr::boundaries_ltla21 |>
  st_drop_geometry() |> 
  filter(!str_starts(ltla21_code, "N"))

# ---- Dataset for Part 1 (Baseline model with unemployment control) ----
data("children_low_income_ltla")
data("UC_households_ltla")
data("unemployment_ltla")

dataset_part1 <- UC_households_ltla |>
  left_join(children_low_income_ltla) |>
  left_join(unemployment_ltla) |> 
  select(ltla21_code, ltla21_name, year, UC_households_perc, children_low_income_perc, unemployment_perc) |> 
  filter(!is.na(UC_households_perc) & !is.na(children_low_income_perc) & !is.na(unemployment_perc)) |> 
  filter(between(year, 2016, 2020))

# Save dataset
usethis::use_data(dataset_part1, overwrite = TRUE)

# ---- Dataset for Part 2 (Adding number of years UC has been active) ----
data("uc_first_active_month")

# Join the first active date with main dataset & calculate number of months UC 
# has been active by the end of each year
dataset_part2 <- dataset_part1 |> 
  left_join(uc_first_active_month, by = "ltla21_code") |> 
  mutate(
    months_active = ifelse(
      year >= year(first_active_date),
      ((year - year(first_active_date)) * 12) + (12 - month(first_active_date) + 1),
      0),
    years_active = ifelse(
      year >= year(first_active_date),
      year - year(first_active_date),
      0)
  ) |> 
  select(-first_active_date)

# Save dataset
usethis::use_data(dataset_part2, overwrite = TRUE)

# ---- Dataset for Part 3 (Adding proportion of lone parents households) ----
data("lone_parent_households_ltla")

dataset_part3 <- dataset_part1 |> 
  filter(year < 2020) |> 
  left_join(lone_parent_households_ltla) |> 
  select(-lone_parent_households_abs, -households_number)

# Save dataset
usethis::use_data(dataset_part3, overwrite = TRUE)

# ---- Pre-treatment dataset ----
pre_treatment_df <- children_low_income_ltla |> 
  full_join(lone_parent_households_ltla) |> 
  full_join(unemployment_ltla) |> 
  left_join(uc_first_active_month) |> 
  select(ltla21_name, ltla21_code, year, 
         children_low_income_perc, 
         households_number, lone_parent_households_perc,
         unemployment_perc, first_active_date) |> 
  filter(!is.na(children_low_income_perc)) |> 
  filter(year == 2015) |> 
  mutate(
    first_active_quarter = if_else(
      !is.na(first_active_date),
      factor(paste0(year(first_active_date), " Q", quarter(first_active_date))),
      NA
    )
  )

# Save dataset
usethis::use_data(pre_treatment_df, overwrite = TRUE)

# ---- CHECKS ----
# ---- Dataset Model 1 ----
# Checks 
# Step 1: Checking completeness of local authorities
unmatched_in_df1 <- anti_join(dataset_part1, ltla21_noNI, by = "ltla21_code")

if(nrow(unmatched_in_df1) > 0) {
  print("Local authorities in the dataset not found in ltla21_noNI:")
  print(unmatched_in_df1)
} else {
  print("All local authorities in the dataset match those in ltla21_noNI.")
}

# Checking for local authorities in ltla21_noNI that are not in dataset 1
# (= missing data)
unmatched_in_ltla21 <- anti_join(ltla21_noNI, dataset_part1, by = "ltla21_code")

if(nrow(unmatched_in_ltla21) > 0) {
  print("Local authorities in ltla21_noNI not found in the dataset:")
  print(unmatched_in_ltla21, n = 100)
} else {
  print("All local authorities in ltla21_noNI are represented in the dataset.")
}

# RESULT: 21 English + 2 Scottish local authorities missing from the dataset

# Step 2: Ensuring there is data for all years 2016-2020 for each local authority
year_coverage <- dataset_part1 |> 
  group_by(ltla21_code) |>
  summarize(years_count = n_distinct(year)) |>
  filter(years_count != 5)  # Filter out those with complete data for all 5 years

# Output the results with a message
if(nrow(year_coverage) > 0) {
  print("Local authorities with incomplete data across the years 2016 to 2020:")
  print(year_coverage)
} else {
  print("All local authorities have complete data for each year from 2016 to 2020.")
}

# RESULT: Missing years for 2 Scottish local authorities
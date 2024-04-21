# ---- HOUSEHOLDS ON UNIVERSAL CREDIT - LOCAL AUTHORITIES ----
# NOTE 1: From April 2020, Changes to Universal Credit in response to the pandemic
# For more details, check: https://www.gov.uk/government/publications/universal-credit-statistics-background-information-and-methodology/universal-credit-statistics-background-information-and-methodology

# NOTE 2: Nortern Ireland is not included because there is no available data for 
# its number of households on Universal Credit from Stat-Xplpre

# NOTE 3: Local authorities (called ltla for Lower Tier Local Authorities) - 363
# - England: English local authority districts (309)
# - Wales: Unitary authorities (22)
# - Scotland: Scottish council areas (32)

# ---- Setup ----
library(tidyverse)
library(janitor)
library(geographr)
library(sf)
library(readxl)
library(httr2)

ltla21_noNI <- geographr::boundaries_ltla21 |>
  st_drop_geometry() |> 
  filter(!str_starts(ltla21_code, "N"))

data("households_number_ltla")

# ---- UC Households - Local Authorities  ----
# Source: Department of Work and Pensions (DWP)
# Stat-Xplore - Universal Credit > Households on Universal Credit
# Geography (residence-based) - GB > Local Authority
UC_households_ltla_wide <- read_csv("inst/extdata/households_on_UC_ltla_15-22.csv") |> 
  clean_names() |> 
  select(-matches("_annotations"), -x182) |> 
  rename(ltla21_name = month) |> 
  filter(!ltla21_name %in% c("National - Regional - LA - OAs", "Unknown", "Total")) |> 
  mutate(ltla21_name = str_remove(ltla21_name, "\\s*/\\s*.*$")) |> 
  mutate_at(vars(-ltla21_name), ~as.numeric(ifelse(. == "..", 0, .))) |> 
  left_join(ltla21_noNI) |>
  relocate(ltla21_code, .before = ltla21_name)

# Financial Year ends on April 5th of each year: we use the number of 
# households on Universal Credit in March of each year for annual data
UC_households_ltla <- UC_households_ltla_wide |> 
  select(ltla21_name, ltla21_code, matches("march_")) |> 
  rename(march_2022 = march_2022_r) |> 
  pivot_longer(cols = starts_with("march_"),
               names_to = "year",
               values_to = "UC_households_abs") |> 
  mutate(year = as.numeric(gsub("march_", "", year))) |> 
  left_join(households_number_ltla) |> 
  mutate(UC_households_perc = (UC_households_abs / household_number)*100) |> 
  filter(between(year, 2016, 2020))

# ---- Checks ----
# Step 1: Checking completeness of local authorities
# Checking for local authorities in UC_households_ltla that are not in ltla21_noNI
unmatched_in_UC_households <- anti_join(UC_households_ltla, ltla21_noNI, by = "ltla21_code")

if(nrow(unmatched_in_UC_households) > 0) {
  print("Local authorities in the UC households dataset not found in ltla21_noNI:")
  print(unmatched_in_UC_households)
} else {
  print("All local authorities in the UC households dataset match those in ltla21_noNI.")
}

# RESULT: 4 English local authorities missing from the ltla21_noNI dataset

# Checking for local authorities in ltla21_noNI that are not in UC_households_ltla
# (= missing data)
unmatched_in_ltla21 <- anti_join(ltla21_noNI, UC_households_ltla, by = "ltla21_code")

if(nrow(unmatched_in_ltla21) > 0) {
  print("Local authorities in ltla21_noNI not found in the UC households dataset:")
  print(unmatched_in_ltla21)
} else {
  print("All local authorities in ltla21_noNI are represented in the UC households dataset.")
}

# RESULT: 17 English local authorities missing from the UC households dataset

# Step 2: Ensuring there is data for all years 2016-2020 for each local authority
year_coverage <- UC_households_ltla |> 
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

# RESULT: All good

# ---- Save dataset ----
usethis::use_data(UC_households_ltla, overwrite = TRUE)

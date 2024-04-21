# ---- TIME-VARYING CONTROLS - LOCAL AUTHORITIES LEVEL ----
# NOTE: Nortern Ireland is not included because there is no available data for 
# its number of households on Universal Credit from Stat-Xplpre

# NOTE 2: Local authorities (called ltla for Lower Tier Local Authorities) - 363
# - England: English local authority districts (309)
# - Wales: Unitary authorities (22)
# - Scotland: Scottish council areas (32)

# ---- Setup ----
# devtools::load_all(".")
library(tidyverse)
library(httr2)
library(janitor)
library(geographr)
library(sf)
library(readxl)

ltla21_noNI <- geographr::boundaries_ltla21 |>
  st_drop_geometry() |> 
  filter(!str_starts(ltla21_code, "N"))

# ---- MODEL-BASED UNEMPLOYMENT RATES ----
# Source: Office for National Statistics
# https://www.ons.gov.uk/employmentandlabourmarket/peoplenotinwork/unemployment/datasets/modelledunemploymentforlocalandunitaryauthoritiesm01/current

url <- "https://www.ons.gov.uk/file?uri=/employmentandlabourmarket/peoplenotinwork/unemployment/datasets/modelledunemploymentforlocalandunitaryauthoritiesm01/current/modelbasedunemploymentdataaugust2022.xls"
download <- tempfile(fileext = ".xls")

request(url) |>
  req_progress() |>
  req_perform(download)

unemployment_raw <- read_excel(
  download,
  sheet = "LA,UA Rates",
  range = "A3:IB378") |>
  clean_names()

unemployment_ltla_wide <- unemployment_raw |> 
  select(ltla21_name = "ualad",
         unemployment_2015 = "apr_2014_to_mar_2015",
         unemployment_2016 = "apr_2015_to_mar_2016",
         unemployment_2017 = "apr_2016_to_mar_2017",
         unemployment_2018 = "apr_2017_to_mar_2018",
         unemployment_2019 = "apr_2018_to_mar_2019",
         unemployment_2020 = "apr_2019_to_mar_2020",
         unemployment_2021 = "apr_2020_to_mar_2021",
         unemployment_2022 = "apr_2021_to_mar_2022") |> 
  filter(!is.na(ltla21_name)) |> 
  left_join(ltla21_noNI) |> 
  relocate(ltla21_code, .after = ltla21_name)

# Create long dataset
unemployment_ltla <- unemployment_ltla_wide |>
  filter(!is.na(unemployment_2016)) |>
  pivot_longer(
    cols = starts_with("unemployment"),
    names_to = "year",
    values_to = "unemployment_perc"
  ) |>
  mutate(year = as.numeric(str_extract(year, "\\d{4}")),
         unemployment_perc = round(as.numeric(unemployment_perc), 2)) |> 
  filter(between(year, 2016, 2020))

# ---- Checks ----
# Step 1: Checking completeness of local authorities
# Checking for local authorities in unemployment_ltla that are not in ltla21_noNI
unmatched_in_unemployment <- anti_join(unemployment_ltla, ltla21_noNI, by = "ltla21_code")

if(nrow(unmatched_in_unemployment) > 0) {
  print("Local authorities in the unemployment dataset not found in ltla21_noNI:")
  print(unique(unmatched_in_unemployment$ltla21_name))
} else {
  print("All local authorities in the unemployment dataset match those in ltla21_noNI.")
}

# Checking for local authorities in ltla21_noNI that are not in unemployment
# (= missing data)
unmatched_in_ltla21_noNI <- anti_join(ltla21_noNI, unemployment_ltla, by = "ltla21_code")

if(nrow(unmatched_in_ltla21_noNI) > 0) {
  print("Local authorities in ltla21_noNI not found in the unemployment dataset:")
  print(unmatched_in_ltla21_noNI)
} else {
  print("All local authorities in ltla21_noNI are represented in the unemployment dataset.")
}

# RESULT: 4 Local Authorities missing: Isles of Scilly, North Northamptonshire, West Northamptonshire, City of London

# Step 2: Ensuring there is data for all years 2016-2020 for each local authority
year_coverage <- unemployment_ltla |> 
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
use_data(unemployment_ltla, overwrite = TRUE)

# ---- PROPORTION OF LONE PARENT HOUSEHOLDS (2004-2019) ----
# Get number of households from package
data("households_number_ltla")

# Source: Office for National Statistics
# 2004 - 2019: https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019
url_04_19 <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019/aps2004to2019finalv2.xlsx"

download_04_19 <- tempfile(fileext = ".xlsx")

request(url_04_19) |>
  req_progress() |> 
  req_perform(download_04_19)

lone_parent_households_ltla <- read_excel(
  download_04_19,
  sheet = "Lone_parent_households",
  range = "A11:T381") |> 
  clean_names()|> 
  select(-country, -area_type) |> 
  rename(ltla21_code = area_code, ltla21_name = area_name_note_3) |> 
  pivot_longer(cols = -ltla21_code, 
               names_to = "year", 
               values_to = "lone_parent_households_abs") |> 
  mutate(year = as.numeric(gsub("x(\\d{4})_note_\\d+", "\\1", year))) |> 
  filter(year >= 2016) |> 
  mutate(lone_parent_households_abs = as.numeric(lone_parent_households_abs)) |> 
  left_join(households_number_ltla) |> 
  mutate(lone_parent_households_perc = lone_parent_households_abs / households_number * 100) |> 
  left_join(ltla21_noNI) |>
  relocate(ltla21_name, .before = ltla21_code) |> 
  filter(!is.na(lone_parent_households_perc))

# ---- Checks ----
# Step 1: Checking completeness of local authorities
# Checking for local authorities in lone_parent_households_ltla that are not in ltla21_noNI
unmatched_in_lone_parent_households <- anti_join(lone_parent_households_ltla, ltla21_noNI, by = "ltla21_code")

if(nrow(unmatched_in_lone_parent_households) > 0) {
  print("Local authorities in the lone parents dataset not found in ltla21_noNI:")
  print(unique(unmatched_in_lone_parent_households$ltla21_code))
} else {
  print("All local authorities in the lone parents dataset match those in ltla21_noNI.")
}

# RESULT: 11 English and 2 Scottish local authorities not in ltla21_noNI

# Checking for local authorities in ltla21_noNI that are not in lone_parent_households
# (= missing data)
unmatched_in_ltla21_noNI <- anti_join(ltla21_noNI, lone_parent_households_ltla, by = "ltla21_code")

if(nrow(unmatched_in_ltla21_noNI) > 0) {
  print("Local authorities in ltla21_noNI not found in the lone parents dataset:")
  print(unmatched_in_ltla21_noNI)
} else {
  print("All local authorities in ltla21_noNI are represented in the lone parents dataset.")
}

# RESULT: 6 Local Authorities missing

# Step 2: Ensuring there is data for all years 2016-2019 for each local authority
year_coverage <- lone_parent_households_ltla |> 
  group_by(ltla21_code) |>
  summarize(years_count = n_distinct(year)) |>
  filter(years_count != 4)  # Filter out those with complete data for all 4 years

# Output the results with a message
if(nrow(year_coverage) > 0) {
  print("Local authorities with incomplete data across the years 2016 to 2019:")
  print(year_coverage)
} else {
  print("All local authorities have complete data for each year from 2016 to 2019.")
}

# RESULT: 15 local authorities wih missing years

# ---- Save dataset ----
usethis::use_data(lone_parent_households_ltla, overwrite = TRUE)
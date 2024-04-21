# ---- NUMBER OF HOUSEHOLDS - LOCAL AUTHORITIES ----
# NOTE: Nortern Ireland is not included because there is no available data for 
# its number of households on Universal Credit from Stat-Xplpre

# NOTE 2: Local authorities (called ltla for Lower Tier Local Authorities) - 363
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

# ---- Number of households ----
# Source: Office for National Statistics
# 2004 - 2019: https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019
# 2020: https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/14432estimatednumberofhouseholdsingreatbritaininnuts1nuts3englishandwelshlocalauthoritiesandscottishcouncilareas2020
url_04_19 <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019/aps2004to2019finalv2.xlsx"
url_20 <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/14432estimatednumberofhouseholdsingreatbritaininnuts1nuts3englishandwelshlocalauthoritiesandscottishcouncilareas2020/hhbylanuts1nuts32020final.xlsx"

download_04_19 <- tempfile(fileext = ".xlsx")
download_20 <- tempfile(fileext = ".xlsx")

request(url_04_19) |>
  req_progress() |> 
  req_perform(download_04_19)

request(url_20) |>
  req_progress() |> 
  req_perform(download_20)

households_number_ltla_04_19_raw <- read_excel(
  download_04_19,
  sheet = "Total_households",
  range = "A11:T381"
) |> 
  clean_names()

households_number_ltla_20_raw <- read_excel(
  download_20,
  sheet = "DATA",
  range = "A6:C373"
) |> 
  clean_names() |> 
  select(ltla21_code = la_code,
         x2020_note_1 = estimated_number_of_private_households_2020)

households_number_ltla <- households_number_ltla_04_19_raw |> 
  select(-country, -area_name_note_3, -area_type) |> 
  rename(ltla21_code = area_code) |> 
  left_join(households_number_ltla_20_raw) |> 
  pivot_longer(cols = -ltla21_code, 
               names_to = "year", 
               values_to = "households_number") |> 
  mutate(year = as.numeric(gsub("x(\\d{4})_note_\\d+", "\\1", year))) |> 
  filter(between(year, 2016, 2020))

# ---- Checks ----
# Step 1: Checking completeness of local authorities
# Checking for local authorities in households_number_ltla that are not in ltla21_noNI
unmatched_in_households_number <- anti_join(households_number_ltla, ltla21_noNI, by = "ltla21_code")

if(nrow(unmatched_in_households_number) > 0) {
  print("Local authorities in the households number dataset not found in ltla21_noNI:")
  print(unique(unmatched_in_households_number$ltla21_code))
} else {
  print("All local authorities in the households number dataset match those in ltla21_noNI.")
}

# RESULT: 11 English and 2 Scottish local authorities not in ltla21_noNI

# Checking for local authorities in ltla21_noNI that are not in households_number
# (= missing data)
unmatched_in_ltla21_noNI <- anti_join(ltla21_noNI, households_number_ltla, by = "ltla21_code")

if(nrow(unmatched_in_ltla21_noNI) > 0) {
  print("Local authorities in ltla21_noNI not found in the households number dataset:")
  print(unmatched_in_ltla21_noNI)
} else {
  print("All local authorities in ltla21_noNI are represented in the households number dataset.")
}

# RESULT: 6 Local Authorities missing

# Step 2: Ensuring there is data for all years 2016-2020 for each local authority
year_coverage <- households_number_ltla |> 
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
usethis::use_data(households_number_ltla, overwrite = TRUE)

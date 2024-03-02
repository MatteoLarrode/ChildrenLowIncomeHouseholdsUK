# ---- HOUSEHOLDS ON UNIVERSAL CREDIT - LOCAL AUTHORITIES ----
# NOTE: From April 2020, Changes to Universal Credit in response to the pandemic
# For more details, check: https://www.gov.uk/government/publications/universal-credit-statistics-background-information-and-methodology/universal-credit-statistics-background-information-and-methodology
# ---- Setup ----
library(tidyverse)
library(janitor)
library(geographr)
library(sf)
library(readxl)
library(imputeTS)

ltla21 <- geographr::boundaries_ltla21 |> 
  st_drop_geometry() |> 
  filter(!grepl("^N", ltla21_code))

# ---- Number of households ----
# Source: Office for National Statistics
# 2004 - 2019: https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019
# 2020: https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/14432estimatednumberofhouseholdsingreatbritaininnuts1nuts3englishandwelshlocalauthoritiesandscottishcouncilareas2020
url_04_19 <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019/aps2004to2019finalv2.xlsx"
url_20 <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/14432estimatednumberofhouseholdsingreatbritaininnuts1nuts3englishandwelshlocalauthoritiesandscottishcouncilareas2020/hhbylanuts1nuts32020final.xlsx"
url_21 <- "https://static.ons.gov.uk/datasets/dd43cf6b-78a2-443e-b2a1-e7e2efdc0028/TS041-2021-3-filtered-2024-03-02T19:45:27Z.xlsx#get-data"

download_04_19 <- tempfile(fileext = ".xlsx")
download_20 <- tempfile(fileext = ".xlsx")
download_21 <- tempfile(fileext = ".xlsx")

request(url_04_19) |>
  req_progress() |> 
  req_perform(download_04_19)

request(url_20) |>
  req_progress() |> 
  req_perform(download_20)

request(url_21) |>
  req_progress() |> 
  req_perform(download_21)

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

households_number_ltla_21_raw <- read_excel(
  download_21,
  sheet = "Dataset",
  range = "A1:C332"
  ) |> 
  clean_names() |> 
  select(ltla21_code = lower_tier_local_authorities_code,
         x2021_note_1 = observation)

# For missing household number data (2022 and Scotland 2021): imputation by 
# simple moving average
households_number_ltla <- households_number_ltla_04_19_raw |> 
  select(-country, -area_name_note_3, -area_type) |> 
  rename(ltla21_code = area_code) |> 
  left_join(households_number_ltla_20_raw) |> 
  left_join(households_number_ltla_21_raw) |> 
  pivot_longer(cols = -ltla21_code, 
               names_to = "year", 
               values_to = "household_number") |> 
  mutate(year = as.numeric(gsub("x(\\d{4})_note_\\d+", "\\1", year))) |> 
  complete(ltla21_code, year = seq(min(year), 2022)) |>
  group_by(ltla21_code) |> 
  mutate(household_number = na_ma(household_number)) |> 
  ungroup()

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
  left_join(ltla21) |>
  relocate(ltla21_code, .after = ltla21_name) |> 
  filter(!is.na(ltla21_code))

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
  mutate(UC_households_perc = (UC_households_abs / household_number)*100)

usethis::use_data(UC_households_ltla, overwrite = TRUE)
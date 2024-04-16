# ---- TIME-VARYING CONTROLS - LOCAL AUTHORITIES LEVEL ----
# ---- Setup ----
# devtools::load_all(".")
library(tidyverse)
library(httr2)
library(janitor)
library(geographr)
library(sf)
library(readxl)

ltla21 <- geographr::boundaries_ltla21 |>
  st_drop_geometry() |> 
  filter(!str_starts(ltla21_code, "N"))

# ---- Model-based unemployment rates ----
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
  left_join(ltla21) |> 
  relocate(ltla21_code, .after = ltla21_name) |> 
  filter(!is.na(ltla21_name))

# Check if LA codes match & missing data
ltla21_test <- ltla21 |> 
  full_join(unemployment_ltla_wide)

# Missing data:
  # Irrelevant: 
    # - Isles of Scilly (same for main variables)
    # - Buckinghamshire, North Northamptonshire & West Northamptonshire 
      # (same for main variables b/c due to boundary changes)
  # Relevant:
      # - No data for City of London

# Create long dataset
unemployment_ltla <- unemployment_ltla_wide |>
  filter(!is.na(unemployment_2016)) |>
  pivot_longer(
    cols = starts_with("unemployment"),
    names_to = "year",
    values_to = "unemployment_perc"
  ) |>
  mutate(year = as.numeric(str_extract(year, "\\d{4}")),
         unemployment_perc = round(as.numeric(unemployment_perc), 2))

# ---- Save dataset ----
use_data(unemployment_ltla, overwrite = TRUE)

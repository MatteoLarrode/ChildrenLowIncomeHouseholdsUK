# ---- CHILDREN IN RELATIVE LOW INCOME HOUSEHOLDS - LOCAL AUTHORITIES ----
# NOTE: Local authorities (called ltla for Lower Tier Local Authorities) - 374
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
# For age filtering, Children in Low Income Households dataset considers 0-19
# England - Source: Office for National Statistics
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

# Final children population dataset (and impute for Scotland 2022)
population_0_16 <- rbind(children_pop_eng_wales, children_pop_scot) |> 
  complete(ltla21_code, year, fill = list(population_0_16 = NA)) |> 
  group_by(ltla21_code) |> 
  mutate(population_0_16 = na_ma(population_0_16)) |> 
  ungroup()
  
# ---- Children in relative low income households - Local Authorities ----
# Source: Department of Work and Pensions (DWP)
# Stat-Xplore - Children in Low Income Families > Relative Low Income
# Geography (residence-based) - UK > Local Authority
children_low_income_ltla_wide <- read_csv("inst/extdata/children_relative_low_income_ltla_14-22.csv") |>
  clean_names() |>
  select(
    ltla21_name = year,
    children_low_income_hh_abs_fye15 = x2014_15,
    children_low_income_hh_abs_fye16 = x2015_16,
    children_low_income_hh_abs_fye17 = x2016_17,
    children_low_income_hh_abs_fye18 = x2017_18,
    children_low_income_hh_abs_fye19 = x2018_19,
    children_low_income_hh_abs_fye20 = x2019_20,
    children_low_income_hh_abs_fye21 = x2020_21,
    children_low_income_hh_abs_fye22 = x2021_22_p
  ) |>
  filter(!ltla21_name %in% c("National - Regional - LA - OAs", "Unknown", "Total")) |>
  mutate(ltla21_name = str_remove(ltla21_name, "\\s*/\\s*.*$")) |>
  left_join(ltla21) |>
  relocate(ltla21_code, .after = ltla21_name)

children_low_income_ltla <- children_low_income_ltla_wide |>
  pivot_longer(
    cols = starts_with("children_low_income_hh_abs_fye"),
    names_to = "year",
    values_to = "children_low_income_hh_abs"
  ) |>
  mutate(
    year = as.numeric(paste0("20", str_extract(year, "\\d+"))),
    children_low_income_hh_abs = as.numeric(children_low_income_hh_abs)
  ) |> 
  left_join(population_0_16) |> 
  mutate(children_low_income_hh_perc = (children_low_income_hh_abs / population_0_16) * 100)

usethis::use_data(children_low_income_ltla, overwrite = TRUE)

# ---- ARCHIVED CODE ----
# Download data
# Source: https://www.gov.uk/government/collections/children-in-low-income-families-local-area-statistics
# url <- "https://assets.publishing.service.gov.uk/media/641c5cdb5155a200136ad550/children-in-low-income-families-local-area-statistics-2014-to-2022.ods"
# 
# download <- tempfile(fileext = ".ods")
# 
# request(url) |>
#   req_progress() |>
#   req_perform(download)
# 
# children_rel_low_income_ltla_raw <-
#   read_ods(
#     download,
#     sheet = "3_Relative_Local_Authority",
#     range = "A10:R385"
#   ) |>
#   clean_names()
# 
# # Clean data
# children_rel_low_income_ltla <- children_rel_low_income_ltla_raw |>
#   # select only percentages of children living in low income families
#   select(
#     ltla21_name = local_authority_note_2,
#     ltla21_code = area_code,
#     children_perc_fye15 = percentage_of_children_fye_2015_note_3,
#     children_perc_fye16 = percentage_of_children_fye_2016_note_3,
#     children_perc_fye17 = percentage_of_children_fye_2017_note_3,
#     children_perc_fye18 = percentage_of_children_fye_2018_note_3,
#     children_perc_fye19 = percentage_of_children_fye_2019_note_3,
#     children_perc_fye20 = percentage_of_children_fye_2020_note_3,
#     children_perc_fye21 = percentage_of_children_fye_2021_note_3,
#     children_perc_fye22 = percentage_of_children_fye_2022_p_note_3,
#   ) |>
#   filter(ltla21_code != "K02000001")

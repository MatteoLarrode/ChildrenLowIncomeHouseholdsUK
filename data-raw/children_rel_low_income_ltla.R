# ---- CHILDREN IN RELATIVE LOW INCOME HOUSEHOLDS - LOCAL AUTHORITIES ----
# ---- Setup ----
library(tidyverse)
library(httr2)
library(readODS)
library(janitor)
library(geographr)
library(sf)

ltla21 <- geographr::boundaries_ltla21 |> 
  st_drop_geometry()

# ---- Children in relative low income households - Local Authorities ----
# Source: Department of Work and Pensions (DWP)
# Stat-Xplore - Children in Low Income Families > Relative Low Income
# Geography (residence-based) - UK > Local Authority
children_low_income_ltla_wide <- read_csv("inst/extdata/children_relative_low_income_ltla_14-22.csv") |> 
  clean_names() |> 
  select(ltla21_name = year,
         children_low_income_hh_nbr_fye15 = x2014_15,
         children_low_income_hh_nbr_fye16 = x2015_16,
         children_low_income_hh_nbr_fye17 = x2016_17, 
         children_low_income_hh_nbr_fye18 = x2017_18,
         children_low_income_hh_nbr_fye19 = x2018_19, 
         children_low_income_hh_nbr_fye20 = x2019_20,
         children_low_income_hh_nbr_fye21 = x2020_21, 
         children_low_income_hh_nbr_fye22 = x2021_22_p) |> 
  filter(!ltla21_name %in% c("National - Regional - LA - OAs", "Unknown", "Total")) |> 
  mutate(ltla21_name = str_remove(ltla21_name, "\\s*/\\s*.*$")) |> 
  left_join(ltla21) |> 
  relocate(ltla21_code, .after = ltla21_name)

children_low_income_ltla <- children_low_income_ltla_wide |> 
  pivot_longer(cols = starts_with("children_low_income_hh_nbr_fye"), 
               names_to = "year", 
               values_to = "children_low_income_hh_nbr") |> 
  mutate(year = as.numeric(paste0("20", str_extract(year, "\\d+"))),
         children_low_income_hh_nbr = as.numeric(children_low_income_hh_nbr))
  
use_data(children_low_income_ltla, overwrite = TRUE)

# ---- ARCHIVED CODE ----
# ---- Download data ----
# Source: https://www.gov.uk/government/collections/children-in-low-income-families-local-area-statistics
url <- "https://assets.publishing.service.gov.uk/media/641c5cdb5155a200136ad550/children-in-low-income-families-local-area-statistics-2014-to-2022.ods"

download <- tempfile(fileext = ".ods")

request(url) |>
  req_progress() |> 
  req_perform(download)

children_rel_low_income_ltla_raw <-
  read_ods(
    download,
    sheet = "3_Relative_Local_Authority",
    range = "A10:R385"
  ) |> 
  clean_names()

# ---- Clean data ----
children_rel_low_income_ltla <- children_rel_low_income_ltla_raw |> 
  # select only percentages of children living in low income families
  select(ltla21_name = local_authority_note_2,
         ltla21_code = area_code,
         children_perc_fye15 = percentage_of_children_fye_2015_note_3,
         children_perc_fye16 = percentage_of_children_fye_2016_note_3,
         children_perc_fye17 = percentage_of_children_fye_2017_note_3,
         children_perc_fye18 = percentage_of_children_fye_2018_note_3,
         children_perc_fye19 = percentage_of_children_fye_2019_note_3,
         children_perc_fye20 = percentage_of_children_fye_2020_note_3,
         children_perc_fye21 = percentage_of_children_fye_2021_note_3,
         children_perc_fye22 = percentage_of_children_fye_2022_p_note_3,
         ) |> 
  filter(ltla21_code != "K02000001")

usethis::use_data(children_rel_low_income_ltla, overwrite = TRUE)

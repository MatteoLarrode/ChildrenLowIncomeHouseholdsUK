# ---- CHILDREN IN RELATIVE LOW INCOME HOUSEHOLDS - MSOA ----
# ---- Setup ----
library(tidyverse)
library(httr2)
library(janitor)
library(geographr)
library(sf)

msoa21 <- geographr::boundaries_msoa21 |> 
  st_drop_geometry()

iz11 <- geographr::boundaries_iz11 |> 
  rename(msoa21_code = iz11_code,
         msoa21_name = iz11_name) |> 
  st_drop_geometry()

msoa <- rbind(msoa21, iz11)

# ---- MSOA ----
# Source: Department of Work and Pensions (DWP)
# Stat-Xplore - Children in Low Income Families > Relative Low Income
# Geography (residence-based) - GB > Middle Layer Super Output Area

# For England & Wales --> MSOA
# For Scotland --> Intermediate Data Zones
children_low_income_msoa_wide <- read_csv("inst/extdata/children_relative_low_income_msoa_14-22.csv") |> 
  clean_names() |> 
  select(msoa21_name = year,
         children_low_income_hh_nbr_fye15 = x2014_15,
         children_low_income_hh_nbr_fye16 = x2015_16,
         children_low_income_hh_nbr_fye17 = x2016_17, 
         children_low_income_hh_nbr_fye18 = x2017_18,
         children_low_income_hh_nbr_fye19 = x2018_19, 
         children_low_income_hh_nbr_fye20 = x2019_20,
         children_low_income_hh_nbr_fye21 = x2020_21, 
         children_low_income_hh_nbr_fye22 = x2021_22_p) |> 
  filter(!msoa21_name %in% c("National - Regional - LA - OAs (GB)", "Unknown", "Total")) |> 
  left_join(msoa21) |> 
  left_join(iz11, by = join_by(msoa21_name))


  mutate(ltla21_name = str_remove(ltla21_name, "\\s*/\\s*.*$")) |> 
  left_join(ltla21) |> 
  relocate(ltla21_code, .after = ltla21_name)


usethis::use_data(children_rel_low_income_msoa, overwrite = TRUE)
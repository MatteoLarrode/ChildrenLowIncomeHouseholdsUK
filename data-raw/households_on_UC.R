# ---- HOUSEHOLDS ON UNIVERSAL CREDIT ----
# ---- Setup ----
library(tidyverse)
library(janitor)
library(geographr)
library(sf)

ltla21 <- geographr::boundaries_ltla21 |> 
  st_drop_geometry() |> 
  filter(!grepl("^N", ltla21_code))

# ---- NUMBER OF HOUSEHOLDS ----
households_total_raw <- read_csv()

# ---- LOCAL AUTHORITIES ----
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
               values_to = "UC_households") |> 
  mutate(year = as.numeric(gsub("march_", "", year)))


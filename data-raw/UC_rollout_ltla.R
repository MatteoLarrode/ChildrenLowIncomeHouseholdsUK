# ---- UNIVERSAL CREDIT ROLLOUT IN LOCAL AUTHORITIES: INDEPENDENT VARIABLE ----
# ---- Setup ----
# devtools::load_all(".")
library(tidyverse)
library(janitor)
library(readxl)
library(geographr)
library(sf)

ltla <- geographr::boundaries_ltla21 |> 
  st_drop_geometry()

# ---- UC Rollout Binary Variable----
uc_rollout_raw <- read_excel("inst/extdata/ltla_UC_rollout.xlsx") |> 
  clean_names() |> 
  rename(ltla21_name = local_authority) |> 
  left_join(ltla)



usethis::use_data(UC_rollout_ltla, overwrite = TRUE)

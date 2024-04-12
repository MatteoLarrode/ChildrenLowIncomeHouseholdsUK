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
  mutate(
    ltla21_name = str_remove(ltla21_name, " City Council"),
    ltla21_name = str_remove(ltla21_name, " Council"),
    ltla21_name = str_remove(ltla21_name, " County"),
    ltla21_name = str_remove(ltla21_name, " Metropolitan"),
    ltla21_name = str_remove(ltla21_name, "London Borough of "),
    ltla21_name = str_remove(ltla21_name, "City of "),
    ltla21_name = str_remove(ltla21_name, " Borough"),
    ltla21_name = str_remove(ltla21_name, " District"),
    ltla21_name = str_replace(ltla21_name, "&", "and"),
    ltla21_name = str_replace(ltla21_name, "Bristol", "Bristol, City of"),
    ltla21_name = str_replace(ltla21_name, "Hull", "Kingston upon Hull, City of"),
    ltla21_name = str_replace(ltla21_name, "Glasgow", "Glasgow City"),
    ltla21_name = str_replace(ltla21_name, "Edinburgh", "City of Edinburgh"),
    ltla21_name = str_replace(ltla21_name, "Durham", "County Durham"),
    ltla21_name = str_replace(ltla21_name, "The Moray", "Moray"),
    ltla21_name = str_replace(ltla21_name, "Herefordshire, of", "Herefordshire, County of"),
  ) |>
  left_join(ltla) |>
  relocate(ltla21_code, .before = ltla21_name)

# Some Jobcenter Plus areas within the same Local Authorities have experienced
# the UC rollout at different months. I count the Local Authority as having been
# rolled out when the first of its JCP areas have been rolled out

# Function to set values to 1 after the first occurrence of 1 in a row
set_values_to_1 <- function(row) {
  first_one_index <- which(row == 1)[1]
  if (!is.na(first_one_index)) {
    row[(first_one_index + 1):length(row)] <- 1
  }
  return(row)
}

# Apply function rowise
uc_rollout_processed <- as.data.frame(t(apply(uc_rollout_raw, 1, set_values_to_1))) |> 
  select(-total_appearances)

# Outcome measured in financial year (April to March): Need to decide month threshold for rollout
# FYE 2018 (April 2017 - March 2018): when do I start considering UC was rolled out for this year?
# Try multiple options and see if results is dependent on it

# Option 1: UC must have been rolled out since previous December (3 months BEFORE start of the financial year)
uc_rollout_ltla_15mo_wide <- uc_rollout_processed |>
  mutate(
    # first rollout was November 2015, so no rollout for FYE 2015 and 2016
    uc_rolled_out_fy_2015 = 0,
    uc_rolled_out_fy_2016 = 0,
    uc_rolled_out_fy_2017 = if_else(december_2016 == 1, 1, 0),
    uc_rolled_out_fy_2018 = if_else(december_2017 == 1, 1, 0),
    uc_rolled_out_fy_2019 = if_else(december_2018 == 1, 1, 0),
    uc_rolled_out_fy_2020 = 1
  ) |>
  select(
    ltla21_code, ltla21_name,
    uc_rolled_out_fy_2015, uc_rolled_out_fy_2016,
    uc_rolled_out_fy_2017, uc_rolled_out_fy_2018,
    uc_rolled_out_fy_2019, uc_rolled_out_fy_2020
  )

uc_rollout_ltla_15mo <- uc_rollout_ltla_15mo_wide |> 
  pivot_longer(
    cols = starts_with("uc_rolled_out_fy_"),
    names_to = "year",
    values_to = "uc_rolled_out",
    names_prefix = "uc_rolled_out_fy_"
  ) |> 
  mutate(year = as.numeric(year))

# Option 2: UC must have been rolled out since April (start of financial year)
uc_rollout_ltla_12mo_wide <- uc_rollout_processed |>
  mutate(
    # Since the first rollout was in November 2015, there's no rollout considered for FYE 2015 and FYE 2016
    uc_rolled_out_fy_2015 = 0,
    uc_rolled_out_fy_2016 = 0,
    uc_rolled_out_fy_2017 = if_else(april_2016 == 1, 1, 0), # Checking April of the previous year
    uc_rolled_out_fy_2018 = if_else(april_2017 == 1, 1, 0),
    uc_rolled_out_fy_2019 = if_else(april_2018 == 1, 1, 0),
    uc_rolled_out_fy_2020 = 1
  ) |>
  select(
    ltla21_code, ltla21_name,
    uc_rolled_out_fy_2015, uc_rolled_out_fy_2016,
    uc_rolled_out_fy_2017, uc_rolled_out_fy_2018,
    uc_rolled_out_fy_2019, uc_rolled_out_fy_2020
  )

uc_rollout_ltla_12mo <- uc_rollout_ltla_12mo_wide |> 
  pivot_longer(
    cols = starts_with("uc_rolled_out_fy_"),
    names_to = "year",
    values_to = "uc_rolled_out",
    names_prefix = "uc_rolled_out_fy_"
  ) |> 
  mutate(year = as.numeric(year))

# Option 3: UC must have been rolled out since October (6 months into the financial year)
uc_rollout_ltla_6mo_wide <- uc_rollout_processed |>
  mutate(
    # Since the first rollout was in November 2015, there's no rollout considered for FYE 2015 and FYE 2016
    uc_rolled_out_fy_2015 = 0,
    uc_rolled_out_fy_2016 = 0,
    uc_rolled_out_fy_2017 = if_else(october_2016 == 1, 1, 0), # Checking October of the same financial year
    uc_rolled_out_fy_2018 = if_else(october_2017 == 1, 1, 0),
    uc_rolled_out_fy_2019 = if_else(october_2018 == 1, 1, 0),
    uc_rolled_out_fy_2020 = 1
  ) |>
  select(
    ltla21_code, ltla21_name,
    uc_rolled_out_fy_2015, uc_rolled_out_fy_2016,
    uc_rolled_out_fy_2017, uc_rolled_out_fy_2018,
    uc_rolled_out_fy_2019, uc_rolled_out_fy_2020
  )

uc_rollout_ltla_6mo <- uc_rollout_ltla_6mo_wide |> 
  pivot_longer(
    cols = starts_with("uc_rolled_out_fy_"),
    names_to = "year",
    values_to = "uc_rolled_out",
    names_prefix = "uc_rolled_out_fy_"
  ) |> 
  mutate(year = as.numeric(year))

# Save datasets
usethis::use_data(uc_rollout_ltla_15mo, overwrite = TRUE)
usethis::use_data(uc_rollout_ltla_12mo, overwrite = TRUE)
usethis::use_data(uc_rollout_ltla_6mo, overwrite = TRUE)

# ---- UC Rollout Number of Months ----
uc_active <- uc_rollout_processed |> 
  pivot_longer(cols = -c(ltla21_code, ltla21_name),
               names_to = "month_year", values_to = "uc_live") |> 
  mutate(date = as.Date(paste("01", str_to_title(month_year), sep="-"), format="%d-%B_%Y")) |> 
  filter(uc_live == 1)

# Finding the first month UC was active for each local authority
uc_first_active_month <- uc_active |> 
  group_by(ltla21_code) |> 
  summarise(first_active_date = min(date), .groups = 'drop')

# Save dataset
usethis::use_data(uc_first_active_month, overwrite = TRUE)



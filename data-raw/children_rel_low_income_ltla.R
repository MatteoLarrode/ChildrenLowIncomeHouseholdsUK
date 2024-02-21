# ---- Children in Relative Low Income Households - LA ----
library(tidyverse)
library(httr2)
library(readODS)
library(janitor)

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

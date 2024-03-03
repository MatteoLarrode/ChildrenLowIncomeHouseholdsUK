# ---- EXPLORATORY DATA ANALYSIS ----

# ---- Setup ----
# pkgload::load_all(".")
library(tidyverse)

# ---- I) Relationship between households on UC and children in low income households ----
# LTLAs in England, Wales and Scotland (UC data not available for Northern Ireland yet)
data("UC_households_ltla")
data("children_low_income_ltla")

UC_Children_df <- UC_households_ltla |>
  left_join(children_low_income_ltla) |>
  select(ltla21_code, ltla21_name, year, UC_households_perc, children_low_income_hh_perc)

# Scatterplot for 2017
UC_Children_2017_df <- UC_Children_df |>
  filter(year == 2017)

ggplot(
  UC_Children_2017_df, aes(x = UC_households_perc, y = children_low_income_hh_perc)
) +
  geom_point()

# Regression model
UC_Children_model <- lm(data = UC_Children_df, children_low_income_hh_perc ~ UC_households_perc)
summary(UC_Children_model)

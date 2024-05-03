# ===============================
# ---- FIXED EFFECTS MODELS -----
# ===============================
library(fixest)

# ---- Section 1: Continuous Independent Variable ----
# Model 1: Baseline
fe_model_baseline <-
  feols(
    data = dataset_part1,
    children_low_income_perc ~ UC_households_perc | ltla21_code + year,
    cluster = ~ltla21_code
  )

# Model 2: Including control
fe_model1 <-
  feols(
    data = dataset_part1,
    children_low_income_perc ~ UC_households_perc + unemployment_perc | ltla21_code + year,
    cluster = ~ltla21_code
  )

# --- Section 2: Interaction term for years of UC activity ----
# Model (Appendix):
fe_model2 <-
  feols(
    data = dataset_part2,
    children_low_income_perc ~
      UC_households_perc +
        years_active +
        UC_households_perc * years_active +
        unemployment_perc | ltla21_code + year,
    cluster = ~ltla21_code
  )

#  --- Section 3: Interaction term for lone parents ----
# Model 3: Baseline
fe_model_baseline2 <-
  feols(
    data = dataset_part3,
    children_low_income_perc ~
      UC_households_perc +
        lone_parent_households_perc +
        unemployment_perc | ltla21_code + year,
    cluster = ~ltla21_code
  )

# Model 4: Adding interaction term for the proportion of lone parents
fe_model3 <-
  feols(
    data = dataset_part3,
    children_low_income_perc ~
      UC_households_perc +
        lone_parent_households_perc +
        UC_households_perc * lone_parent_households_perc +
        unemployment_perc | ltla21_code + year,
    cluster = ~ltla21_code
  )

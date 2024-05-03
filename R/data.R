# ---- DOCUMENTATION OF THE DATASETS ----

#' Children Living in Low Income Families by Local Authority (2015-2020)
#'
#' This dataset provides annual data on the number and percentage of children living in low-income families
#' within each local authority in England, Scotland and Wales.
#'
#' @format A data frame with 2164 rows and 6 variables:
#' \describe{
#'   \item{ltla21_name}{\code{character} Local Authority (LTLA) name.}
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2015 corresponds to a April 2014-March 2015 data collection period.}
#'   \item{children_low_income_abs}{\code{double} Absolute number of children living in low-income families.}
#'   \item{population_0_16}{\code{double} Total population of children aged 0-16 years in the LTLA.}
#'   \item{children_low_income_perc}{\code{double} Percentage of children aged 0-16 living in low-income families in the LTLA.}
#' }
#'
#' @source “Children in relative low-income families' local area statistics (CiRLIF)” Stat-Xplore
#' @source https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales
#' @source https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/mid-year-population-estimates/population-estimates-time-series-data
#' @examples
#' data(children_low_income_ltla)
#' summary(children_low_income_ltla)
"children_low_income_ltla"

#' Number of Households by Local Authority (2015-2020)
#'
#' This dataset contains the annual number of households within each local authority in England, Wales and Scotland.
#'
#' @format A data frame with 2220 rows and 3 variables:
#' \describe{
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2015 corresponds to a April 2014-March 2015 data collection period.}
#'   \item{households_number}{\code{double} Number of households.}
#' }
#'
#' @source https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019
#' @source https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/14432estimatednumberofhouseholdsingreatbritaininnuts1nuts3englishandwelshlocalauthoritiesandscottishcouncilareas2020
#' @source description
#' @examples
#' data(households_number_ltla)
#' summary(households_number_ltla)
"households_number_ltla"

#' Lone Parent Households by Local Authority (2015-2019)
#'
#' This dataset provides annual data on the number and proportion of lone parent households within each
#' local authority in England, Wales and Scotkand.
#'
#' @format A data frame with 1826 rows and 6 variables:
#' \describe{
#'   \item{ltla21_name}{\code{character} Local Authority (LTLA) name.}
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2015 corresponds to a April 2014-March 2015 data collection period.}
#'   \item{lone_parent_households_abs}{\code{double} Absolute number of lone parent households.}
#'   \item{households_number}{\code{double} Total number of households in the LTLA.}
#'   \item{lone_parent_households_perc}{\code{double} Percentage of households that are lone parent households.}
#' }
#'
#' @source https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019
#' @examples
#' data(lone_parent_households_ltla)
#' summary(lone_parent_households_ltla)
"lone_parent_households_ltla"

#' Households Claiming Universal Credit by Local Authority (2016-2020)
#'
#' This dataset contains annual data on the number and proportion of households receiving Universal Credit (UC)
#' within each local authority in England, Scotland and Wales.
#' 
#' @format A data frame with 1750 rows and 6 variables:
#' \describe{
#'   \item{ltla21_name}{\code{character} Local Authority (LTLA) name.}
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2016 corresponds to a April 2015-March 2016 data collection period.}
#'   \item{UC_households_abs}{\code{double} Absolute number of households claiming Universal Credit.}
#'   \item{households_number}{\code{double} Total number of households in the LTLA.}
#'   \item{UC_households_perc}{\code{double} Percentage of households claiming Universal Credit in the LTLA.}
#' }
#'
#' @source “Households on Universal Credit” dataset from Stat-Xplore
#' @examples
#' data(UC_households_ltla)
#' summary(UC_households_ltla)
"UC_households_ltla"

#' Unemployment Rates by Local Authority (2015-2020)
#'
#' This dataset provides annual unemployment rates for each local authority in England, Scotland and Wales.
#'
#' @format A data frame with 2220 rows and 4 variables:
#' \describe{
#'   \item{ltla21_name}{\code{character} Local Authority (LTLA) name.}
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2015 corresponds to a April 2014-March 2015 data collection period.}
#'   \item{unemployment_perc}{\code{double} Unemployment rate in the local authority, expressed as a percentage.}
#' }
#'
#' @source https://www.ons.gov.uk/employmentandlabourmarket/peoplenotinwork/unemployment/datasets/modelledunemploymentforlocalandunitaryauthoritiesm01/current
#' @examples
#' data(unemployment_ltla)
#' summary(unemployment_ltla)
"unemployment_ltla"

#' First Active Month of Universal Credit by Local Authority
#'
#' This dataset records the month when Universal Credit was introduced
#' in each local authority in England, Scotland and Wales. This information is useful for tracking the
#' rollout of Universal Credit across the UK.
#'
#' @format A data frame with 358 rows and 2 variables:
#' \describe{
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{first_active_date}{\code{date} Month when Universal Credit first became active in the local authority.}
#' }
#'
#' @source https://assets.publishing.service.gov.uk/media/5ab507c8e5274a1aa2d414d1/universal-credit-transition-rollout-schedule.pdf
#' @examples
#' data(uc_first_active_month)
#' summary(uc_first_active_month)
"uc_first_active_month"

#' Pre-Treatment Data Frame for Local Authorities
#'
#' This dataset combines values for all variables used in the study for each local authority in England, Scotland and Wales
#' for the year 2015. It serves as a baseline for the evaluation of the impact of UC, which was introduced after this year.
#'
#' @format A data frame with 359 rows and 9 variables:
#' \describe{
#'   \item{ltla21_name}{\code{character} Local Authority (LTLA) name.}
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{year}{\code{double} Pre-treatment year: 2015 for all records.}
#'   \item{children_low_income_perc}{\code{double} Percentage of children living in low-income families.}
#'   \item{households_number}{\code{double} Total number of households in the local authority.}
#'   \item{lone_parent_households_perc}{\code{double} Percentage of households that are lone parent households.}
#'   \item{unemployment_perc}{\code{double} Unemployment rate in the local authority, expressed as a percentage.}
#'   \item{first_active_date}{\code{date} The date when Universal Credit first became active in the local authority.}
#'   \item{first_active_quarter}{\code{factor} The quarter when Universal Credit first became active in the local authority.}
#' }
#'
#' @examples
#' data(pre_treatment_df)
#' summary(pre_treatment_df)
"pre_treatment_df"

#' Dataset for Section 1 of the Quantitative Analysis
#'
#' This dataset, first part of a series used for modeling analyses, compiles key socio-economic indicators
#' for each local authority in England across the 2016-2020 period. It includes data on the percentage
#' of households receiving Universal Credit, child poverty rates, and unemployment rates.
#'
#' @format A data frame with 1691 rows and 6 variables:
#' \describe{
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{ltla21_name}{\code{character} Local Authority name.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2016 corresponds to a April 2015-March 2016 data collection period.}
#'   \item{UC_households_perc}{\code{double} Percentage of households receiving Universal Credit.}
#'   \item{children_low_income_perc}{\code{double} Percentage of children living in low-income families.}
#'   \item{unemployment_perc}{\code{double} Unemployment rate in the local authority, expressed as a percentage.}
#' }
#'
#' @examples
#' data(dataset_part1)
#' summary(dataset_part1)
"dataset_part1"

#' Dataset for Section 2 of the Quantitative Analysis
#'
#' This dataset, second part of a series used for modeling analyses, extends `dataset_part1` by adding information about the duration of Universal Credit 
#' activation within each local authority.
#'
#' @format A data frame with 1691 rows and 8 variables:
#' \describe{
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{ltla21_name}{\code{character} Local Authority name.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2016 corresponds to a April 2015-March 2016 data collection period.}
#'   \item{UC_households_perc}{\code{double} Percentage of households receiving Universal Credit.}
#'   \item{children_low_income_perc}{\code{double} Percentage of children living in low-income families.}
#'   \item{unemployment_perc}{\code{double} Unemployment rate in the local authority, expressed as a percentage.}
#'   \item{months_active}{\code{double} Number of months Universal Credit has been active in the local authority.}
#'   \item{years_active}{\code{double} Number of years Universal Credit has been active in the local authority.}
#' }
#'
#' @examples
#' data(dataset_part2)
#' summary(dataset_part2)
"dataset_part2"

#' Dataset for Section 3 of the Quantitative Analysis
#' 
#' This dataset, third part of a series used for modeling analyses, further extends the previous datasets by including
#' the percentage of lone parent households in local authorities. No data was available for 2020, so the dataset only
#' includes data over the 2016-2019 period. 
#' 
#' @format A data frame with 1352 rows and 7 variables:
#' \describe{
#'   \item{ltla21_code}{\code{character} Local Authority code.}
#'   \item{ltla21_name}{\code{character} Local Authority name.}
#'   \item{year}{\code{double} Financial year ending, e.g. 2016 corresponds to a April 2015-March 2016 data collection period.}
#'   \item{UC_households_perc}{\code{double} Percentage of households receiving Universal Credit.}
#'   \item{children_low_income_perc}{\code{double} Percentage of children living in low-income families.}
#'   \item{unemployment_perc}{\code{double} Unemployment rate in the local authority, expressed as a percentage.}
#'   \item{lone_parent_households_perc}{\code{double} Percentage of households that are lone parent households.}
#' }
#'
#' @examples
#' data(dataset_part3)
#' summary(dataset_part3)
"dataset_part3"
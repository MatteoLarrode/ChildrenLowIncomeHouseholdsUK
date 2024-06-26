% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{children_low_income_ltla}
\alias{children_low_income_ltla}
\title{Children Living in Low Income Families by Local Authority (2015-2020)}
\format{
A data frame with 2164 rows and 6 variables:
\describe{
\item{ltla21_name}{\code{character} Local Authority (LTLA) name.}
\item{ltla21_code}{\code{character} Local Authority code.}
\item{year}{\code{double} Financial year ending, e.g. 2015 corresponds to a April 2014-March 2015 data collection period.}
\item{children_low_income_abs}{\code{double} Absolute number of children living in low-income families.}
\item{population_0_16}{\code{double} Total population of children aged 0-16 years in the LTLA.}
\item{children_low_income_perc}{\code{double} Percentage of children aged 0-16 living in low-income families in the LTLA.}
}
}
\source{
“Children in relative low-income families' local area statistics (CiRLIF)” Stat-Xplore

https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales

https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/mid-year-population-estimates/population-estimates-time-series-data
}
\usage{
children_low_income_ltla
}
\description{
This dataset provides annual data on the number and percentage of children living in low-income families
within each local authority in England, Scotland and Wales.
}
\examples{
data(children_low_income_ltla)
summary(children_low_income_ltla)
}
\keyword{datasets}

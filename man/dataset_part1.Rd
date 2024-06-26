% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{dataset_part1}
\alias{dataset_part1}
\title{Dataset for Section 1 of the Quantitative Analysis}
\format{
A data frame with 1691 rows and 6 variables:
\describe{
\item{ltla21_code}{\code{character} Local Authority code.}
\item{ltla21_name}{\code{character} Local Authority name.}
\item{year}{\code{double} Financial year ending, e.g. 2016 corresponds to a April 2015-March 2016 data collection period.}
\item{UC_households_perc}{\code{double} Percentage of households receiving Universal Credit.}
\item{children_low_income_perc}{\code{double} Percentage of children living in low-income families.}
\item{unemployment_perc}{\code{double} Unemployment rate in the local authority, expressed as a percentage.}
}
}
\usage{
dataset_part1
}
\description{
This dataset, first part of a series used for modeling analyses, compiles key socio-economic indicators
for each local authority in England across the 2016-2020 period. It includes data on the percentage
of households receiving Universal Credit, child poverty rates, and unemployment rates.
}
\examples{
data(dataset_part1)
summary(dataset_part1)
}
\keyword{datasets}

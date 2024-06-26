% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{dataset_part3}
\alias{dataset_part3}
\title{Dataset for Section 3 of the Quantitative Analysis}
\format{
A data frame with 1352 rows and 7 variables:
\describe{
\item{ltla21_code}{\code{character} Local Authority code.}
\item{ltla21_name}{\code{character} Local Authority name.}
\item{year}{\code{double} Financial year ending, e.g. 2016 corresponds to a April 2015-March 2016 data collection period.}
\item{UC_households_perc}{\code{double} Percentage of households receiving Universal Credit.}
\item{children_low_income_perc}{\code{double} Percentage of children living in low-income families.}
\item{unemployment_perc}{\code{double} Unemployment rate in the local authority, expressed as a percentage.}
\item{lone_parent_households_perc}{\code{double} Percentage of households that are lone parent households.}
}
}
\usage{
dataset_part3
}
\description{
This dataset, third part of a series used for modeling analyses, further extends the previous datasets by including
the percentage of lone parent households in local authorities. No data was available for 2020, so the dataset only
includes data over the 2016-2019 period.
}
\examples{
data(dataset_part3)
summary(dataset_part3)
}
\keyword{datasets}

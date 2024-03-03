In this dissertation, I conduct a quantitative analysis of the effect of
UK welfare policy changes on the proportion of children living in
relative low-income households.

This Markdown includes the data analysis component of this dissertation.
It will first include some exploratory data analysis, and then will be
used to run the other components of the quantitative analysis of the
impact of UK benefit policies on the number of children living in
relative low income.

Note that the collection and cleaning of the data that will be used here
is done in scripts in the `data-raw` folder of this repository, and the
datasets are available in the `data` folder.

### Setup

    library(tidyverse)

    # pkgload::load_all(".")

## I) Relationship between households on UC and children in low income households

We start by examining the relationship between the rollout of Universal
Credit, more precisely the proportion of households on Universal Credit,
and the proportion of children living in low income household.

A little bit more information on the variables at hand now.

#### Households on Universal Credit

#### Children Living in Low Income Households

    data("UC_households_ltla")
    data("children_low_income_ltla")

    UC_Children_df <- UC_households_ltla |>
      left_join(children_low_income_ltla) |>
      select(ltla21_code, ltla21_name, year, UC_households_perc, children_low_income_hh_perc)

    head(UC_Children_df)

    ## # A tibble: 6 × 5
    ##   ltla21_code ltla21_name    year UC_households_perc children_low_income_hh_perc
    ##   <chr>       <chr>         <dbl>              <dbl>                       <dbl>
    ## 1 E06000047   County Durham  2016              0.914                        18.3
    ## 2 E06000047   County Durham  2017              1.91                         20.9
    ## 3 E06000047   County Durham  2018              3.84                         21.3
    ## 4 E06000047   County Durham  2019              9.02                         21.7
    ## 5 E06000047   County Durham  2020             12.4                          25.5
    ## 6 E06000047   County Durham  2021             19.2                          28.0

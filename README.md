# The Effects of Welfare Reform on Child Poverty in the UK

In this dissertation, I conduct a quantitative analysis of the effect of
welfare policy changes in the UK on the proportion of children living in
relative low-income families.

This Markdown includes the data analysis component of this dissertation.
It will first include some exploratory data analysis, and then will be
used to run the other components of the quantitative analysis of the
impact of UK benefit policies on the number of children living in
relative low income families. Note that the collection and cleaning of
the data that will be used here is done in scripts in the `data-raw`
folder of this repository, and the datasets are available in the `data`
folder.

## Data

### Outcome: Children Living in Relative Low Income Families

Data is downloaded from
[Stat-Xplore](https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml),
the Department of Work and Pensions (DWP) data distribution platform.

-   Low income is a family whose equivalised income is below 60 per cent
    of median household incomes. For Absolute low income involves, the
    median of the 2010/11 year is used. For Relative low income, the
    comparison is made to the median of the current year. This
    dissertation focuses on Relative low income because it better
    adjusts for economic changes. Relative income is Before Housing
    Costs (BHC) and includes contributions from earning, state support
    and pensions. Equivalisation adjusts incomes for household size and
    composition.

-   A family must have claimed Child Benefit and at least one other
    household benefit (Universal Credit, tax credits or Housing Benefit)
    at any point in the year to be classed as low income in these
    statistics

-   Children are defined as dependent individuals aged under 16; or aged
    16 to 19 in full-time non-advanced education.

Visit the dedicated [DWP
page](https://www.gov.uk/government/publications/children-in-low-income-families-local-area-statistics-background-information-and-methodology/background-information-and-methodology-children-in-low-income-families-local-area-statistics)
for further information.

#### Relative measure

To get the **proportion** of children in low income families, I used
[yearly population
estimates](https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales)
provided by the Office for National Statistics (for England and Wales),
and [time series
data](https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/mid-year-population-estimates/population-estimates-time-series-data)
from the National Records of Scotland. Because not all individuals aged
16 to 19 years old are counted as children in the CiRLIF measure,
population counts are summed for individuals aged 0-15 years old, and
used to divide the absolute measure of CiRLIF provided by the DWP.

**Geography: Local authorities (called ltla for Lower Tier Local
Authorities)**

-   England: English local authority districts (309)
-   Wales: Unitary authorities (22)
-   Scotland: Scottish council areas (32)
-   Northern Ireland: District council areas (11)

### Main Independent Variable: Households on Universal Credit

Data for the number of households who have a calculated entitlement for
Universal Credit is downloaded from
[Stat-Xplore](https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml),
the Department of Work and Pensions (DWP) data distribution platform.

Data is also available regarding the family type, number and age of
children, and work status of the household claiming Universal Credit.
For further information, visit the dedicated [DWP
page](https://www.gov.uk/government/publications/universal-credit-statistics-background-information-and-methodology/universal-credit-statistics-background-information-and-methodology).

#### Relative measure

To calculate the proportion of households on Universal Credit for each
local authority, numbers of households on UC were divided by historical
annual estimates of the number of households published by the Office for
National Statistics:
[2004-2019](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/13586estimatednumberofhouseholdsbyselectedhouseholdtypeslocalauthoritiesinenglandandwalescountiesandregionsofenglandscottishcouncilareasandgreatbritainconstituentcountries2004to2019),
[2020](https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/families/adhocs/14432estimatednumberofhouseholdsingreatbritaininnuts1nuts3englishandwelshlocalauthoritiesandscottishcouncilareas2020),
[2021](https://www.ons.gov.uk/datasets/TS041/editions/2021/versions/3).

**Geography: Local authorities (called ltla for Lower Tier Local
Authorities)**

-   England: English local authority districts (309)
-   Wales: Unitary authorities (22)
-   Scotland: Scottish council areas (32)
-   *[Data for Northern
    Ireland](https://www.communities-ni.gov.uk/articles/universal-credit-statistics)
    is made available by the Northern Ireland Department for
    Communities, but not yet collected in this package*

#### Universal Credit Rollout: Binary variable

The official [UC ‘Full Service’ transition rollout
schedule](https://assets.publishing.service.gov.uk/media/5ab507c8e5274a1aa2d414d1/universal-credit-transition-rollout-schedule.pdf)
published by the DWP was used to create explanatory variables measuring
cross-local authority variation in the timing of the UC rollout (Hardie,
2023: 1035). The first is a binary variable indicating whether UC ‘Full
Service’ had rolled out yet in each year in each local authority in the
sample (coded: 0 = ‘no’, 1 = ‘yes’). To mitigate bias and ensure
robustness in the conversion of the monthly Universal Credit rollout
data to annual data for the analysis, I coded multiple variables with
different thresholds — December of the previous year, April, and October
— to determine the minimum duration of Universal Credit presence within
a financial year required for a local authority to be classified as
having implemented UC. This first binary variable allows to study the
staggered rollout of UC as a natural experiment, with a delayed
treatment across local authorities.

The ‘Full Service’ iteration of Universal Credit was chosen for analysis
because it represents the comprehensive form of UC, making it accessible
to all types of claimants, including those with housing expenses. The
initial ‘Live Service’ variant was not considered in this study due to
its limited scope, primarily involving claims from single, unemployed
individuals without housing cost claims, thereby having minimal impact
on children from low-income families. (Hardie, 2023: 1035).

#### Universal Credit Rollout Duration: Categorical variable

If a significant effect of the rollout on children living in low income
families in indeed observed, this effect could be expected to vary
depending on how long UC has been rollout out in the local authority.
One possible scenario is that the effect fades over time because the
administrative system adapts. Conversely, as time goes on, more people
are reached by Universal Credit, and the effect on children in low
income families could become larger. For the purpose of studying the
long-term effect of the rollout, we build a secondary independent
variable ‘UC Full Service Rollout by Rollout Length’; a categorical
variable indicating whether UC ‘Full Service’ had rolled out yet in each
month in each local authority , and if so for how long (coded: 0 = ‘No
(pre-rollout)’ 1 = ‘Yes (1-6 months post)’, 2 = ‘Yes (7-12 months
post)’, 3 = ‘Yes (13-24 months post)’, and 4 = ‘Yes(25+ months post)’)
(Hardie, 2023: 1035). The proportion of children in low income families
is measured for a financial year, so the number of months is measured
from the month of the rollout to the middle of the financial year
(October).

## I) Relationship Between Households on UC and Children in Low Income Families

I start with an examination of the relationship between the rollout of
Universal Credit, more precisely the proportion of households on
Universal Credit, and the proportion of children living in low income
household.

I join the datasets of households on UC and children living in low
income, on local authority and year.

    data("children_low_income_ltla")
    data("UC_households_ltla")

    uc_children_df <- UC_households_ltla |>
      left_join(children_low_income_ltla) |>
      select(ltla21_code, ltla21_name, year, UC_households_perc, children_low_income_perc) |> 
      filter(!is.na(UC_households_perc) & !is.na(children_low_income_perc))

    print(paste0("Number of unique local authorities: ", length(unique(uc_children_df$ltla21_code))))

    ## [1] "Number of unique local authorities: 340"

    head(uc_children_df, 10)

    ## # A tibble: 10 × 5
    ##    ltla21_code ltla21_name    year UC_households_perc children_low_income_perc
    ##    <chr>       <chr>         <dbl>              <dbl>                    <dbl>
    ##  1 E06000047   County Durham  2016              0.914                     23.4
    ##  2 E06000047   County Durham  2017              1.91                      26.4
    ##  3 E06000047   County Durham  2018              3.84                      26.9
    ##  4 E06000047   County Durham  2019              9.02                      27.3
    ##  5 E06000047   County Durham  2020             12.4                       32.3
    ##  6 E06000047   County Durham  2021             19.2                       36.0
    ##  7 E06000047   County Durham  2022             18.6                       30.8
    ##  8 E06000005   Darlington     2016              0.717                     21.7
    ##  9 E06000005   Darlington     2017              2.06                      24.8
    ## 10 E06000005   Darlington     2018              2.33                      26.8

There is data for a total of 340 local authorities covering 2016 to
2022, leading to 2380 observations across England, Wales and Scotland.

### Initial observation

    summary_statistics <- uc_children_df |> 
      group_by(year) |> 
      summarise(
        median_children_low_income = median(children_low_income_perc),
        lower_IQR_children_low_income = quantile(children_low_income_perc, 0.25),
        upper_IQR_children_low_income = quantile(children_low_income_perc, 0.75)
      )

    print(summary_statistics)

    ## # A tibble: 7 × 4
    ##    year median_children_low_income lower_IQR_children_l…¹ upper_IQR_children_l…²
    ##   <dbl>                      <dbl>                  <dbl>                  <dbl>
    ## 1  2016                       17.8                   14.1                   22.2
    ## 2  2017                       18.7                   14.7                   23.0
    ## 3  2018                       19.6                   15.1                   24.5
    ## 4  2019                       19.5                   15.1                   24.1
    ## 5  2020                       20.8                   16.0                   26.5
    ## 6  2021                       19.5                   14.9                   26.4
    ## 7  2022                       22.3                   16.6                   28.0
    ## # ℹ abbreviated names: ¹​lower_IQR_children_low_income,
    ## #   ²​upper_IQR_children_low_income

There is a noticeable increase in the proportion of children living in
relative low income households. The first question is: is this rise in
child poverty in some parts of the UK concentrated in areas where more
people are claiming UC?

### Scatterplot

**Figure 1. Binned scatterplot of the proportion of household claiming
UC and proportion of children living in relative low income households
across local authorities (2017)**

    uc_children_2017_df <- uc_children_df |>
      filter(year == 2017)

    ggplot(uc_children_2017_df, aes(x = UC_households_perc, y = children_low_income_perc)) +
      geom_point()

![](README_files/figure-markdown_strict/unnamed-chunk-3-1.png)

Figure 1 is a binned scatterplot of the proportion of households
claiming Universal Credit (x-axis) and the proportion of children living
in low income families in 2017. It suggests a strong positive
relationship across local authorities. Of course, this correlation could
be driven by underlying characteristics of the local authorities.
(Reeves & Loopstra, 2021: 9)

### Fixed-Effects Model - Continuous Independent Variable (// Reeves & Loopstra, 2021)

A first baseline fixed effects (time and space) model allows to explore
whether this relationship remains even after controlling for
time-invariant local authority characteristics and time trends.

*Note: Standard errors are clustered for repeated observations within
local authorities.*

    uc_children_cont_fem <- 
      feols(data = uc_children_df, 
            children_low_income_perc ~ UC_households_perc | ltla21_code + year,
            cluster = ~ltla21_code)

    summary(uc_children_cont_fem)

    ## OLS estimation, Dep. Var.: children_low_income_perc
    ## Observations: 2,380 
    ## Fixed-effects: ltla21_code: 340,  year: 7
    ## Standard-errors: Clustered (ltla21_code) 
    ##                    Estimate Std. Error t value   Pr(>|t|)    
    ## UC_households_perc 0.137705   0.026661 5.16513 4.1074e-07 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 1.97767     Adj. R2: 0.923087
    ##                 Within R2: 0.025308

The results of this first model show that for every 1 percentage point
increase in households receiving UC, there is a 0.138 percentage point
increase in the proportion of children living in low income families.
This relationship is statistically significant at all conventional
thresholds.

**Important notes**:

1.  The key assumption needed for a valid estimation of a causal effect
    with this fixed-effects model is the parallel trends assumption.
    That is, local authorities which have **not** displayed an increase
    in UC caseload would have seen the same change in the proportion of
    children living in low income families as local authorities which
    have indeed displayed an increase in proportion of households on UC.
    This assumption needs to be studied further.
2.  It would be benefiticial to control for potentially time varying
    local authority characteristics such as unemployment. This would
    make the parallel trends assumption more plausible. More data
    collection is necessary for that.

### Fixed-Effects Model - Binary Independent Variable (UC Full Service Rollout) (// Hardie, 2023)

In the next model, the Universal Credit rollout is studied as a binary
treatment across all local authorities. This additional analysis is
critical to assess a causality link of the rollout of the policy on the
proportion of children living in low income families because it allows
to run placebo tests, which will be detailed later.

    data("uc_rollout_ltla_15mo")
    data("uc_rollout_ltla_12mo")
    data("uc_rollout_ltla_6mo")

    uc_rollout_ltla_15mo_joined <- uc_rollout_ltla_15mo |> 
      left_join(children_low_income_ltla)

    ## Joining with `by = join_by(ltla21_code, ltla21_name, year)`

    uc_rollout_ltla_12mo_joined <- uc_rollout_ltla_12mo |> 
      left_join(children_low_income_ltla)

    ## Joining with `by = join_by(ltla21_code, ltla21_name, year)`

    uc_rollout_ltla_6mo_joined <- uc_rollout_ltla_6mo |> 
      left_join(children_low_income_ltla)

    ## Joining with `by = join_by(ltla21_code, ltla21_name, year)`

    uc_children_binary_15mo_fem <- 
      feols(data = uc_rollout_ltla_15mo_joined, 
            children_low_income_perc ~ uc_rolled_out | ltla21_code + year,
            cluster = ~ltla21_code)

    summary(uc_children_binary_15mo_fem)

    ## OLS estimation, Dep. Var.: children_low_income_perc
    ## Observations: 2,172 
    ## Fixed-effects: ltla21_code: 358,  year: 6
    ## Standard-errors: Clustered (ltla21_code) 
    ##                Estimate Std. Error  t value Pr(>|t|) 
    ## uc_rolled_out -0.145409   0.117448 -1.23807   0.2165 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 1.40669     Adj. R2: 0.952533
    ##                 Within R2: 4.264e-4

    uc_children_binary_12mo_fem <- 
      feols(data = uc_rollout_ltla_12mo_joined, 
            children_low_income_perc ~ uc_rolled_out | ltla21_code + year,
            cluster = ~ltla21_code)

    summary(uc_children_binary_12mo_fem)

    ## OLS estimation, Dep. Var.: children_low_income_perc
    ## Observations: 2,172 
    ## Fixed-effects: ltla21_code: 358,  year: 6
    ## Standard-errors: Clustered (ltla21_code) 
    ##               Estimate Std. Error  t value Pr(>|t|) 
    ## uc_rolled_out 0.071163   0.165788 0.429243  0.66801 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 1.40691     Adj. R2: 0.952518
    ##                 Within R2: 1.132e-4

    uc_children_binary_6mo_fem <- 
      feols(data = uc_rollout_ltla_6mo_joined, 
            children_low_income_perc ~ uc_rolled_out | ltla21_code + year,
            cluster = ~ltla21_code)

    summary(uc_children_binary_6mo_fem)

    ## OLS estimation, Dep. Var.: children_low_income_perc
    ## Observations: 2,172 
    ## Fixed-effects: ltla21_code: 358,  year: 6
    ## Standard-errors: Clustered (ltla21_code) 
    ##                Estimate Std. Error   t value Pr(>|t|) 
    ## uc_rolled_out -0.100273   0.132627 -0.756055  0.45011 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## RMSE: 1.40682     Adj. R2: 0.952524
    ##                 Within R2: 2.385e-4

None of the models displays a statistically significant effect of the
rollout of Universal Credit on the proportion of children in low income
families within local authorities. The implications of this finding are
difficult to flesh out because of the potential measurement issues
emerging from the difference in measurement frequency between the
independent variable and outcome.

### Add time-varying controls to fixed-effects model

-   Research on drivers of child poverty needed
    -   unemployment rate
    -   nth percentile of wages

### Fixed-Effects Model - Categorical Variable: Long-term effects of UC Full Service Rollout

-   How to count number of months from rollout to reference year
    -   e.g. FYE 2018 (April 2017 - March 2018): if UC has been rolled
        out in December 2016, how many months are counted for FYE 2018?

### Scottish Child Payment

“On 15 February 2021 we introduced the Scottish Child Payment for
low-income families with children under six as part of our work on
tackling child poverty. It was initially set at a rate of £10 per week
per child with no limit to the number of eligible children.

In March 2022 we published “Best Start, Bright Futures: tackling child
poverty delivery plan 2022 to 2026” in which we committed to doubling
the value of the Scottish Child Payment from April 2022, delivering the
benefit in full to all eligible children under the age of 16 and further
increasing the value to £25 per child, per week, by the end of 2022.
These commitments were delivered on 14 November 2022.”
(<https://www.gov.scot/policies/social-security/scottish-child-payment/>)

-   MSOA level children living in low income families for Scotland and
    England
    -   difference in differences for pre-2021 and 2021-2022
    -   with matching on UC takeup, unemployment & pre-treatment outcome

### Two-Child Limit in Universal Credit

-   Households with a third or subsequent child born from 6 April 2017
    claiming Universal Credit or Child Tax Credit no longer receive
    additional amounts for these children. The policy only applies to
    children born from 6 April 2017, so not all families with a third or
    subsequent child claiming Universal Credit will be affected until
    the mid-2030s. In April 2023, the two-child limit affected 422,000
    (55%) of the 772,000 families with three or more children claiming
    Universal Credit or Child Tax Credit. 22,000 households had an
    exception.

-   Initial results: Relative poverty among families with three or more
    children, which has been rising since 2013, has continued to
    increase since April 2017. The Government points to falling absolute
    poverty over the period and questions the use of relative poverty
    measures.

-   More research needed (Patrick et al, 2023)

-   Possibility of quasi-experimental research? Data on number of
    children living in low income by age available.

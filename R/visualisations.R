# ==============================
# ---- DATA VISUALISATIONS -----
# ==============================

# ---- SETUP ----
library(tidyverse)
library(httr2)
library(readODS)
library(janitor)
library(gridExtra)

# ---- LITERATURE REVIEW ----
# Time-series data for children in relative low income
# Source: https://www.gov.uk/government/statistics/households-below-average-income-for-financial-years-ending-1995-to-2022; Table 4.14ts

temp_zip_path <- tempfile(fileext = ".zip")

# Download the file
url <- "https://assets.publishing.service.gov.uk/media/64e763b51ff6f3000d70af47/hbai-2122-ods-table-pack.zip"
response <- request(url) |>
  req_perform() |>
  resp_body_raw()
writeBin(response, temp_zip_path)

# Unzip the file
temp_extract_dir <- tempdir()
unzip(temp_zip_path, files = "children-hbai-timeseries-1994-95-2021-22-tables.ods", exdir = temp_extract_dir)

# Read the ODS
temp_ods_path <- file.path(temp_extract_dir, "children-hbai-timeseries-1994-95-2021-22-tables.ods")

child_ts_BHC_raw <-
  read_ods(temp_ods_path,
    sheet = "4_14ts",
    range = "A7:AC28"
  ) |>
  clean_names()

child_ts_AHC_raw <-
  read_ods(temp_ods_path,
    sheet = "4_14ts",
    range = "A7:AC50"
  ) |>
  clean_names() |>
  slice(-1:-23)

rm(response, temp_extract_dir, temp_ods_path, temp_zip_path)

# ---- Figure 1 ----
# Children (%) in Households with Income Below 60% of the Median (Equivalised), AHC and BHC (1994-2022)
fig1_BHC <- child_ts_BHC_raw |>
  filter(x1 == "All children (per cent)") |>
  mutate(across(-x1, ~ as.numeric(as.character(.)))) |>
  pivot_longer(
    cols = -c(x1),
    names_to = "year",
    values_to = "value",
    names_prefix = "x",
  ) |>
  mutate(
    year = str_replace(year, "_", "-")
  ) |>
  rename(variable = x1) |>
  mutate(
    variable = "child_low_income_perc_BHC",
    # Update the year column
    year = gsub("94-955", "1994-95", year),
    year = gsub("95-965", "1995-96", year),
    year = gsub("20-212", "2020-21", year),
    year = gsub("21-221", "2021-22", year)
  ) |>
  mutate(
    year = case_when(
      # Handle years from 2010 to 2019
      str_detect(year, "^10-") ~ str_replace(year, "^10", "2010"),
      str_detect(year, "^11-") ~ str_replace(year, "^11", "2011"),
      str_detect(year, "^12-") ~ str_replace(year, "^12", "2012"),
      str_detect(year, "^13-") ~ str_replace(year, "^13", "2013"),
      str_detect(year, "^14-") ~ str_replace(year, "^14", "2014"),
      str_detect(year, "^15-") ~ str_replace(year, "^15", "2015"),
      str_detect(year, "^16-") ~ str_replace(year, "^16", "2016"),
      str_detect(year, "^17-") ~ str_replace(year, "^17", "2017"),
      str_detect(year, "^18-") ~ str_replace(year, "^18", "2018"),
      str_detect(year, "^19-") ~ str_replace(year, "^19", "2019"),
      # Handle years from 2000 to 2009
      str_detect(year, "^00-") ~ str_replace(year, "^00", "2000"),
      str_detect(year, "^01-") ~ str_replace(year, "^01", "2001"),
      str_detect(year, "^02-") ~ str_replace(year, "^02", "2002"),
      str_detect(year, "^03-") ~ str_replace(year, "^03", "2003"),
      str_detect(year, "^04-") ~ str_replace(year, "^04", "2004"),
      str_detect(year, "^05-") ~ str_replace(year, "^05", "2005"),
      str_detect(year, "^06-") ~ str_replace(year, "^06", "2006"),
      str_detect(year, "^07-") ~ str_replace(year, "^07", "2007"),
      str_detect(year, "^08-") ~ str_replace(year, "^08", "2008"),
      str_detect(year, "^09-") ~ str_replace(year, "^09", "2009"),
      # Handle years from 1996 to 1999
      str_detect(year, "^96-") ~ str_replace(year, "^96", "1996"),
      str_detect(year, "^97-") ~ str_replace(year, "^97", "1997"),
      str_detect(year, "^98-") ~ str_replace(year, "^98", "1998"),
      str_detect(year, "^99-") ~ str_replace(year, "^99", "1999"),
      # For other years that do not match the above patterns (already correct)
      TRUE ~ year
    )
  )

fig1_AHC <- child_ts_AHC_raw |>
  filter(x1 == "All children (per cent)") |>
  mutate(across(-x1, ~ as.numeric(as.character(.)))) |>
  pivot_longer(
    cols = -c(x1),
    names_to = "year",
    values_to = "value",
    names_prefix = "x",
  ) |>
  mutate(
    year = str_replace(year, "_", "-")
  ) |>
  rename(variable = x1) |>
  mutate(
    variable = "child_low_income_perc_AHC",
    # Update the year column
    year = gsub("94-955", "1994-95", year),
    year = gsub("95-965", "1995-96", year),
    year = gsub("20-212", "2020-21", year),
    year = gsub("21-221", "2021-22", year)
  ) |>
  mutate(
    year = case_when(
      # Handle years from 2010 to 2019
      str_detect(year, "^10-") ~ str_replace(year, "^10", "2010"),
      str_detect(year, "^11-") ~ str_replace(year, "^11", "2011"),
      str_detect(year, "^12-") ~ str_replace(year, "^12", "2012"),
      str_detect(year, "^13-") ~ str_replace(year, "^13", "2013"),
      str_detect(year, "^14-") ~ str_replace(year, "^14", "2014"),
      str_detect(year, "^15-") ~ str_replace(year, "^15", "2015"),
      str_detect(year, "^16-") ~ str_replace(year, "^16", "2016"),
      str_detect(year, "^17-") ~ str_replace(year, "^17", "2017"),
      str_detect(year, "^18-") ~ str_replace(year, "^18", "2018"),
      str_detect(year, "^19-") ~ str_replace(year, "^19", "2019"),
      # Handle years from 2000 to 2009
      str_detect(year, "^00-") ~ str_replace(year, "^00", "2000"),
      str_detect(year, "^01-") ~ str_replace(year, "^01", "2001"),
      str_detect(year, "^02-") ~ str_replace(year, "^02", "2002"),
      str_detect(year, "^03-") ~ str_replace(year, "^03", "2003"),
      str_detect(year, "^04-") ~ str_replace(year, "^04", "2004"),
      str_detect(year, "^05-") ~ str_replace(year, "^05", "2005"),
      str_detect(year, "^06-") ~ str_replace(year, "^06", "2006"),
      str_detect(year, "^07-") ~ str_replace(year, "^07", "2007"),
      str_detect(year, "^08-") ~ str_replace(year, "^08", "2008"),
      str_detect(year, "^09-") ~ str_replace(year, "^09", "2009"),
      # Handle years from 1996 to 1999
      str_detect(year, "^96-") ~ str_replace(year, "^96", "1996"),
      str_detect(year, "^97-") ~ str_replace(year, "^97", "1997"),
      str_detect(year, "^98-") ~ str_replace(year, "^98", "1998"),
      str_detect(year, "^99-") ~ str_replace(year, "^99", "1999"),
      # For other years that do not match the above patterns (already correct)
      TRUE ~ year
    )
  )

fig1_df <- rbind(fig1_AHC, fig1_BHC)

# Visualisation
ggplot(fig1_df, aes(x = year, y = value, group = variable, color = variable)) +
  geom_line(linewidth = 1.75) +
  scale_color_manual(
    values = c(
      "child_low_income_perc_AHC" = "#d6ab63",
      "child_low_income_perc_BHC" = "#51bec7"
    ),
    labels = c("After housing costs", "Before housing costs") # Rename legend labels
  ) +
  scale_y_continuous(limits = c(0, NA), expand = c(0, 0)) +
  theme(
    aspect.ratio = 3.2 / 7,
    plot.margin = margin(t = 0, r = 0.5, b = 0, l = 0.5, unit = "cm"),
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "#dcdbd8"),
    panel.grid.minor.y = element_line(color = "#dcdbd8"),
    legend.text = element_text(margin = margin(l = 3), size = 12),
    legend.title = element_blank(),
    legend.position = c(0.1, 0.2),
    legend.key.width = unit(25, "pt"),
    legend.key.height = unit(15, "pt"),
    legend.key = element_blank(),
    axis.text = element_text(size = rel(1), color = "gray8"),
    axis.title = element_text(size = rel(1.2), color = "gray8"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.line.x = element_line(color = "gray8"),
    axis.ticks.y = element_blank()
  ) +
  labs(
    x = "Year",
    y = "Children in Relative Low Income Families (%)",
  )

# ---- Figure 3 ----
fig3_df <- child_ts_AHC_raw |>
  filter(x1 %in% c("Lone parent:", "Couple with children:")) |>
  mutate(across(-x1, ~ as.numeric(as.character(.)))) |>
  pivot_longer(
    cols = -c(x1),
    names_to = "year",
    values_to = "value",
    names_prefix = "x",
  ) |>
  mutate(
    year = str_replace(year, "_", "-")
  ) |>
  rename(variable = x1) |>
  filter(!year %in% c("20-212", "21-221")) |>
  mutate(
    variable = case_when(
      variable == "Lone parent:" ~ "Children living with lone parents",
      variable == "Couple with children:" ~ "Children living with couples"
    ),
    # Update the year column
    year = gsub("94-955", "1994-95", year),
    year = gsub("95-965", "1995-96", year),
    year = gsub("20-212", "2020-21", year),
    year = gsub("21-221", "2021-22", year)
  ) |>
  mutate(
    year = case_when(
      # Handle years from 2010 to 2019
      str_detect(year, "^10-") ~ str_replace(year, "^10", "2010"),
      str_detect(year, "^11-") ~ str_replace(year, "^11", "2011"),
      str_detect(year, "^12-") ~ str_replace(year, "^12", "2012"),
      str_detect(year, "^13-") ~ str_replace(year, "^13", "2013"),
      str_detect(year, "^14-") ~ str_replace(year, "^14", "2014"),
      str_detect(year, "^15-") ~ str_replace(year, "^15", "2015"),
      str_detect(year, "^16-") ~ str_replace(year, "^16", "2016"),
      str_detect(year, "^17-") ~ str_replace(year, "^17", "2017"),
      str_detect(year, "^18-") ~ str_replace(year, "^18", "2018"),
      str_detect(year, "^19-") ~ str_replace(year, "^19", "2019"),
      # Handle years from 2000 to 2009
      str_detect(year, "^00-") ~ str_replace(year, "^00", "2000"),
      str_detect(year, "^01-") ~ str_replace(year, "^01", "2001"),
      str_detect(year, "^02-") ~ str_replace(year, "^02", "2002"),
      str_detect(year, "^03-") ~ str_replace(year, "^03", "2003"),
      str_detect(year, "^04-") ~ str_replace(year, "^04", "2004"),
      str_detect(year, "^05-") ~ str_replace(year, "^05", "2005"),
      str_detect(year, "^06-") ~ str_replace(year, "^06", "2006"),
      str_detect(year, "^07-") ~ str_replace(year, "^07", "2007"),
      str_detect(year, "^08-") ~ str_replace(year, "^08", "2008"),
      str_detect(year, "^09-") ~ str_replace(year, "^09", "2009"),
      # Handle years from 1996 to 1999
      str_detect(year, "^96-") ~ str_replace(year, "^96", "1996"),
      str_detect(year, "^97-") ~ str_replace(year, "^97", "1997"),
      str_detect(year, "^98-") ~ str_replace(year, "^98", "1998"),
      str_detect(year, "^99-") ~ str_replace(year, "^99", "1999"),
      # For other years that do not match the above patterns (already correct)
      TRUE ~ year
    )
  )

# Visualisation
ggplot(fig3_df, aes(x = year, y = value, group = variable, color = variable)) +
  geom_line(linewidth = 1.75) +
  scale_color_manual(
    values = c(
      "Children living with lone parents" = "#843844",
      "Children living with couples" = "#17648d"
    )
  ) +
  scale_y_continuous(limits = c(0, NA), expand = c(0, 0)) +
  theme(
    aspect.ratio = 3.2 / 7,
    plot.margin = margin(t = 0, r = 0.5, b = 0, l = 0.5, unit = "cm"),
    plot.background = element_rect(fill = "white"),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "#dcdbd8"),
    panel.grid.minor.y = element_line(color = "#dcdbd8"),
    legend.text = element_text(margin = margin(l = 3), size = 12),
    legend.title = element_blank(),
    legend.position = c(0.15, 0.22),
    legend.key.width = unit(25, "pt"),
    legend.key.height = unit(15, "pt"),
    legend.key = element_blank(),
    axis.text = element_text(size = rel(1), color = "gray8"),
    axis.title = element_text(size = rel(1.2), color = "gray8"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.line.x = element_line(color = "gray8"),
    axis.ticks.y = element_blank()
  ) +
  labs(
    x = "Year",
    y = "Children in Relative Low Income Families (%)",
  )

# ---- Figure 2 ----
fig2_df <- read_csv("inst/extdata/europe_child_poverty.csv") |> 
  pivot_longer(cols = -Country, names_to = "Indicator", values_to = "Value") |> 
  mutate(Highlight = ifelse(Country == "United Kingdom", "United Kingdom", "Other"))

fig2_df_plot1 <- fig2_df |> 
  filter(Indicator == "Material deprivation (% of children lacking three or more necessities)") |> 
  mutate(Country = fct_reorder(Country, Value))

fig2_df_plot2 <- fig2_df |> 
  filter(Indicator == "Poverty headcount (% of children in households below 60% median)") |> 
  mutate(Country = fct_reorder(Country, Value))

fig2_df_plot3 <- fig2_df |> 
  filter(Indicator == "Persistent child poverty (% of children in poverty this year and at least two of previous three years)") |> 
  mutate(Country = fct_reorder(Country, Value))

plot1 <-  
  ggplot(fig2_df_plot1, aes(x = Country, y = Value, fill = Highlight)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("United Kingdom" = "#B20000", "Other" = "grey")) +
  scale_y_continuous(expand = c(0, 0))+
  labs(title = "Material deprivation \n(% of children lacking three or more necessities)") +
  theme(
    plot.margin = margin(t = 0.5, r = 0.5, b = 0, l = 0.5, unit = "cm"),
    plot.background = element_rect(fill = "white"),
    plot.title = element_text(size = 14, hjust = 0.5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "#dcdbd8"),
    panel.grid.minor.y = element_line(color = "#dcdbd8"),
    legend.position = "none",
    axis.text = element_text(size = rel(1), color = "gray8"),
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 60, hjust = 1, size = rel(0.9)),
    axis.line.x = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank()
  ) 

plot2 <-  
  ggplot(fig2_df_plot2, aes(x = Country, y = Value, fill = Highlight)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("United Kingdom" = "#B20000", "Other" = "grey")) +
  scale_y_continuous(expand = c(0, 0))+
  labs(title = "Poverty headcount \n(% of children in households below 60% median)") +
  theme(
    plot.margin = margin(t = 0.5, r = 0.5, b = 0, l = 0.5, unit = "cm"),
    plot.background = element_rect(fill = "white"),
    plot.title = element_text(size = 14, hjust = 0.5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "#dcdbd8"),
    panel.grid.minor.y = element_line(color = "#dcdbd8"),
    legend.position = "none",
    axis.text = element_text(size = rel(1), color = "gray8"),
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 60, hjust = 1, size = rel(0.9)),
    axis.line.x = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank()
  ) 

plot3 <-  
  ggplot(fig2_df_plot3, aes(x = Country, y = Value, fill = Highlight)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("United Kingdom" = "#B20000", "Other" = "grey")) +
  scale_y_continuous(expand = c(0, 0))+
  labs(title = "Persistent child poverty \n(% of children in poverty this year and\n at least two of previous three years)") +
  theme(
    plot.margin = margin(t = 0.5, r = 0.5, b = 0, l = 0.5, unit = "cm"),
    plot.background = element_rect(fill = "white"),
    plot.title = element_text(size = 14, hjust = 0.5),
    panel.background = element_rect(fill = "white"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "#dcdbd8"),
    panel.grid.minor.y = element_line(color = "#dcdbd8"),
    legend.position = "none",
    axis.text = element_text(size = rel(1), color = "gray8"),
    axis.title = element_blank(),
    axis.text.x = element_text(angle = 60, hjust = 1, size = rel(0.9)),
    axis.line.x = element_line(color = "gray8"),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_blank()
  ) 

grid.arrange(plot1, plot2, plot3, ncol = 3)

# ---- ANALYSIS ----

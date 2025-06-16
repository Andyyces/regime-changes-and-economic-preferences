## Regime Changes and Economic Preferences: Global Evidence

##### Supervisor: Andreas Leibing

##### Author: Andrea Ceskova, Elvin Mammadov

##### Starting date: 14.04.2025

In this project, we are analyzing the relationship between economic preferences and regime changes in global context. We'll use TWFE to examine whether regime changes have a causal effect on varying level of economic preferences. We also capture the direction of change (autocratization or democratization) and differentiate between those in our analysis.

## Data sources

This project build on two data sets: [V-Dem dataset](https://v-dem.net/data/the-v-dem-dataset/) and [Global Preference Survey](https://gps.iza.org/home). From the V-Dem Dataset, we work mainly with the aggregated data on country level: **Liberal Democracy index**. [Here](https://v-dem.net/documents/57/structureofaggregation.pdf) you can see the structure of aggregation. The GDP data is taken from the [Maddison Project Database](https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2023).

### How to run ?

1)  Before running any part of the project, restore the R package environment using `renv`.

`if (!require("renv")) install.packages("renv") renv::restore()`

All analysis and most scripts depend on the cleaned data created in the wrangling step. So that is why you should run first `"R/Data_wragling.Rmd"`. There is also "`R/Script"` folder that contains codes used in `"Data_wragling.Rmd"`, so these codes automatically run when you run `"Data_wragling.Rmd"`.

2.  There are files in `/Milestones` folder that consist of milestones reports.

3.  After successful data wrangling, you can render each milestone report from the `/Milestones` folder using:

`quarto::render("Milestones/Milestone-2-Data.qmd") quarto::render("Milestones/Milestone-3_Econometrich-Approach.qmd") quarto::render("Milestones/Milestone-4_Results.qmd") quarto::render("Milestones/Milestone-5_Robustness.qmd")`

4.  The `/R/Regression.qmd` consist of empirical strategies that were used in our analysis. The output of these regressions is located in `/Output` folder.

5.  Optional: `R/Visualizations.qmd` and `R/Robustness_check.qmd`, these generate exploratory plots and additional statistical diagnostics related to treatment/control group comparison and validity checks.

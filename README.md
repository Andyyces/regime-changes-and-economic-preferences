## Regime Changes and Economic Preferences: Global Evidence

##### Supervisor: Andreas Leibing

##### Author: Andrea Ceskova, Elvin Mammadov

##### Starting date: 14.04.2025

This project investigates the relationship between economic preferences and regime changes in a global context. We employ Two-Way Fixed Effects (TWFE) regression to examine whether regime changes have a causal impact on various economic preferences. Our analysis distinguishes between the direction of change (autocratization versus democratization) to capture differential effects.

## Data sources

This project utilizes two primary datasets: [V-Dem dataset](https://v-dem.net/data/the-v-dem-dataset/) and [Global Preference Survey](https://gps.iza.org/home). From the V-Dem Dataset. We derive treatment indicators from changes in the V-Dem **Liberal Democracy index** at the country level. [Here](https://v-dem.net/documents/57/structureofaggregation.pdf) you can see the structure of aggregation. The GDP data comes from the [Maddison Project D](https://www.rug.nl/ggdc/historicaldevelopment/maddison/releases/maddison-project-database-2023)

For robustness checks, we validate our methodology using two alternative country-level datasets for treatment calculation:

-   [Polity 5: Regime Authority Characteristics and Transition Datasets](https://www.systemicpeace.org/inscrdata.html)

-   [V-Dem dataset](https://v-dem.net/data/the-v-dem-dataset/): **Regimes of the World Index**

## Running the analysis

1.  First, restore the R package environment using `renv`:

`if (!require("renv")) install.packages("renv") renv::restore()`

2.  The empirical analysis requires cleaned data generated in the data wrangling step. Therefore, begin by running `/R/Data_wragling.Rmd`. Each code chunk in this file sources a corresponding script from the `/R/Script` folder. Running the code chunks in `/R/Data_wragling.Rmd` executes the code sequentially.

```         
After processing, `/R/Data_wragling.Rmd` saves the cleaned datasets as RDS files in the `/Input/clean` folder.
```

3.  `/R/Regression.qmd` contains empirical strategies and analyses. Output from these regressions is saved in the `/Output` folder.

4.  The `R/Robustness_check.qmd` produces additional statistical diagnostics related to treatment/control group comparison and validity assessments. Our robustness checks apply the same methodology to different country-level datasets: `/R/Polity results.qmd` analyzes the Polity 5 dataset, while `/R/Regime based results.qmd` examines the Regimes of the World Index from V-Dem.

5.  `R/Visualizations.qmd` generates country-level visualizations of regime changes across all three datasets: V-Dem Liberal Democracy Index, V-Dem Regimes of the World Index and Polity5. Outputs are saved in the `/Output` folder.

## Report Rendering

The `/Milestones` folder contains both source (.qmd) and rendered PDF files of project milestone reports. After successfuly completing all analyses as described above, each milestone report from the `/Milestones` can be rendered using:

`quarto::render("Milestones/Milestone-2-Data.qmd")``quarto::render("Milestones/Milestone-2-Data.qmd")quarto::render("Milestones/Milestone-3_Econometrich-Approach.qmd")quarto::render("Milestones/Milestone-4_Results.qmd")quarto::render("Milestones/Milestone-5_Robustness.qmd")`

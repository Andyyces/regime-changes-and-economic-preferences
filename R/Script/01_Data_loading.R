#install.packages("pacman")
library(pacman)
p_load(haven,
       here,
       stargazer,
       summarytools,
       readxl,
       dplyr,
       lubridate,
       ggplot2,
       vdemdata,
       summarytools,
       devtools,
       zoo,
       tidyverse,
       dataverse)

#install.packages("summarytools")
#install.packages("devtools")
#devtools::install_github("vdeminstitute/vdemdata")


# Downloading Vdem data 
vdem <- vdemdata::vdem


# Downaloading GPS Data
#opening datasets (individual survey)
unzip(here("Input", "raw", "GPS_Dataset.zip"), 
      files = "GPS_dataset_individual_level.zip",
      exdir = here("Input", "raw"))

unzip(here("Input", "raw", "GPS_dataset_individual_level.zip"), 
      files = "individual_v11_new.dta",
      exdir = here("Input", "raw"))

GPS_indiv <- read_dta(here("Input", "raw", "individual_v11_new.dta"))

#converting the column encodings to UTF-8
names(GPS_indiv)
GPS_indiv <- GPS_indiv %>%
  mutate(across(where(is.character), ~ iconv(., from = "", to = "UTF-8")))



# Downloading GDP data from the Dataverse
gdp_data <- get_dataframe_by_id(
  fileid = 421302,
  server = "dataverse.nl",
  .f = function(x) read_excel(x, sheet = "Full data")
)





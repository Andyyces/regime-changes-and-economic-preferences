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



# Downloading GPS Data
download.file("https://gps.iza.org/file/GPS_dataset_individual_level.zip", 
              destfile = here("Input", "raw", "GPS_dataset_individual_level.zip"), mode = "wb")

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


p5 <- read_excel(here("Input", "p5v2018.xls"))


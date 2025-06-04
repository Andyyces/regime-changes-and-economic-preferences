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
       tidyverse)

#install.packages("summarytools")
#install.packages("devtools")
#devtools::install_github("vdeminstitute/vdemdata")


#Vdem data 
vdem <- vdemdata::vdem

#opening datasets (individual survey)
#unzip(here("Input","GPS_Dataset.zip"))
#unzip(here("Input", "GPS_dataset_individual_level.zip"))
GPS_indiv <- read_dta(here("Input","individual_v11_new.dta"))

#openning data polity
#p5 <- read_excel(here("Input", "p5v2018.xls"))
gdp_data <- read_excel(here("Input", "mpd2023_web_2.xlsx"))
#converting the column encodings to UTF-8
names(GPS_indiv)
GPS_indiv <- GPS_indiv %>%
  mutate(across(where(is.character), ~ iconv(., from = "", to = "UTF-8")))


#install.packages("devtools")
#devtools::install_github("vdeminstitute/vdemdata")
library(vdemdata)
vdem <- vdemdata::vdem



library(haven)
library(here)
unzip("Data/GPS_Dataset.zip")
unzip("GPS_dataset_individual_level.zip")
GPS_indiv <- read_dta("individual_new.dta")

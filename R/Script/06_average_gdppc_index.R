# Takes a while to compute because of the nested loop
calculate_avg_gdppc <- function(final_data, gdp_data) {
  # Ensure numeric types for merging
  final_data$year_3 <- as.numeric(final_data$year_3)
  final_data$year_adult <- as.numeric(final_data$year_adult)
  
  # Initialize the new column
  final_data$avg_gdppc_formative <- NA
  
  # Loop over each row to calculate average GDP per capita during formative years
  for (i in 1:nrow(final_data)) {
    id <- final_data$id_gallup[i]  # Track respondent ID
    iso <- final_data$isocode[i]
    start_year <- final_data$year_3[i]
    end_year <- final_data$year_adult[i]
    
    # Subset relevant GDP data
    gdp_subset <- gdp_data[gdp_data$countrycode == iso & 
                             gdp_data$year >= start_year & 
                             gdp_data$year <= end_year, ]
    
    # Calculate mean GDP per capita
    avg_gdp <- mean(gdp_subset$gdppc, na.rm = TRUE)
    
    # Optional: Print for debugging
    # print(paste("ID:", id, "| ISO:", iso, "| Years:", start_year, "-", end_year, "| Avg GDP:", avg_gdp))
    
    # Assign result
    final_data$avg_gdppc_formative[i] <- avg_gdp
  }
  
  return(final_data)
}


final_data_gdp <- calculate_avg_gdppc(final_data_clean, gdp_data)

# Takes a while to compute because of the nested loop
calculate_avg_libdem <- function(final_data_gdp, vdem_sub) {
  # Ensure numeric types
  final_data_gdp$year_3 <- as.numeric(final_data_gdp$year_3)
  final_data_gdp$year_adult <- as.numeric(final_data_gdp$year_adult)
  
  # Initialize new column
  final_data_gdp$avg_libdem_formative <- NA
  
  # Loop over each respondent
  for (i in 1:nrow(final_data_gdp)) {
    iso <- final_data_gdp$isocode[i]
    start_year <- final_data_gdp$year_3[i]
    end_year <- final_data_gdp$year_adult[i]
    
    # Filter V-Dem data for the country and years
    vdem_subset <- vdem_sub[vdem_sub$country_text_id == iso & 
                              vdem_sub$year >= start_year & 
                              vdem_sub$year <= end_year, ]
    
    # Compute mean liberal democracy index
    avg_libdem <- mean(vdem_subset$v2x_libdem, na.rm = TRUE)
    
    # Assign to new column
    final_data_gdp$avg_libdem_formative[i] <- avg_libdem
  }
  
  return(final_data_gdp)
}

final_data_gdp <- calculate_avg_libdem(final_data_gdp, vdem_sub)

final_data_gdp <- final_data_gdp %>%
  filter(!is.na(avg_libdem_formative) & !is.na(avg_gdppc_formative))


# Assigning observations as treated only if they were older than 2 years in year of regime change
final_data_gdp$formative_regime_change[final_data_gdp$first_formative_age < 3] <- 0
table(final_data_gdp$formative_regime_change)

# More preprocessing for the regressions
final_data_gdp <- final_data_gdp %>% mutate(years_spend_regimes = age - first_formative_age)
final_data_gdp$region <- factor(final_data_gdp$region)
final_data_gdp$avg_gdppc_formative <- log(final_data_gdp$avg_gdppc_formative)

# Saving the final dataset in rds format
saveRDS(final_data_gdp, here("Input","clean", "final_data_gdp.rds"))
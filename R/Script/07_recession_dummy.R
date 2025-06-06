# Creating a recession dummy based on country-specific volatility
create_country_specific_recession <- function(gdp_data, n_sd = 1.5) {
  
  # First calculating country-specific statistics
  country_stats <- gdp_data %>%
    arrange(countrycode, year) %>%
    group_by(countrycode) %>%
    mutate(
      gdppc_growth = (gdppc - lag(gdppc)) / lag(gdppc) * 100
    ) %>%
    summarise(
      country_mean_growth = mean(gdppc_growth, na.rm = TRUE),
      country_sd_growth = sd(gdppc_growth, na.rm = TRUE),
      n_observations = sum(!is.na(gdppc_growth))
    ) %>%
    filter(n_observations >= 10)  # Require at least 10 observations for reliable stats
  
  # Now creating recession indicators
  recession_data <- gdp_data %>%
    arrange(countrycode, year) %>%
    group_by(countrycode) %>%
    mutate(
      # Calculating growth
      gdppc_growth = (gdppc - lag(gdppc)) / lag(gdppc) * 100
    ) %>%
    # Joining with country statistics
    left_join(country_stats, by = "countrycode") %>%
    mutate(
      # Calculating threshold for this country
      recession_threshold = country_mean_growth - (n_sd * country_sd_growth),
      
      # Recession if growth is below country-specific threshold
      recession = case_when(
        is.na(gdppc_growth) ~ NA_real_,
        is.na(recession_threshold) ~ NA_real_,
        gdppc_growth < recession_threshold ~ 1,
        TRUE ~ 0
      )
    ) %>%
    select(countrycode, year, recession, gdppc_growth, recession_threshold, 
           country_mean_growth, country_sd_growth) %>%
    ungroup()
  
  # Printing summary statistics
  cat("\n=== Country-Specific Recession Definition Summary ===\n")
  cat("Number of standard deviations used:", n_sd, "\n")
  cat("Countries with sufficient data:", nrow(country_stats), "\n")
  
  # Showing distribution of thresholds
  threshold_summary <- recession_data %>%
    group_by(countrycode) %>%
    summarise(
      threshold = first(recession_threshold),
      mean_growth = first(country_mean_growth),
      sd_growth = first(country_sd_growth)
    ) %>%
    filter(!is.na(threshold))
  
  cat("\nDistribution of recession thresholds:\n")
  cat("Min threshold:", round(min(threshold_summary$threshold, na.rm = TRUE), 2), "%\n")
  cat("Median threshold:", round(median(threshold_summary$threshold, na.rm = TRUE), 2), "%\n")
  cat("Max threshold:", round(max(threshold_summary$threshold, na.rm = TRUE), 2), "%\n")
  
  return(recession_data)
}

# Applying to GDP data (country level)
recession_indicators <- create_country_specific_recession(gdp_data, n_sd = 1.5)

# Connecting to GPS individual level data: Function to calculate if individual experienced recession during formative years
calculate_recession_exposure <- function(final_data, recession_indicators) {
  # Initialize new columns
  final_data$recession_formative <- 0  
  final_data$n_recession_years <- 0
  final_data$recession_intensity <- 0
  final_data$recession_threshold_avg <- NA
  
  for (i in 1:nrow(final_data)) {
    iso <- final_data$isocode[i]
    
    # Defining formative years window (ages 3-18)
    start_year <- final_data$year_3[i]      
    end_year <- final_data$year_adult[i]    
    
    # Getting recession data for formative years
    recession_subset <- recession_indicators %>%
      filter(countrycode == iso & 
               year >= start_year &    
               year <= end_year)       
    
    if (nrow(recession_subset) > 0 && any(!is.na(recession_subset$recession))) {
      # Checking if ANY recession occurred during formative years
      final_data$recession_formative[i] <- ifelse(
        any(recession_subset$recession == 1, na.rm = TRUE), 1, 0
      )
      
      # Counting how many years had recessions during ages 3-18
      final_data$n_recession_years[i] <- sum(recession_subset$recession, na.rm = TRUE)
      
      # Storing average threshold for this country (for diagnostics)
      final_data$recession_threshold_avg[i] <- mean(recession_subset$recession_threshold, na.rm = TRUE)
      
      # Average negative growth during recession years (intensity)
      recession_years <- recession_subset %>% 
        filter(recession == 1)
      
      if (nrow(recession_years) > 0) {
        final_data$recession_intensity[i] <- mean(recession_years$gdppc_growth, na.rm = TRUE)
      }
    }
  }
  
  # Printing summary statistics
  cat("\n=== Recession Exposure Summary (Country-Specific) ===\n")
  cat("Total individuals:", nrow(final_data), "\n")
  cat("Individuals with valid recession data:", sum(!is.na(final_data$recession_threshold_avg)), "\n")
  cat("Individuals with recession exposure:", sum(final_data$recession_formative), "\n")
  cat("Percentage exposed to recession:", 
      round(mean(final_data$recession_formative) * 100, 2), "%\n")
  cat("Average number of recession years (among exposed):", 
      round(mean(final_data$n_recession_years[final_data$recession_formative == 1]), 2), "\n")
  cat("Average recession intensity (among exposed):", 
      round(mean(final_data$recession_intensity[final_data$recession_formative == 1]), 2), "%\n")
  
  return(final_data)
}

# Applying to our data
final_data_gdp <- calculate_recession_exposure(final_data_gdp, recession_indicators)

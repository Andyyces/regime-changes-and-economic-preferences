# Function to create country-level regime change data
create_country_regime_data <- function(democracy_data, threshold = 0.05, country_filter = NULL) {
  
  # Filtering for specific countries if provided
  if (!is.null(country_filter)) {
    democracy_data <- democracy_data %>%
      filter(country_text_id %in% country_filter)
  }
  
  # First identifying regime changes at country level
  country_regime_changes <- democracy_data %>%
    group_by(country_text_id) %>%
    arrange(year) %>%
    mutate(
      # Calculating rolling standard errors for confidence intervals
      v2x_libdem_rolling_sd = rollapply(v2x_libdem, width = 5,
                                        FUN = function(x) sd(x, na.rm = TRUE),
                                        fill = NA, align = "center"),
      v2x_libdem_rolling_n = rollapply(v2x_libdem, width = 5,
                                       FUN = function(x) sum(!is.na(x)),
                                       fill = NA, align = "center"),
      
      # Calculating confidence intervals
      country_sd = sd(v2x_libdem, na.rm = TRUE),
      country_n = n(),
      
      v2x_libdem_se = case_when(
        !is.na(v2x_libdem_rolling_sd) & v2x_libdem_rolling_n > 1 ~
          v2x_libdem_rolling_sd / sqrt(v2x_libdem_rolling_n),
        TRUE ~ country_sd / sqrt(country_n)
      ),
      
      df = case_when(
        !is.na(v2x_libdem_rolling_n) & v2x_libdem_rolling_n > 1 ~
          v2x_libdem_rolling_n - 1,
        TRUE ~ country_n - 1
      ),
      
      t_stat = qt(0.975, df = df),
      ci_lower = v2x_libdem - t_stat * v2x_libdem_se,
      ci_upper = v2x_libdem + t_stat * v2x_libdem_se,
      
      # Look at 10-year changes
      libdem_diff = v2x_libdem - lag(v2x_libdem, 10),
      ci_lower_lag10 = lag(ci_lower, 10),
      ci_upper_lag10 = lag(ci_upper, 10),
      
      # Checking for non-overlapping confidence intervals
      ci_non_overlapping = case_when(
        is.na(ci_lower) | is.na(ci_upper_lag10) ~ 0,
        ci_lower > ci_upper_lag10 | ci_upper < ci_lower_lag10 ~ 1,
        TRUE ~ 0
      ),
      
      # Identifying regime changes
      regime_change = ifelse(ci_non_overlapping == 1 & 
                               !is.na(libdem_diff) & 
                               abs(libdem_diff) > threshold, 1, 0),
      
      # Creating treatment variable with 3 categories
      treatment = case_when(
        regime_change == 1 & libdem_diff > 0 ~ 2,  # Democratization
        regime_change == 1 & libdem_diff < 0 ~ 1,  # Autocratization
        TRUE ~ 0  # No regime change
      ),
      
      # Creating factor with labels
      treatment_factor = factor(treatment,
                                levels = c(0, 1, 2),
                                labels = c("No change", "Autocratization", "Democratization"))
    ) %>%
    select(country_text_id, country_name, year, v2x_libdem, treatment, treatment_factor)
  
  return(country_regime_changes)
}

# Getting unique countries from gps_sub
countries_to_analyze <- unique(gps_sub$isocode)

# Creating dataframe the country-level data for selected countries only
country_data <- create_country_regime_data(vdem_sub, 
                                           threshold = 0.2,
                                           country_filter = countries_to_analyze)

# Filtering for periods after 1920
country_data <- country_data %>%
  filter(year > 1920)

# Long format for easier merging
# Creating binary indicators for each treatment type
country_data_binary <- country_data %>%
  mutate(
    autocratization = ifelse(treatment == 1, 1, 0),
    democratization = ifelse(treatment == 2, 1, 0),
    any_change = ifelse(treatment != 0, 1, 0)
  )
saveRDS(country_data, file = here("Input", "clean", "country_data.rds"))
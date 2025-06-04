# Function to merge country-level regime change data with individual GPS data
merge_regime_changes_with_individuals <- function(gps_data, country_data_binary) {
  
  # First, reshaping country data to have one row per regime change
  # Extract all regime changes (where treatment != 0)
  regime_changes_long <- country_data_binary %>%
    filter(treatment != 0) %>%
    select(country_text_id, year, treatment, autocratization, democratization) %>%
    rename(regime_change_year = year)
  
  # Joining with GPS data
  # Each individual gets matched with all regime changes in their country
  merged_data <- gps_data %>%
    left_join(regime_changes_long,
              by = c("isocode" = "country_text_id"),
              relationship = "many-to-many") %>%
    mutate(
      # Calculate age at regime change
      age_at_regime_change = regime_change_year - birth_year,
      
      # Check if regime change occurred during formative years (ages 3-18)
      experienced_formative_change = case_when(
        is.na(regime_change_year) ~ 0,
        age_at_regime_change >= 3 & age_at_regime_change <= 18 ~ 1,
        TRUE ~ 0
      ),
      
      # Type of change experienced during formative years
      formative_autocratization = experienced_formative_change * autocratization,
      formative_democratization = experienced_formative_change * democratization
    )
  # Aggregating to individual level - one row per person
  individual_summary <- merged_data %>%
    group_by(id_gallup) %>%
    summarize(
      # Keeping all original individual variables (take first value)
      across(c(age, country, isocode, region, patience, risktaking, posrecip, negrecip, altruism, trust, subj_math_skills, gender,  birth_year, year_3, year_adult), 
             ~first(.)),
      
      # Treatment indicators - handle cases with no regime changes
      formative_regime_change = if(all(is.na(experienced_formative_change))) 0 else max(experienced_formative_change, na.rm = TRUE),
      formative_autocratization = if(all(is.na(formative_autocratization))) 0 else max(formative_autocratization, na.rm = TRUE),
      formative_democratization = if(all(is.na(formative_democratization))) 0 else max(formative_democratization, na.rm = TRUE),
      
      # Count of regime changes
      n_formative_changes = sum(experienced_formative_change, na.rm = TRUE),
      n_formative_autocratizations = sum(formative_autocratization, na.rm = TRUE),
      n_formative_democratizations = sum(formative_democratization, na.rm = TRUE),
      
      # Details of first formative regime change
      first_formative_year = ifelse(
        any(experienced_formative_change == 1, na.rm = TRUE),
        min(regime_change_year[experienced_formative_change == 1], na.rm = TRUE),
        NA_real_
      ),
      first_formative_age = ifelse(
        any(experienced_formative_change == 1, na.rm = TRUE),
        min(age_at_regime_change[experienced_formative_change == 1], na.rm = TRUE),
        NA_real_
      ),
      first_formative_type = case_when(
        any(experienced_formative_change == 1, na.rm = TRUE) ~ 
          first(treatment[experienced_formative_change == 1]),
        TRUE ~ 0
      ),
      
      # List of all formative regime change years (if needed)
      all_formative_years = list(regime_change_year[experienced_formative_change == 1]),
      all_formative_ages = list(age_at_regime_change[experienced_formative_change == 1]),
      
      .groups = "drop"
    )
  
  # Print summary statistics
  cat("\n=== Summary Statistics ===\n")
  cat("Total individuals:", nrow(individual_summary), "\n")
  cat("Individuals with formative regime changes:", 
      sum(individual_summary$formative_regime_change), "\n")
  cat("- Experienced autocratization:", 
      sum(individual_summary$formative_autocratization), "\n")
  cat("- Experienced democratization:", 
      sum(individual_summary$formative_democratization), "\n")
  cat("Average age at first formative change:", 
      round(mean(individual_summary$first_formative_age, na.rm = TRUE), 2), "\n")
  
  # Create frequency table
  cat("\nFormative regime change distribution:\n")
  print(table(individual_summary$formative_regime_change))
  
  return(individual_summary)
}

# Applying to our data
final_data <- merge_regime_changes_with_individuals(gps_sub, country_data_binary)
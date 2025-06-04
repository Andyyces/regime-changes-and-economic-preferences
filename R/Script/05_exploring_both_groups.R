# First, identify countries that experienced ANY regime changes during your study period
countries_with_regime_changes <- country_data %>%
  filter(treatment != 0) %>%  # Any regime change (democratization or autocratization)
  distinct(country_text_id) %>%
  pull(country_text_id)

# Cleaning
final_data_clean <- final_data %>%
  mutate(
    # Create a cleaner treatment variable
    clean_treatment = case_when(
      formative_regime_change == 1 ~ 1,                    # Treated: experienced change during formative years (no need to differenciate here)
      !isocode %in% countries_with_regime_changes ~ 0,     # Pure control: from stable countries
      TRUE ~ NA_real_                                      # Contaminated: delete these
    )
  ) %>%
  filter(!is.na(clean_treatment))  # Remove contaminated controls

# Checking the new sample sizes
table(final_data_clean$clean_treatment)

# First approach: Country counts by treatment type
country_breakdown <- final_data_clean %>%
  group_by(first_formative_type, country) %>%
  summarise(n_individuals = n(), .groups = "drop") %>%
  arrange(first_formative_type, desc(n_individuals))

print("Country breakdown by treatment type:")
print(country_breakdown)

# Different approach: Summary table - countries per treatment type
country_summary <- final_data_clean %>%
  group_by(first_formative_type) %>%
  summarise(
    n_individuals = n(),
    n_countries = n_distinct(country),
    countries = paste(unique(country), collapse = ", "),
    .groups = "drop"
  )

print("Summary by treatment type:")
print(country_summary)

# Different approach: Focus on treated countries - which countries had which type of changes
treated_countries <- final_data_clean %>%
  filter(clean_treatment == 1) %>%
  group_by(country) %>%
  summarise(
    total_treated = n(),
    democratization = sum(formative_democratization),
    autocratization = sum(formative_autocratization),
    regime_change_type = case_when(
      democratization > 0 & autocratization == 0 ~ "Democratization only",
      autocratization > 0 & democratization == 0 ~ "Autocratization only", 
      democratization > 0 & autocratization > 0 ~ "Both types",
      TRUE ~ "Neither"
    ),
    .groups = "drop"
  ) %>%
  arrange(desc(total_treated))

print("Countries with treated individuals:")
print(treated_countries)
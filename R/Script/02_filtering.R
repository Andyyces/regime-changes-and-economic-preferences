#selecting necessary columns
vdem_sub <- vdem %>%
  select(country_name,country_text_id, year, v2x_libdem)

#calculating birth_years and selecting necessary columns
gps_sub <- GPS_indiv %>%
  mutate(birth_year = year(date) - age ) %>% mutate(year_3= birth_year + 3) %>% 
  select(id_gallup, age , date, country,isocode, region, patience, risktaking, posrecip, negrecip, altruism, trust, subj_math_skills, gender, birth_year, year_3)

gps_sub <- gps_sub %>%
  mutate(year = year(date)) %>% select(!date)

#Imagine the person faced with democracy at 18
gps_sub <- gps_sub %>%
  mutate(year_adult = birth_year + 18) 

gps_sub <- gps_sub %>%
  rename(interview_year = year)

#Keeping just complete cases and saving the observations containing NA's as a separate dataframe
gps_NA <- gps_sub %>%
  filter(!complete.cases(.))

gps_sub <- gps_sub %>%
  drop_na()
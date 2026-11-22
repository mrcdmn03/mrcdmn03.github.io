library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)
file_path <- "data_raw/hour01sajun2026.xls"

excel_sheets(file_path)
hour01_sa_raw <- read_excel(
  path = file_path,
  sheet = "People",
  col_names = FALSE
)
head(hour01_sa_raw, 20)
hour01_sa_clean <- hour01_sa_raw %>%
  slice(11:n()) %>%
  select(
    period = ...1,
    total_weekly_hours_millions = ...2,
    all_workers_hours = ...3,
    full_time_workers_hours = ...4,
    part_time_workers_hours = ...5,
    second_jobs_hours = ...6
  ) %>%
  filter(!is.na(period)) %>%
  mutate(
    total_weekly_hours_millions = as.numeric(total_weekly_hours_millions),
    all_workers_hours = as.numeric(all_workers_hours),
    full_time_workers_hours = as.numeric(full_time_workers_hours),
    part_time_workers_hours = as.numeric(part_time_workers_hours),
    second_jobs_hours = as.numeric(second_jobs_hours)
  )
colSums(is.na(hour01_sa_clean))
hour01_sa_clean %>%
  filter(!is.na(all_workers_hours)) %>%
  head(10)
hour01_sa_analysis <- hour01_sa_clean %>%
  filter(!is.na(all_workers_hours))
nrow(hour01_sa_analysis)

first(hour01_sa_analysis$period)

last(hour01_sa_analysis$period)
colSums(is.na(hour01_sa_analysis))
write.csv(
  hour01_sa_analysis,
  "data_clean/hour01_sa_analysis.csv",
  row.names = FALSE
)
ggplot(hour01_sa_analysis, aes(x = 1:nrow(hour01_sa_analysis), y = all_workers_hours)) +
  geom_line() +
  labs(
    title = "Average Actual Weekly Hours Worked: All Workers",
    subtitle = "HOUR01 SA, seasonally adjusted, Mar-May 1992 to Feb-Apr 2026",
    x = "Time period",
    y = "Average weekly hours"
  ) +
  theme_minimal()
p_hour01_sa_all_workers <- ggplot(hour01_sa_analysis, aes(x = 1:nrow(hour01_sa_analysis), y = all_workers_hours)) +
  geom_line() +
  labs(
    title = "Average Actual Weekly Hours Worked: All Workers",
    subtitle = "HOUR01 SA, seasonally adjusted, Mar-May 1992 to Feb-Apr 2026",
    x = "Time period",
    y = "Average weekly hours"
  ) +
  theme_minimal()

ggsave(
  filename = "figures/hour01_sa_all_workers_line_plot.png",
  plot = p_hour01_sa_all_workers,
  width = 8,
  height = 5,
  dpi = 300
)
hour01_sa_analysis <- hour01_sa_analysis %>%
  mutate(
    period_index = row_number(),
    year = as.numeric(str_extract(period, "\\d{4}"))
  )

head(hour01_sa_analysis)
p_hour01_sa_all_workers_year <- ggplot(hour01_sa_analysis, aes(x = period_index, y = all_workers_hours)) +
  geom_line() +
  scale_x_continuous(
    breaks = hour01_sa_analysis$period_index[hour01_sa_analysis$year %% 5 == 0],
    labels = hour01_sa_analysis$year[hour01_sa_analysis$year %% 5 == 0]
  ) +
  labs(
    title = "Average Actual Weekly Hours Worked: All Workers",
    subtitle = "HOUR01 SA, seasonally adjusted, Mar-May 1992 to Feb-Apr 2026",
    x = "Year",
    y = "Average weekly hours"
  ) +
  theme_minimal()

p_hour01_sa_all_workers_year
year_breaks <- hour01_sa_analysis %>%
  group_by(year) %>%
  summarise(period_index = first(period_index), .groups = "drop") %>%
  filter(year %% 5 == 0)

p_hour01_sa_all_workers_year <- ggplot(hour01_sa_analysis, aes(x = period_index, y = all_workers_hours)) +
  geom_line() +
  scale_x_continuous(
    breaks = year_breaks$period_index,
    labels = year_breaks$year
  ) +
  labs(
    title = "Average Actual Weekly Hours Worked: All Workers",
    subtitle = "HOUR01 SA, seasonally adjusted, Mar-May 1992 to Feb-Apr 2026",
    x = "Year",
    y = "Average weekly hours"
  ) +
  theme_minimal()

p_hour01_sa_all_workers_year
ggsave(
  filename = "figures/hour01_sa_all_workers_line_plot_year_axis.png",
  plot = p_hour01_sa_all_workers_year,
  width = 8,
  height = 5,
  dpi = 300
)
file_path_nsa <- "data_raw/hour01nsajun2026.xls"

excel_sheets(file_path_nsa)
library(readxl)
excel_sheets(file_path_nsa)
hour01_nsa_raw <- read_excel(
  path = file_path_nsa,
  sheet = "People",
  col_names = FALSE
)
head(hour01_nsa_raw, 20)
hour01_nsa_clean <- hour01_nsa_raw %>%
  slice(10:n()) %>%
  select(
    period = ...1,
    total_weekly_hours_millions = ...2,
    all_workers_hours = ...3,
    full_time_workers_hours = ...4,
    part_time_workers_hours = ...5,
    second_jobs_hours = ...6
  ) %>%
  filter(!is.na(period)) %>%
  mutate(
    total_weekly_hours_millions = as.numeric(total_weekly_hours_millions),
    all_workers_hours = as.numeric(all_workers_hours),
    full_time_workers_hours = as.numeric(full_time_workers_hours),
    part_time_workers_hours = as.numeric(part_time_workers_hours),
    second_jobs_hours = as.numeric(second_jobs_hours)
  )
library(dplyr)
hour01_nsa_clean <- hour01_nsa_raw %>%
  slice(10:n()) %>%
  select(
    period = ...1,
    total_weekly_hours_millions = ...2,
    all_workers_hours = ...3,
    full_time_workers_hours = ...4,
    part_time_workers_hours = ...5,
    second_jobs_hours = ...6
  ) %>%
  filter(!is.na(period)) %>%
  mutate(
    total_weekly_hours_millions = as.numeric(total_weekly_hours_millions),
    all_workers_hours = as.numeric(all_workers_hours),
    full_time_workers_hours = as.numeric(full_time_workers_hours),
    part_time_workers_hours = as.numeric(part_time_workers_hours),
    second_jobs_hours = as.numeric(second_jobs_hours)
  )
nrow(hour01_nsa_clean)

first(hour01_nsa_clean$period)

last(hour01_nsa_clean$period)

colSums(is.na(hour01_nsa_clean))
hour01_nsa_analysis <- hour01_nsa_clean %>%
  filter(!is.na(all_workers_hours))

nrow(hour01_nsa_analysis)

first(hour01_nsa_analysis$period)

last(hour01_nsa_analysis$period)

colSums(is.na(hour01_nsa_analysis))
write.csv(
  hour01_nsa_analysis,
  "data_clean/hour01_nsa_analysis.csv",
  row.names = FALSE
)
hour01_nsa_analysis <- hour01_nsa_analysis %>%
  mutate(
    period_index = row_number(),
    year = as.numeric(str_extract(period, "\\d{4}"))
  )

head(hour01_nsa_analysis)
library(stringr)
hour01_nsa_analysis <- hour01_nsa_analysis %>%
  mutate(
    period_index = row_number(),
    year = as.numeric(str_extract(period, "\\d{4}"))
  )

head(hour01_nsa_analysis)
library(ggplot2)
year_breaks_nsa <- hour01_nsa_analysis %>%
  group_by(year) %>%
  summarise(period_index = first(period_index), .groups = "drop") %>%
  filter(year %% 5 == 0)

p_hour01_nsa_all_workers_year <- ggplot(hour01_nsa_analysis, aes(x = period_index, y = all_workers_hours)) +
  geom_line() +
  scale_x_continuous(
    breaks = year_breaks_nsa$period_index,
    labels = year_breaks_nsa$year
  ) +
  labs(
    title = "Average Actual Weekly Hours Worked: All Workers",
    subtitle = "HOUR01 NSA, not seasonally adjusted, Mar-May 1992 to Feb-Apr 2026",
    x = "Year",
    y = "Average weekly hours"
  ) +
  theme_minimal()

p_hour01_nsa_all_workers_year
ggsave(
  filename = "figures/hour01_nsa_all_workers_line_plot_year_axis.png",
  plot = p_hour01_nsa_all_workers_year,
  width = 8,
  height = 5,
  dpi = 300
)
hour01_sa_compare <- hour01_sa_analysis %>%
  select(period, period_index, year, all_workers_hours) %>%
  mutate(adjustment = "Seasonally adjusted")

hour01_nsa_compare <- hour01_nsa_analysis %>%
  select(period, period_index, year, all_workers_hours) %>%
  mutate(adjustment = "Not seasonally adjusted")

hour01_sa_nsa_compare <- bind_rows(
  hour01_sa_compare,
  hour01_nsa_compare
)

head(hour01_sa_nsa_compare)

nrow(hour01_sa_nsa_compare)
p_hour01_sa_vs_nsa <- ggplot(
  hour01_sa_nsa_compare,
  aes(x = period_index, y = all_workers_hours, linetype = adjustment)
) +
  geom_line() +
  scale_x_continuous(
    breaks = year_breaks$period_index,
    labels = year_breaks$year
  ) +
  labs(
    title = "Seasonally Adjusted vs Not Seasonally Adjusted Average Weekly Hours",
    subtitle = "HOUR01, all workers, Mar-May 1992 to Feb-Apr 2026",
    x = "Year",
    y = "Average weekly hours",
    linetype = "Series"
  ) +
  theme_minimal()

p_hour01_sa_vs_nsa
ggsave(
  filename = "figures/hour01_sa_vs_nsa_all_workers_comparison.png",
  plot = p_hour01_sa_vs_nsa,
  width = 8,
  height = 5,
  dpi = 300
)
file_path_hour02_sa <- "data_raw/hour02sajun2026.xls"

excel_sheets(file_path_hour02_sa)
hour02_sa_raw <- read_excel(
  path = file_path_hour02_sa,
  sheet = "People",
  col_names = FALSE
)
head(hour02_sa_raw, 20)
hour01_sa_summary <- hour01_sa_analysis %>%
  summarise(
    observations = n(),
    start_period = first(period),
    end_period = last(period),
    mean_hours = mean(all_workers_hours),
    median_hours = median(all_workers_hours),
    min_hours = min(all_workers_hours),
    max_hours = max(all_workers_hours),
    sd_hours = sd(all_workers_hours)
  )

hour01_sa_summary
write.csv(
  hour01_sa_summary,
  "data_clean/hour01_sa_summary_statistics.csv",
  row.names = FALSE
)
hour01_sa_analysis %>%
  filter(all_workers_hours == min(all_workers_hours)) %>%
  select(period, all_workers_hours)

hour01_sa_analysis %>%
  filter(all_workers_hours == max(all_workers_hours)) %>%
  select(period, all_workers_hours)
hour01_sa_min_max <- bind_rows(
  hour01_sa_analysis %>%
    filter(all_workers_hours == min(all_workers_hours)) %>%
    select(period, all_workers_hours) %>%
    mutate(statistic = "Minimum"),
  
  hour01_sa_analysis %>%
    filter(all_workers_hours == max(all_workers_hours)) %>%
    select(period, all_workers_hours) %>%
    mutate(statistic = "Maximum")
) %>%
  select(statistic, period, all_workers_hours)

hour01_sa_min_max

write.csv(
  hour01_sa_min_max,
  "data_clean/hour01_sa_min_max_values.csv",
  row.names = FALSE
)
hour01_sa_covid_period <- hour01_sa_analysis %>%
  filter(year >= 2018 & year <= 2022)

nrow(hour01_sa_covid_period)

first(hour01_sa_covid_period$period)

last(hour01_sa_covid_period$period)

head(hour01_sa_covid_period)
p_hour01_sa_covid_zoom <- ggplot(hour01_sa_covid_period, aes(x = period_index, y = all_workers_hours)) +
  geom_line() +
  geom_point() +
  scale_x_continuous(
    breaks = hour01_sa_covid_period$period_index[seq(1, nrow(hour01_sa_covid_period), by = 6)],
    labels = hour01_sa_covid_period$period[seq(1, nrow(hour01_sa_covid_period), by = 6)]
  ) +
  labs(
    title = "Average Actual Weekly Hours Worked During the COVID-19 Period",
    subtitle = "HOUR01 SA, all workers, 2018 to 2022",
    x = "Period",
    y = "Average weekly hours"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

p_hour01_sa_covid_zoom
ggsave(
  filename = "figures/hour01_sa_covid_period_zoom.png",
  plot = p_hour01_sa_covid_zoom,
  width = 8,
  height = 5,
  dpi = 300
)
write.csv(
  hour01_sa_covid_period,
  "data_clean/hour01_sa_covid_period.csv",
  row.names = FALSE
)
hour01_sa_covid_summary <- hour01_sa_covid_period %>%
  summarise(
    observations = n(),
    start_period = first(period),
    end_period = last(period),
    mean_hours = mean(all_workers_hours),
    median_hours = median(all_workers_hours),
    min_hours = min(all_workers_hours),
    max_hours = max(all_workers_hours),
    sd_hours = sd(all_workers_hours)
  )

hour01_sa_covid_summary
write.csv(
  hour01_sa_covid_summary,
  "data_clean/hour01_sa_covid_summary_statistics.csv",
  row.names = FALSE
)
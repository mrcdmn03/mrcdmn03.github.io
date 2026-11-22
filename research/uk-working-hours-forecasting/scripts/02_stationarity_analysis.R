# Stationarity analysis
# ONS HOUR01 seasonally adjusted series

hour01_sa <- read.csv("data_clean/hour01_sa_analysis.csv")
# Check the imported data

nrow(hour01_sa)
names(hour01_sa)
head(hour01_sa)
tail(hour01_sa)
# Select the target variable

all_workers <- hour01_sa$all_workers_hours

length(all_workers)
class(all_workers)
sum(is.na(all_workers))
# Check train-test boundary

hour01_sa[326, c("period", "all_workers_hours")]
hour01_sa[327, c("period", "all_workers_hours")]
# Create training and test sets

train_values <- all_workers[1:326]
test_values  <- all_workers[327:408]

length(train_values)
length(test_values)
# Convert training and test data to time-series objects

train_ts <- ts(
  train_values,
  start = c(1992, 5),
  frequency = 12
)

test_ts <- ts(
  test_values,
  start = c(2019, 7),
  frequency = 12
)

start(train_ts)
end(train_ts)
frequency(train_ts)

start(test_ts)
end(test_ts)
frequency(test_ts)
# Plot the training series

plot(
  train_ts,
  type = "l",
  main = "ONS HOUR01 SA - Training Series",
  xlab = "Year",
  ylab = "Average actual weekly hours",
  lwd = 2
)
# Load package for stationarity tests

library(tseries)
# Augmented Dickey-Fuller test

adf_result <- adf.test(train_ts)
adf_result
# KPSS test for level stationarity

kpss_result <- kpss.test(train_ts, null = "Level")
kpss_result
# First difference of the training series

train_diff1 <- diff(train_ts)

length(train_diff1)

plot(
  train_diff1,
  type = "l",
  main = "First-Differenced ONS HOUR01 SA Training Series",
  xlab = "Year",
  ylab = "Change in average weekly hours",
  lwd = 2
)
# Stationarity tests after first differencing

adf_diff1 <- adf.test(train_diff1)
adf_diff1

kpss_diff1 <- kpss.test(train_diff1, null = "Level")
kpss_diff1
# Stationarity conclusion:
# Original training series is non-stationary:
# ADF p = 0.9649; KPSS p = 0.01
#
# First-differenced series is stationary:
# ADF p < 0.01; KPSS p > 0.10
#
# Therefore, non-seasonal differencing order d = 1

# ACF of the first-differenced training series

acf(
  train_diff1,
  lag.max = 36,
  main = "ACF of First-Differenced Training Series"
)
# PACF of the first-differenced training series

pacf(
  train_diff1,
  lag.max = 36,
  main = "PACF of First-Differenced Training Series"
)
# Extract numerical ACF and PACF values

acf_values <- acf(train_diff1, lag.max = 36, plot = FALSE)
pacf_values <- pacf(train_diff1, lag.max = 36, plot = FALSE)

acf_values$acf[2:13]
pacf_values$acf[1:12]
# Check seasonal lags 12, 24 and 36

acf_values$acf[c(13, 25, 37)]
pacf_values$acf[c(12, 24, 36)]
library(forecast)
# Check recommended seasonal differencing

nsdiffs(train_ts)
# Manual candidate ARIMA models

model_110 <- Arima(
  train_ts,
  order = c(1, 1, 0),
  include.drift = FALSE,
  method = "ML"
)

model_011 <- Arima(
  train_ts,
  order = c(0, 1, 1),
  include.drift = FALSE,
  method = "ML"
)

model_310 <- Arima(
  train_ts,
  order = c(3, 1, 0),
  include.drift = FALSE,
  method = "ML"
)

model_013 <- Arima(
  train_ts,
  order = c(0, 1, 3),
  include.drift = FALSE,
  method = "ML"
)

model_111 <- Arima(
  train_ts,
  order = c(1, 1, 1),
  include.drift = FALSE,
  method = "ML"
)
# Store manual models together

manual_models <- list(
  "ARIMA(1,1,0)" = model_110,
  "ARIMA(0,1,1)" = model_011,
  "ARIMA(3,1,0)" = model_310,
  "ARIMA(0,1,3)" = model_013,
  "ARIMA(1,1,1)" = model_111
)
# Compare manual candidates using AICc and BIC

manual_comparison <- data.frame(
  Model = names(manual_models),
  AICc = sapply(manual_models, function(x) x$aicc),
  BIC = sapply(manual_models, function(x) x$bic)
)

manual_comparison <- manual_comparison[
  order(manual_comparison$AICc),
]

manual_comparison
# Manual model comparison:
# ARIMA(0,1,3) had the lowest AICc and BIC among the initial manual candidates.
# ARIMA(3,1,0) was the second-best candidate.
# Final model selection requires automated search and residual diagnostics.

# Automated non-seasonal ARIMA search

auto_nonseasonal <- auto.arima(
  train_ts,
  d = 1,
  D = 0,
  max.p = 5,
  max.q = 5,
  seasonal = FALSE,
  stepwise = FALSE,
  approximation = FALSE,
  allowdrift = TRUE,
  allowmean = FALSE,
  ic = "aicc"
)

auto_nonseasonal
# Automated non-seasonal ARIMA search selected ARIMA(0,1,5).
# AICc = -628.06 and BIC = -605.62.
# This improves AICc over the best manual candidate ARIMA(0,1,3),
# although the BIC difference is small.
# Drift was allowed but was not selected.

# Automated seasonal ARIMA search

auto_seasonal <- auto.arima(
  train_ts,
  d = 1,
  D = 0,
  max.p = 5,
  max.q = 5,
  max.P = 2,
  max.Q = 2,
  max.order = 14,
  seasonal = TRUE,
  stepwise = FALSE,
  approximation = FALSE,
  allowdrift = TRUE,
  allowmean = FALSE,
  ic = "aicc"
)

auto_seasonal
# Residual diagnostics for ARIMA(0,1,5)

checkresiduals(auto_seasonal)
# Residual diagnostics for ARIMA(0,1,3)

checkresiduals(model_013)
# Inspect coefficient estimates

model_013
auto_seasonal
model_013
# Additional parsimonious candidate: ARIMA(0,1,4)

model_014 <- Arima(
  train_ts,
  order = c(0, 1, 4),
  include.drift = FALSE,
  method = "ML"
)

model_014
# Residual diagnostics for ARIMA(0,1,4)

checkresiduals(model_014)
# Model selection conclusion:
# ARIMA(0,1,5) had the lowest AICc, but ARIMA(0,1,4)
# produced a very similar AICc, a lower BIC, and satisfactory
# residual diagnostics.
#
# ARIMA(0,1,4) is therefore selected as the preferred
# parsimonious specification for out-of-sample evaluation.
#
# Ljung-Box p-value for ARIMA(0,1,4) = 0.2917.

# Expanding-window one-step-ahead forecast setup

arima_forecasts <- numeric(length(test_values))
naive_forecasts <- numeric(length(test_values))
length(arima_forecasts)
length(naive_forecasts)

head(arima_forecasts)
head(naive_forecasts)
# Expanding-window one-step-ahead forecasting

history_values <- train_values

for (i in seq_along(test_values)) {
  
  # Convert the currently available history to a time-series object
  history_ts <- ts(
    history_values,
    start = c(1992, 5),
    frequency = 12
  )
  
  # Re-estimate ARIMA(0,1,4) using all information available at this point
  fit_i <- Arima(
    history_ts,
    order = c(0, 1, 4),
    include.drift = FALSE,
    method = "ML"
  )
  
  # One-step-ahead ARIMA forecast
  arima_forecasts[i] <- as.numeric(
    forecast(fit_i, h = 1)$mean[1]
  )
  
  # Naïve forecast: use the latest observed value
  naive_forecasts[i] <- tail(history_values, 1)
  
  # Add the newly observed actual value to the expanding window
  history_values <- c(
    history_values,
    test_values[i]
  )
}
head(arima_forecasts)
head(naive_forecasts)

tail(arima_forecasts)
tail(naive_forecasts)

sum(arima_forecasts == 0)
sum(naive_forecasts == 0)
# Create out-of-sample forecast results table

forecast_results <- data.frame(
  period = hour01_sa$period[327:408],
  actual = test_values,
  arima_forecast = arima_forecasts,
  naive_forecast = naive_forecasts
)

head(forecast_results)
tail(forecast_results)
nrow(forecast_results)
# Calculate forecast errors

forecast_results$arima_error <- forecast_results$actual - forecast_results$arima_forecast
forecast_results$naive_error <- forecast_results$actual - forecast_results$naive_forecast

head(forecast_results)

# Overall out-of-sample accuracy metrics

# MAE
arima_mae <- mean(abs(forecast_results$arima_error))
naive_mae <- mean(abs(forecast_results$naive_error))

# RMSE
arima_rmse <- sqrt(mean(forecast_results$arima_error^2))
naive_rmse <- sqrt(mean(forecast_results$naive_error^2))

# MAPE
arima_mape <- mean(
  abs(forecast_results$arima_error / forecast_results$actual)
) * 100

naive_mape <- mean(
  abs(forecast_results$naive_error / forecast_results$actual)
) * 100

# MASE scaling term based on the training series
mase_scale <- mean(abs(diff(train_values)))

# MASE
arima_mase <- mean(abs(forecast_results$arima_error)) / mase_scale
naive_mase <- mean(abs(forecast_results$naive_error)) / mase_scale

# Create overall accuracy table

overall_accuracy <- data.frame(
  Model = c("ARIMA(0,1,4)", "Naive"),
  MAE = c(arima_mae, naive_mae),
  RMSE = c(arima_rmse, naive_rmse),
  MAPE = c(arima_mape, naive_mape),
  MASE = c(arima_mase, naive_mase)
)

overall_accuracy
# Define pre-COVID, COVID-affected and post-COVID periods

forecast_results$subperiod <- c(
  rep("Pre-COVID", 8),
  rep("COVID-affected", 24),
  rep("Post-COVID", 50)
)

table(forecast_results$subperiod)
# Accuracy metrics by subperiod

subperiod_accuracy <- do.call(
  rbind,
  lapply(unique(forecast_results$subperiod), function(p) {
    
    temp <- forecast_results[
      forecast_results$subperiod == p,
    ]
    
    data.frame(
      Subperiod = p,
      
      ARIMA_MAE = mean(abs(temp$arima_error)),
      Naive_MAE = mean(abs(temp$naive_error)),
      
      ARIMA_RMSE = sqrt(mean(temp$arima_error^2)),
      Naive_RMSE = sqrt(mean(temp$naive_error^2)),
      
      ARIMA_MAPE = mean(
        abs(temp$arima_error / temp$actual)
      ) * 100,
      
      Naive_MAPE = mean(
        abs(temp$naive_error / temp$actual)
      ) * 100,
      
      ARIMA_MASE = mean(abs(temp$arima_error)) / mase_scale,
      Naive_MASE = mean(abs(temp$naive_error)) / mase_scale
    )
  })
)

subperiod_accuracy

# Subperiod evaluation conclusion:
# Naive forecasts performed slightly better during the pre-COVID
# and post-COVID periods.
#
# ARIMA(0,1,4) performed better during the COVID-affected period
# across MAE, RMSE, MAPE and MASE.
#
# Therefore, the overall advantage of ARIMA is not uniform over time
# and appears to be driven mainly by its stronger relative performance
# during the COVID-affected period.

# Create monthly date index for the test period

forecast_results$date <- seq(
  from = as.Date("2019-07-01"),
  by = "month",
  length.out = nrow(forecast_results)
)

# Plot actual values against ARIMA and naive forecasts

plot(
  forecast_results$date,
  forecast_results$actual,
  type = "l",
  lwd = 2,
  xlab = "Year",
  ylab = "Average actual weekly hours",
  main = "Out-of-Sample Forecast Performance"
)

lines(
  forecast_results$date,
  forecast_results$arima_forecast,
  lwd = 2,
  lty = 2
)

lines(
  forecast_results$date,
  forecast_results$naive_forecast,
  lwd = 2,
  lty = 3
)

legend(
  "bottomright",
  legend = c("Actual", "ARIMA(0,1,4)", "Naive"),
  lty = c(1, 2, 3),
  lwd = 2,
  bty = "n"
)
# COVID-period forecast comparison

covid_plot_data <- forecast_results[
  forecast_results$date >= as.Date("2020-01-01") &
    forecast_results$date <= as.Date("2022-12-01"),
]

plot(
  covid_plot_data$date,
  covid_plot_data$actual,
  type = "l",
  lwd = 2,
  xlab = "Year",
  ylab = "Average actual weekly hours",
  main = "COVID-period Forecast Performance"
)

lines(
  covid_plot_data$date,
  covid_plot_data$arima_forecast,
  lwd = 2,
  lty = 2
)

lines(
  covid_plot_data$date,
  covid_plot_data$naive_forecast,
  lwd = 2,
  lty = 3
)

legend(
  "bottomright",
  legend = c("Actual", "ARIMA(0,1,4)", "Naive"),
  lty = c(1,2,3),
  lwd = 2,
  bty = "n"
)
# --------------------------------------------------
# Sensitivity analysis: non-overlapping series
# --------------------------------------------------

# Select every third observation to remove overlap

hour01_nonoverlap <- hour01_sa[seq(3, nrow(hour01_sa), by = 3), ]

nrow(hour01_nonoverlap)
head(hour01_nonoverlap[, c("period", "all_workers_hours")])
tail(hour01_nonoverlap[, c("period", "all_workers_hours")])
# Convert non-overlapping series to quarterly time series

nonoverlap_ts <- ts(
  hour01_nonoverlap$all_workers_hours,
  start = c(1992, 2),
  frequency = 4
)

length(nonoverlap_ts)
frequency(nonoverlap_ts)
start(nonoverlap_ts)
end(nonoverlap_ts)
# Sensitivity analysis train-test split

nonoverlap_train <- window(
  nonoverlap_ts,
  end = c(2019, 2)
)

nonoverlap_test <- window(
  nonoverlap_ts,
  start = c(2019, 3)
)

length(nonoverlap_train)
length(nonoverlap_test)

start(nonoverlap_train)
end(nonoverlap_train)

start(nonoverlap_test)
end(nonoverlap_test)
# Stationarity tests for non-overlapping training series

adf_nonoverlap <- adf.test(nonoverlap_train)
adf_nonoverlap

kpss_nonoverlap <- kpss.test(nonoverlap_train, null = "Level")
kpss_nonoverlap
# First difference for non-overlapping series

nonoverlap_diff1 <- diff(nonoverlap_train)

length(nonoverlap_diff1)

plot(
  nonoverlap_diff1,
  type = "l",
  main = "First Difference of Non-overlapping Training Series",
  xlab = "Time",
  ylab = "Change in working hours",
  lwd = 2
)
# Stationarity tests after first differencing (non-overlapping)

adf_nonoverlap_diff1 <- adf.test(nonoverlap_diff1)

adf_nonoverlap_diff1


kpss_nonoverlap_diff1 <- kpss.test(
  nonoverlap_diff1,
  null = "Level"
)

kpss_nonoverlap_diff1
# Stationarity tests after first differencing (non-overlapping)

adf_nonoverlap_diff1 <- adf.test(nonoverlap_diff1)

adf_nonoverlap_diff1


kpss_nonoverlap_diff1 <- kpss.test(
  nonoverlap_diff1,
  null = "Level"
)

kpss_nonoverlap_diff1
acf(
  nonoverlap_diff1,
  lag.max = 12,
  main = "ACF of First-Differenced Non-overlapping Training Series"
)

pacf(
  nonoverlap_diff1,
  lag.max = 12,
  main = "PACF of First-Differenced Non-overlapping Training Series"
)

library(forecast)

non_model_110 <- Arima(
  nonoverlap_train,
  order = c(1,1,0),
  include.drift = FALSE,
  method = "ML"
)

non_model_011 <- Arima(
  nonoverlap_train,
  order = c(0,1,1),
  include.drift = FALSE,
  method = "ML"
)

non_model_020 <- Arima(
  nonoverlap_train,
  order = c(0,1,2),
  include.drift = FALSE,
  method = "ML"
)

non_model_111 <- Arima(
  nonoverlap_train,
  order = c(1,1,1),
  include.drift = FALSE,
  method = "ML"
)

non_model_013 <- Arima(
  nonoverlap_train,
  order = c(0,1,3),
  include.drift = FALSE,
  method = "ML"
)

non_manual_models <- list(
  "ARIMA(1,1,0)" = non_model_110,
  "ARIMA(0,1,1)" = non_model_011,
  "ARIMA(0,1,2)" = non_model_020,
  "ARIMA(1,1,1)" = non_model_111,
  "ARIMA(0,1,3)" = non_model_013
)


non_manual_comparison <- data.frame(
  Model = names(non_manual_models),
  AICc = sapply(non_manual_models, function(x) x$aicc),
  BIC = sapply(non_manual_models, function(x) x$bic)
)

non_manual_comparison[
  order(non_manual_comparison$AICc),
]
non_best_model <- non_model_110

non_best_model

checkresiduals(non_best_model)
non_auto <- auto.arima(
  nonoverlap_train,
  d = 1,
  seasonal = FALSE,
  stepwise = FALSE,
  approximation = FALSE,
  allowdrift = TRUE,
  allowmean = FALSE,
  ic = "aicc"
)

non_auto

checkresiduals(non_auto)

# Forecast objects for non-overlapping sensitivity analysis

non_arima110_forecasts <- numeric(length(nonoverlap_test))
non_arima211_forecasts <- numeric(length(nonoverlap_test))
non_naive_forecasts <- numeric(length(nonoverlap_test))


# Expanding-window forecasting

history_non <- as.numeric(nonoverlap_train)


for (i in seq_along(nonoverlap_test)) {
  
  history_ts_non <- ts(
    history_non,
    start = c(1992, 2),
    frequency = 4
  )
  
  
  # ARIMA(1,1,0)
  fit_110 <- Arima(
    history_ts_non,
    order = c(1,1,0),
    include.drift = FALSE,
    method = "ML"
  )
  
  
  non_arima110_forecasts[i] <- as.numeric(
    forecast(fit_110, h = 1)$mean[1]
  )
  
  
  # ARIMA(2,1,1)
  fit_211 <- Arima(
    history_ts_non,
    order = c(2,1,1),
    include.drift = FALSE,
    method = "ML"
  )
  
  
  non_arima211_forecasts[i] <- as.numeric(
    forecast(fit_211, h = 1)$mean[1]
  )
  
  
  # Naive
  non_naive_forecasts[i] <- tail(history_non, 1)
  
  
  # Expand window
  history_non <- c(
    history_non,
    nonoverlap_test[i]
  )
  
}

head(non_arima110_forecasts)
head(non_arima211_forecasts)
head(non_naive_forecasts)

length(non_arima110_forecasts)
length(non_arima211_forecasts)
length(non_naive_forecasts)

sum(is.na(non_arima110_forecasts))
sum(is.na(non_arima211_forecasts))
sum(is.na(non_naive_forecasts))

non_forecast_results <- data.frame(
  actual = as.numeric(nonoverlap_test),
  ARIMA_110 = non_arima110_forecasts,
  ARIMA_211 = non_arima211_forecasts,
  Naive = non_naive_forecasts
)

head(non_forecast_results)

non_forecast_results$ARIMA_110_error <- 
  non_forecast_results$actual - non_forecast_results$ARIMA_110

non_forecast_results$ARIMA_211_error <- 
  non_forecast_results$actual - non_forecast_results$ARIMA_211

non_forecast_results$Naive_error <- 
  non_forecast_results$actual - non_forecast_results$Naive

non_mase_scale <- mean(abs(diff(as.numeric(nonoverlap_train))))


non_accuracy <- data.frame(
  
  Model = c(
    "ARIMA(1,1,0)",
    "ARIMA(2,1,1)",
    "Naive"
  ),
  
  MAE = c(
    mean(abs(non_forecast_results$ARIMA_110_error)),
    mean(abs(non_forecast_results$ARIMA_211_error)),
    mean(abs(non_forecast_results$Naive_error))
  ),
  
  RMSE = c(
    sqrt(mean(non_forecast_results$ARIMA_110_error^2)),
    sqrt(mean(non_forecast_results$ARIMA_211_error^2)),
    sqrt(mean(non_forecast_results$Naive_error^2))
  ),
  
  MAPE = c(
    mean(abs(non_forecast_results$ARIMA_110_error /
               non_forecast_results$actual))*100,
    
    mean(abs(non_forecast_results$ARIMA_211_error /
               non_forecast_results$actual))*100,
    
    mean(abs(non_forecast_results$Naive_error /
               non_forecast_results$actual))*100
  ),
  
  MASE = c(
    mean(abs(non_forecast_results$ARIMA_110_error)) / non_mase_scale,
    mean(abs(non_forecast_results$ARIMA_211_error)) / non_mase_scale,
    mean(abs(non_forecast_results$Naive_error)) / non_mase_scale
  )
)

non_accuracy

non_forecast_results$date <- seq(
  from = as.Date("2019-07-01"),
  by = "3 months",
  length.out = nrow(non_forecast_results)
)


plot(
  non_forecast_results$date,
  non_forecast_results$actual,
  type = "l",
  lwd = 2,
  xlab = "Year",
  ylab = "Average actual weekly hours",
  main = "Non-overlapping Quarterly Forecast Performance"
)

lines(
  non_forecast_results$date,
  non_forecast_results$ARIMA_110,
  lwd = 2,
  lty = 2
)

lines(
  non_forecast_results$date,
  non_forecast_results$ARIMA_211,
  lwd = 2,
  lty = 3
)

lines(
  non_forecast_results$date,
  non_forecast_results$Naive,
  lwd = 2,
  lty = 4
)

legend(
  "bottomright",
  legend = c(
    "Actual",
    "ARIMA(1,1,0)",
    "ARIMA(2,1,1)",
    "Naive"
  ),
  lty = c(1,2,3,4),
  lwd = 2,
  bty = "n"
)

write.csv(
  non_accuracy,
  "nonoverlap_quarterly_accuracy_comparison.csv",
  row.names = FALSE
)

getwd()

ls()

final_model_comparison <- rbind(
  
  data.frame(
    Analysis = "Overlapping monthly series",
    Model = overall_accuracy$Model,
    MAE = overall_accuracy$MAE,
    RMSE = overall_accuracy$RMSE,
    MAPE = overall_accuracy$MAPE,
    MASE = overall_accuracy$MASE
  ),
  
  data.frame(
    Analysis = "Non-overlapping quarterly sensitivity",
    Model = non_accuracy$Model,
    MAE = non_accuracy$MAE,
    RMSE = non_accuracy$RMSE,
    MAPE = non_accuracy$MAPE,
    MASE = non_accuracy$MASE
  )
)

final_model_comparison

write.csv(
  final_model_comparison,
  "final_model_comparison_accuracy.csv",
  row.names = FALSE
)

final_model_comparison_round <- final_model_comparison

final_model_comparison_round[, 3:6] <- round(
  final_model_comparison_round[, 3:6],
  3
)

final_model_comparison_round

write.csv(
  final_model_comparison_round,
  "tables/final_model_comparison_accuracy.csv",
  row.names = FALSE
)

dir.create("tables")

# Final ARIMA model selection table

model_selection_table <- data.frame(
  Model = c(
    "ARIMA(0,1,3)",
    "ARIMA(0,1,4)",
    "ARIMA(0,1,5)"
  ),
  
  AICc = c(
    model_013$aicc,
    model_014$aicc,
    auto_seasonal$aicc
  ),
  
  BIC = c(
    model_013$bic,
    model_014$bic,
    auto_seasonal$bic
  )
)

model_selection_table

write.csv(
  model_selection_table,
  "arima_model_selection_table.csv",
  row.names = FALSE
)

subperiod_accuracy_round <- data.frame(
  Subperiod = subperiod_accuracy$Subperiod,
  
  ARIMA_MAE = round(subperiod_accuracy$ARIMA_MAE, 3),
  Naive_MAE = round(subperiod_accuracy$Naive_MAE, 3),
  
  ARIMA_RMSE = round(subperiod_accuracy$ARIMA_RMSE, 3),
  Naive_RMSE = round(subperiod_accuracy$Naive_RMSE, 3),
  
  ARIMA_MAPE = round(subperiod_accuracy$ARIMA_MAPE, 3),
  Naive_MAPE = round(subperiod_accuracy$Naive_MAPE, 3),
  
  ARIMA_MASE = round(subperiod_accuracy$ARIMA_MASE, 3),
  Naive_MASE = round(subperiod_accuracy$Naive_MASE, 3)
)

subperiod_accuracy_round

write.csv(
  subperiod_accuracy_round,
  "subperiod_accuracy.csv",
  row.names = FALSE
)

non_accuracy_round <- data.frame(
  Model = non_accuracy$Model,
  
  MAE = round(non_accuracy$MAE, 3),
  RMSE = round(non_accuracy$RMSE, 3),
  MAPE = round(non_accuracy$MAPE, 3),
  MASE = round(non_accuracy$MASE, 3)
)

non_accuracy_round

write.csv(
  non_accuracy_round,
  "nonoverlapping_quarterly_sensitivity_accuracy.csv",
  row.names = FALSE
)

library(forecast)

final_full_model <- Arima(
  full_ts,
  order = c(0, 1, 4),
  include.drift = FALSE,
  method = "ML"
)

final_full_model

# Final 12-period forecast with 80% and 95% prediction intervals

final_forecast <- forecast(
  final_full_model,
  h = 12,
  level = c(80, 95)
)

final_forecast

# Final forecast table with ONS rolling three-month period labels

final_forecast_table <- data.frame(
  Period = c(
    "Mar-May 2026",
    "Apr-Jun 2026",
    "May-Jul 2026",
    "Jun-Aug 2026",
    "Jul-Sep 2026",
    "Aug-Oct 2026",
    "Sep-Nov 2026",
    "Oct-Dec 2026",
    "Nov-Jan 2027",
    "Dec-Feb 2027",
    "Jan-Mar 2027",
    "Feb-Apr 2027"
  ),
  
  Point_Forecast = round(as.numeric(final_forecast$mean), 3),
  Lo_80 = round(as.numeric(final_forecast$lower[, 1]), 3),
  Hi_80 = round(as.numeric(final_forecast$upper[, 1]), 3),
  Lo_95 = round(as.numeric(final_forecast$lower[, 2]), 3),
  Hi_95 = round(as.numeric(final_forecast$upper[, 2]), 3)
)

final_forecast_table

write.csv(
  final_forecast_table,
  "tables/final_12_period_forecast.csv",
  row.names = FALSE
)

phase1_data <- hour01_sa[seq(1, nrow(hour01_sa), by = 3), ]
phase2_data <- hour01_sa[seq(2, nrow(hour01_sa), by = 3), ]
phase3_data <- hour01_sa[seq(3, nrow(hour01_sa), by = 3), ]

nrow(phase1_data)
nrow(phase2_data)
nrow(phase3_data)

head(phase1_data, 3)
head(phase2_data, 3)
head(phase3_data, 3)

phase1_data[c(109, 110), "period"]
phase2_data[c(109, 110), "period"]
phase3_data[c(109, 110), "period"]

phase1_train <- phase1_data$all_workers_hours[1:109]
phase1_test  <- phase1_data$all_workers_hours[110:136]

phase2_train <- phase2_data$all_workers_hours[1:109]
phase2_test  <- phase2_data$all_workers_hours[110:136]

phase3_train <- phase3_data$all_workers_hours[1:109]
phase3_test  <- phase3_data$all_workers_hours[110:136]

length(phase1_train); length(phase1_test)
length(phase2_train); length(phase2_test)
length(phase3_train); length(phase3_test)

phase1_train_ts <- ts(phase1_train, frequency = 4)

phase1_adf_level <- adf.test(phase1_train_ts)
phase1_kpss_level <- kpss.test(phase1_train_ts, null = "Level")

phase1_adf_level
phase1_kpss_level

library(tseries)

phase1_diff1 <- diff(phase1_train_ts)

phase1_adf_diff1 <- adf.test(phase1_diff1)
phase1_kpss_diff1 <- kpss.test(phase1_diff1, null = "Level")

phase1_adf_diff1
phase1_kpss_diff1

phase2_train_ts <- ts(phase2_train, frequency = 4)

phase2_adf_level <- adf.test(phase2_train_ts)
phase2_kpss_level <- kpss.test(phase2_train_ts, null = "Level")

phase2_adf_level
phase2_kpss_level

phase2_diff1 <- diff(phase2_train_ts)

phase2_adf_diff1 <- adf.test(phase2_diff1)
phase2_kpss_diff1 <- kpss.test(phase2_diff1, null = "Level")

phase2_adf_diff1
phase2_kpss_diff1

phase3_train_ts <- ts(phase3_train, frequency = 4)

phase3_adf_level <- adf.test(phase3_train_ts)
phase3_kpss_level <- kpss.test(phase3_train_ts, null = "Level")

phase3_adf_level
phase3_kpss_level

phase3_diff1 <- diff(phase3_train_ts)

phase3_adf_diff1 <- adf.test(phase3_diff1)
phase3_kpss_diff1 <- kpss.test(phase3_diff1, null = "Level")

phase3_adf_diff1
phase3_kpss_diff1

library(forecast)

phase1_auto <- auto.arima(
  phase1_train_ts,
  d = 1,
  seasonal = FALSE,
  stepwise = FALSE,
  approximation = FALSE,
  allowdrift = TRUE,
  allowmean = FALSE,
  ic = "aicc"
)

phase1_auto

checkresiduals(phase1_auto)

phase2_auto <- auto.arima(
  phase2_train_ts,
  d = 1,
  seasonal = FALSE,
  stepwise = FALSE,
  approximation = FALSE,
  allowdrift = TRUE,
  allowmean = FALSE,
  ic = "aicc"
)

phase2_auto

checkresiduals(phase2_auto)

phase3_auto <- auto.arima(
  phase3_train_ts,
  d = 1,
  seasonal = FALSE,
  stepwise = FALSE,
  approximation = FALSE,
  allowdrift = TRUE,
  allowmean = FALSE,
  ic = "aicc"
)

phase3_auto

checkresiduals(phase3_auto)

phase1_arima_forecast <- numeric(length(phase1_test))
phase1_naive_forecast <- numeric(length(phase1_test))

for (i in seq_along(phase1_test)) {
  
  if (i == 1) {
    history <- phase1_train
  } else {
    history <- c(phase1_train, phase1_test[1:(i - 1)])
  }
  
  fit <- Arima(
    ts(history, frequency = 4),
    order = c(1, 1, 0),
    include.drift = FALSE,
    method = "ML"
  )
  
  phase1_arima_forecast[i] <- as.numeric(forecast(fit, h = 1)$mean)
  phase1_naive_forecast[i] <- tail(history, 1)
}

phase1_results <- data.frame(
  period = phase1_data$period[110:136],
  actual = phase1_test,
  arima_forecast = phase1_arima_forecast,
  naive_forecast = phase1_naive_forecast
)

head(phase1_results)


phase1_mase_scale <- mean(abs(diff(phase1_train)))

phase1_accuracy <- data.frame(
  Model = c("ARIMA(1,1,0)", "Naive"),
  
  MAE = c(
    mean(abs(phase1_test - phase1_arima_forecast)),
    mean(abs(phase1_test - phase1_naive_forecast))
  ),
  
  RMSE = c(
    sqrt(mean((phase1_test - phase1_arima_forecast)^2)),
    sqrt(mean((phase1_test - phase1_naive_forecast)^2))
  ),
  
  MAPE = c(
    mean(abs((phase1_test - phase1_arima_forecast) / phase1_test)) * 100,
    mean(abs((phase1_test - phase1_naive_forecast) / phase1_test)) * 100
  ),
  
  MASE = c(
    mean(abs(phase1_test - phase1_arima_forecast)) / phase1_mase_scale,
    mean(abs(phase1_test - phase1_naive_forecast)) / phase1_mase_scale
  )
)

phase1_accuracy


phase2_arima_forecast <- numeric(length(phase2_test))
phase2_naive_forecast <- numeric(length(phase2_test))

for (i in seq_along(phase2_test)) {
  
  if (i == 1) {
    history <- phase2_train
  } else {
    history <- c(phase2_train, phase2_test[1:(i - 1)])
  }
  
  fit <- Arima(
    ts(history, frequency = 4),
    order = c(1, 1, 0),
    include.drift = FALSE,
    method = "ML"
  )
  
  phase2_arima_forecast[i] <- as.numeric(forecast(fit, h = 1)$mean)
  phase2_naive_forecast[i] <- tail(history, 1)
}

phase2_results <- data.frame(
  period = phase2_data$period[110:136],
  actual = phase2_test,
  arima_forecast = phase2_arima_forecast,
  naive_forecast = phase2_naive_forecast
)

head(phase2_results)


phase2_mase_scale <- mean(abs(diff(phase2_train)))

phase2_accuracy <- data.frame(
  Model = c("ARIMA(1,1,0)", "Naive"),
  
  MAE = c(
    mean(abs(phase2_test - phase2_arima_forecast)),
    mean(abs(phase2_test - phase2_naive_forecast))
  ),
  
  RMSE = c(
    sqrt(mean((phase2_test - phase2_arima_forecast)^2)),
    sqrt(mean((phase2_test - phase2_naive_forecast)^2))
  ),
  
  MAPE = c(
    mean(abs((phase2_test - phase2_arima_forecast) / phase2_test)) * 100,
    mean(abs((phase2_test - phase2_naive_forecast) / phase2_test)) * 100
  ),
  
  MASE = c(
    mean(abs(phase2_test - phase2_arima_forecast)) / phase2_mase_scale,
    mean(abs(phase2_test - phase2_naive_forecast)) / phase2_mase_scale
  )
)

phase2_accuracy


phase3_arima_forecast <- numeric(length(phase3_test))
phase3_naive_forecast <- numeric(length(phase3_test))

for (i in seq_along(phase3_test)) {
  
  if (i == 1) {
    history <- phase3_train
  } else {
    history <- c(phase3_train, phase3_test[1:(i - 1)])
  }
  
  fit <- Arima(
    ts(history, frequency = 4),
    order = c(2, 1, 1),
    include.drift = FALSE,
    method = "ML"
  )
  
  phase3_arima_forecast[i] <- as.numeric(forecast(fit, h = 1)$mean)
  phase3_naive_forecast[i] <- tail(history, 1)
}

phase3_results <- data.frame(
  period = phase3_data$period[110:136],
  actual = phase3_test,
  arima_forecast = phase3_arima_forecast,
  naive_forecast = phase3_naive_forecast
)

head(phase3_results)


phase3_mase_scale <- mean(abs(diff(phase3_train)))

phase3_accuracy <- data.frame(
  Model = c("ARIMA(2,1,1)", "Naive"),
  
  MAE = c(
    mean(abs(phase3_test - phase3_arima_forecast)),
    mean(abs(phase3_test - phase3_naive_forecast))
  ),
  
  RMSE = c(
    sqrt(mean((phase3_test - phase3_arima_forecast)^2)),
    sqrt(mean((phase3_test - phase3_naive_forecast)^2))
  ),
  
  MAPE = c(
    mean(abs((phase3_test - phase3_arima_forecast) / phase3_test)) * 100,
    mean(abs((phase3_test - phase3_naive_forecast) / phase3_test)) * 100
  ),
  
  MASE = c(
    mean(abs(phase3_test - phase3_arima_forecast)) / phase3_mase_scale,
    mean(abs(phase3_test - phase3_naive_forecast)) / phase3_mase_scale
  )
)

phase3_accuracy


three_phase_accuracy <- rbind(
  data.frame(Phase = "Phase 1", phase1_accuracy),
  data.frame(Phase = "Phase 2", phase2_accuracy),
  data.frame(Phase = "Phase 3", phase3_accuracy)
)

three_phase_accuracy


write.csv(
  three_phase_accuracy,
  "tables/three_phase_nonoverlap_accuracy.csv",
  row.names = FALSE
)

file.exists("tables/three_phase_nonoverlap_accuracy.csv")


three_phase_accuracy_rounded <- three_phase_accuracy

three_phase_accuracy_rounded[, c("MAE", "RMSE", "MAPE", "MASE")] <-
  round(
    three_phase_accuracy_rounded[, c("MAE", "RMSE", "MAPE", "MASE")],
    3
  )

three_phase_accuracy_rounded


write.csv(
  three_phase_accuracy_rounded,
  "tables/three_phase_nonoverlap_accuracy_rounded.csv",
  row.names = FALSE
)

file.exists("tables/three_phase_nonoverlap_accuracy_rounded.csv")


png(
  "figures/hour01_sa_training_diff1_acf_fixed.png",
  width = 1600,
  height = 1000,
  res = 200
)

acf(
  as.numeric(diff(train_ts)),
  lag.max = 36,
  main = "",
  xlab = "Lag"
)

dev.off()

png("figures/hour01_sa_training_diff1_pacf_fixed.png",
    width = 1600, height = 1000, res = 200)

pacf(
  as.numeric(diff(train_ts)),
  lag.max = 36,
  main = "",
  xlab = "Lag"
)

dev.off()

coef(selected_model)

grep("014|arima|model", ls(), value = TRUE, ignore.case = TRUE)

coef(model_014)
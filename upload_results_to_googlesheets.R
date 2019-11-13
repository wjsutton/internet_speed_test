library(googlesheets)
suppressMessages(library(dplyr))
gs_auth(token ="googlesheets_token.rds")
gs_upload("internet_speed_results.csv",overwrite = TRUE)

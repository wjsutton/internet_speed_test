# Internet Speed Test

## Table of Contents
+ [About](#about)
+ [Getting Started](#getting_started)
+ [Usage](#usage)
+ [TODO](#todo)

## About <a name = "about"></a>
This project is for monitoring and recording local broadband the speed. 

## Getting Started <a name = "getting_started"></a>
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. 

### Prerequisites

For this project you will need you will need R installed and the `speedtest` R package installed with the script below:
```
install.packages("speedtest", repos = "https://cinc.rud.is")
```
Or another option from here: https://github.com/hrbrmstr/speedtest#installation

If you would like to write the results to GoogleSheets for surfacing in Tableau Public or another cloud based data viz tool then you'll need the `googlesheets` and `dplyr` R packages.
```
install.packages(c("googlesheets","dplyr"), dependencies = TRUE)
```
and you will need to create an google_auth token named "googlesheets_token.rds" more information on how to do that can be found here: https://github.com/jennybc/googlesheets

### Installing

Running a basic internet speed test with text outputs to the console
```
library(speedtest)

report_time <- Sys.time()

cat(paste0(Sys.time()," Gathering test configuration information...\n"))
config <- spd_config()
cat(paste0(Sys.time()," Gathering server list...\n"))
servers <- spd_servers(config = config)
cat(paste0(Sys.time()," Determining best server...\n"))
servers <- spd_closest_servers(servers, config)
best <- spd_best_servers(servers, config, max = 3)
cat(paste0(Sys.time()," Initiating test from ",config$client$isp," ",config$client$ip," to ",best$sponsor[1]," ",best$name[1],"\n"))
cat(paste0(Sys.time()," Analyzing download speed...\n"))
down <- spd_download_test(best, config, FALSE, timeout = 5)
cat(paste0(Sys.time()," Download Speed ",nice_speed(max(down$bw)),"\n"))
cat(paste0(Sys.time()," Analyzing upload speed...\n"))
up <- spd_upload_test(best, config, FALSE, timeout = 10)
cat(paste0(Sys.time()," Upload Speed ",nice_speed(max(up$bw)),"\n"))
```

Writing the data to a local csv file, if a file doesn't exist create a new one
```
entry <- data.frame(test_time=report_time
                    ,download_speed=max(down$bw)
                    ,upload_speed=max(up$bw)
                    ,stringsAsFactors = FALSE)

if(file.exists("internet_speed_results.csv")){
  cat(paste0(Sys.time()," Appending results to existing file...\n"))
  all_results <- read.csv("internet_speed_results.csv",stringsAsFactors = FALSE)
  all_results$test_time <- as.POSIXct(all_results$test_time)
  all_results <- rbind(all_results,entry)
  write.csv(all_results,"internet_speed_results.csv",row.names = FALSE)
}

if(!file.exists("internet_speed_results.csv")){
  cat(paste0(Sys.time()," Writing results to new file...\n"))
  write.csv(entry,"internet_speed_results.csv",row.names = FALSE)
}

cat(paste0(Sys.time()," Results Written\n"))
cat(paste0(Sys.time()," End of Process\n"))
```

Full internet speed test check and write process executable using
```
source("speedtest.R")
```

Results then uploaded to GoogleSheets on a weekly basis for visualising in Tableau Public using the Google Auth token "googlesheets_token.rds" either using
```
source("upload_results_to_googlesheets.R")
```
or the full script 
```
library(googlesheets)
suppressMessages(library(dplyr))
gs_auth(token ="googlesheets_token.rds")
gs_upload("internet_speed_results.csv",overwrite = TRUE)
```

## Usage <a name = "usage"></a>

I schedule this script to run every 15 minutes on Windows Task Scheduler.

## TODO <a name = "todo"></a>

[] Build Tableau Dashboard
[] Move R library from `googlesheets` (https://github.com/jennybc/googlesheets) to `googlesheets4` (https://googlesheets4.tidyverse.org/) or `googledrive` (https://googledrive.tidyverse.org/)
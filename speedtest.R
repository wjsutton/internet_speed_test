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

cat(paste0(Sys.time()," Writing Results\n"))

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

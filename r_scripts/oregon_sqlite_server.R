library(dplyr)
library(data.table)
library(readxl) 
library(readr)
library(RSQLite)

# import data ------------------------------------------------------------------

read_path <- paste0("../../../data/data_original/gan_episodes_of_care.txt")
start_time <- Sys.time()
oregon_df <- fread(read_path, sep = "|", showProgress = T, 
                   colClasses = rep("character", 72)) 
stop_time <-  Sys.time() - start_time 
# time it took
stop_time # 24.36408 mins

or_DB <- "../../../data/data_new/database/oregon_db.db"
or_Conn <- dbConnect(drv = SQLite(), dbname= or_DB)

start_time <- Sys.time()
dbListTables(or_Conn)
dbWriteTable(or_Conn, name = "Oregon_Full",oregon_df)

stop_time <-  Sys.time() - start_time 
# time it took
stop_time # 18.47879 mins


### close and revoke
newDB <- "../../../data/data_new/database/oregon_db.db"

start_time <- Sys.time()
newConn <- dbConnect(drv = SQLite(), dbname= newDB)
dbListTables(newConn)

stop_time <-  Sys.time() - start_time 
# time it took
stop_time # seconds

start_time <- Sys.time()
oregon_claim_try <- dbGetQuery(newConn, "SELECT personkey FROM Oregon_Full")
stop_time <-  Sys.time() - start_time 
# time it took
stop_time #  1.351812 mins


start_time <- Sys.time()
oregon_claim_try <- dbGetQuery(newConn, "SELECT personkey, clmid, line, clmstatus, cob FROM Oregon_Full")
stop_time <-  Sys.time() - start_time 
# time it took
stop_time #  6.422741 mins


start_time <- Sys.time()
dbWriteTable(newConn, name = "Oregon_Five",oregon_claim_try)
stop_time <-  Sys.time() - start_time 
# time it took
stop_time #  Time difference of 2.145944 mins


start_time <- Sys.time()
or_5 <- dbGetQuery(newConn, "SELECT * FROM Oregon_Five")
stop_time <-  Sys.time() - start_time 
# time it took
stop_time #  3.249266 mins

start_time <- Sys.time()
or_5 <- dbGetQuery(newConn, "SELECT personkey, clmid, line, clmstatus, cob FROM Oregon_Five")
stop_time <-  Sys.time() - start_time 
# time it took
stop_time #  Time difference of 3.083446 mins








oregon_claim1 <- dbGetQuery(newConn, "SELECT * FROM Oregon_Full")[,c(1:38)]
oregon_claim2 <- dbGetQuery(newConn, "SELECT * FROM Oregon_Full")[,c(1,3,4,5,39:72)]





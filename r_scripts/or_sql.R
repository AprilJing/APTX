# ------------------------------------------------------------------------------
# Title: Database sql for Oregon
# Author: Jingyang Liu
# Date Created: Mar 10, 2017
# R version: 3.3.2
# ------------------------------------------------------------------------------

library(dplyr)
library(RSQLite)
my_db <- src_sqlite("my_db.sqlite3", create = T)

read_path <- paste0('./data_new/oregon_asthma_jul_to_oct_claim.csv')

#reserve all column type as character (because of dates)
asthma_samp <- read_csv(read_path, col_types = cols(.default = col_character())) 

asthma_sqlite <- copy_to(my_db, asthma_samp, temporary = T)
asthma_sqlite

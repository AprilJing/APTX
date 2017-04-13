# ------------------------------------------------------------------------------
# Title: Database management (Sqlite)
# Author: Jingyang Liu
# Date Created: Mar 10, 2017
# R version: 3.3.2
# ------------------------------------------------------------------------------

library(dplyr)
library(RSQLite)
library(readr)
or_db <- src_sqlite("or_db.sqlite", create = T)
or_db2 <- src_sqlite("or_db.sqlite2", create = T)

myDB <- "./or_db.sqlite"
conn <- dbConnect(drv = SQLite(), dbname= myDB)





d <- dbDriver("SQLite")
a = dbConnect(d, dbname="or_db.sqlite")

dbListTables(a)

read_path <- paste0('../data/co_est2015_alldata.csv')

#reserve all column type as character (because of dates)
pop_est <- read_csv(read_path, col_types = cols(.default = col_character())) 

read_path2 <- paste0('../../colorado_wildfire/data/case_cross_data/asthma1_jul_to_oct_casecross.csv') 
co_asthma <- read_csv(read_path2, col_types = cols(.default = col_character())) 

pop_sqlite <- copy_to(or_db, pop_est, temporary = T)
co_sqlite <- copy_to(or_db2, co_asthma, temporary = T)

summary(pop_sqlite)

# or
tbl(or_db, sql("SELECT * FROM pop_est"))
tbl(or_db2, sql("SELECT * FROM co_asthma"))


c1 <- select(co_sqlite, cdpheid:RACE, age_ind, COUNTY, STNAME)

c1

c2 <- select(pop_sqlite, STNAME)

c2

## Basic verbs (common for both local and remote)
select(asthma_sqlite, personkey:num_visit, gender, race, fromdate, dx1, px1, mod1)
filter(asthma_sqlite, gender=="U")
arrange(asthma_sqlite, fromdate)
mutate(asthma_sqlite, trydate = dates - 7)
summarise(asthma_sqlite, mean_visit = mean(num_visit))


## Laziness ??
c1 <- select(asthma_sqlite, personkey:num_visit, gender, race, fromdate, dx1, px1, mod1, dates)
c2 <- filter(c1, gender=="M")
c3 <- arrange(c2, fromdate)
c4 <- mutate(c3, trydate = dates)
c4 # until you ask, it will do the data into R

collect(c4)

c4$query # ????? see the query dplyr has generated

explain(c4)

collect(c4)
# compute(c4)
# collapse(c4)

# copy the data from database into R dataframe
a <- tbl_df(collect(c4))


## SQL translation
translate_sql(x)
#> <SQL> "x"
# And strings are escaped by single quotes
translate_sql("x")
#> <SQL> 'x'

# Many functions have slightly different names
translate_sql(x == 1 && (y < 2 || z > 3))
#> <SQL> "x" = 1.0 AND ("y" < 2.0 OR "z" > 3.0)
translate_sql(x ^ 2 < 10)
#> <SQL> POWER("x", 2.0) < 10.0
translate_sql(x %% 2 == 10)
#> <SQL> "x" % 2.0 = 10.0

# R and SQL have different defaults for integers and reals.
# In R, 1 is a real, and 1L is an integer
# In SQL, 1 is an integer, and 1.0 is a real
translate_sql(1)
#> <SQL> 1.0
translate_sql(1L)
#> <SQL> 1

# new_sqlite <- SELECT EMP_ID, NAME, DEPT FROM COMPANY CROSS JOIN DEPARTMENT;



### Title: Sqlite try for joining population estimate and CO claim data
## Date: April 13, 2017 
library(dplyr)
library(RSQLite)
library(readr)

### read data from csv file
read_path <- paste0('../data/co_est2015_alldata.csv')
pop_est <- read_csv(read_path, col_types = cols(.default = col_character())) 

read_path2 <- paste0('../../colorado_wildfire/data/case_cross_data/asthma1_jul_to_oct_casecross.csv') 
co_asthma <- read_csv(read_path2, col_types = cols(.default = col_character())) # Dates display not normally


### Connect database
myDB <- "or_bd.db"
myConn <- dbConnect(drv = SQLite(), dbname= myDB)
dbListTables(myConn)

## Make queries
dbWriteTable(myConn, name = "Population",pop_est)
dbListTables(myConn)
pp <- dbReadTable(myConn, "Population")

dbWriteTable(myConn, name = "Asthma",co_asthma)
dbListTables(myConn)

# choose all columns from the table and limit the state is only Colorado
colo <- dbGetQuery(myConn, "SELECT * from Population where STNAME='Colorado' ")
# choose only 5 columns from the whole data set and Colorado state
colo2 <- dbGetQuery(myConn, "SELECT STATE,	COUNTY,	STNAME,	CTYNAME, 
                    POPESTIMATE2012 from Population where STNAME='Colorado' ")


## With numeric class preserved
### read data from csv file
pop_est2 <- read_csv(read_path) 

dbWriteTable(myConn, name = "PopulationNew",pop_est2)
dbListTables(myConn)
# [1] "Population"    "PopulationNew"
pp2 <- dbReadTable(myConn, "PopulationNew")

# choose 5 columns, Colorado state, and the 2012 population number is larger than 10000
## SQL logical operators: AND, OR, NOT
colo3 <- dbGetQuery(myConn, "SELECT STATE,	COUNTY,	STNAME,	CTYNAME, 
                    POPESTIMATE2012 from PopulationNew where STNAME='Colorado' 
                    and POPESTIMATE2012>10000")


### ----------------------------------------------------------------------------
## Close R and open again, revoke database which was made last time.
library(dplyr)
library(RSQLite)

myDB <- "or_bd.db"
myConn <- dbConnect(drv = SQLite(), dbname= myDB)
dbListTables(myConn)

co_pop_2012 <- dbGetQuery(myConn, "SELECT STATE,	COUNTY,	STNAME,	CTYNAME, 
                    POPESTIMATE2012 from PopulationNew where STNAME='Colorado'")

co_claim <- dbGetQuery(myConn, "SELECT * from Asthma")

# Make new database and store this two tables newly formed
newDB <- "co_db.db"
newConn <- dbConnect(drv = SQLite(), dbname= newDB)
dbWriteTable(newConn, name = "PopStat",co_pop_2012)
dbWriteTable(newConn, name = "CoClaim",co_claim)
dbListTables(newConn)

co_pop_claim <- dbGetQuery(newConn, "SELECT * FROM CoClaim inner join PopStat on 
                           Coclaim.county_final = PopStat.COUNTY")[,c(1:13,18)]
# Error in rsqlite_send_query(conn@ptr, statement) : 
# RIGHT and FULL OUTER JOINs are not currently supported







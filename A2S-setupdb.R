# install.packages("dbplyr")
# install.packages("DBI")
# install.packages("RMySQL")
# library(dbplyr)
#library(dplyr)
library(DBI)
library(RMySQL)

host <- "database-2.cluster-chhrqrpvglpz.us-east-1.rds.amazonaws.com"
port <- 3306
dbname <- "hudk4051"
user <- "renatorusso"
password <- "Y2JVBr68qQX8AjY"

my_db <- dbConnect(MySQL(), user = user, password = password, dbname = dbname, host = host, port = port)
my_db
summary(my_db)
dbListTables(my_db)

#Loading data
ACBQ_data <- readxl::read_xlsx("ACBQ/Data_ACBQ.xlsx")

# Writing data to the DB using the DBI package
dbWriteTable(my_db,"ACBQ_data", ACBQ_data)

dbRemoveTable(my_db, "a2sdata")

# Checking if the data has been written to the DB
dbListTables(my_db)

# Read table in the 
dbReadTable(my_db, "ACBQ_data")

# Selecting columns
dbGetQuery(my_db, "SELECT ACBQ1 FROM ACBQ_data WHERE gender = '1' LIMIT 10")

# Combining aggregate functions with WHERE
dbGetQuery(my_db, "SELECT ABCQ FROM ACBQ_data WHERE RealworldCT > 3 LIMIT 10")
  
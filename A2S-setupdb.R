<<<<<<< Updated upstream
# install.packages("dbplyr")
# install.packages("DBI")
# install.packages("RMySQL")
# library(dbplyr)
#library(dplyr)
library(DBI)
library(RMySQL)

host <- "la-4051.chhrqrpvglpz.us-east-1.rds.amazonaws.com"
port <- 3306
dbname <- "la-4051"
user <- "renatorusso"
password <- "zcUbWvUWRNNN4pg"
=======
library(dplyr)
#install.packages("RMySQL")
library(RMySQL)
#install.packages("DBI")
library(DBI)

host = "la-4051.chhrqrpvglpz.us-east-1.rds.amazonaws.com"
port = 3306
dbname = "la-4051"
user = "renatorusso"
password = "zcUbWvUWRNNN4pg"

my_db <- dbConnect(MySQL(), user = user, password = password, dbname = dbname, host = host, port = port)
#  src_mysql(dbname = dbname, host = host, port = port, user = user, password = password)
>>>>>>> Stashed changes

my_db = dbConnect(MySQL(), user = user, password = password, dbname = dbname, 
                  host = host, port = port)

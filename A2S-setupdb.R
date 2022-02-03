library(dplyr)
#install.packages("RMySQL")
install.
library(RMySQL)
host="la-4051.chhrqrpvglpz.us-east-1.rds.amazonaws.com"
port=3306
dbname="la-4051"
user="renatorusso"
password="zcUbWvUWRNNN4pg"

my_db = src_mysql(dbname=dbname, host=host, port=port, user=user, password=password)


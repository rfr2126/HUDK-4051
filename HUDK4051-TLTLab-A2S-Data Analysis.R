a2s_events <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_events.csv")
a2s_progress <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_progress.csv")
a2s_logs <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_logs.csv")
a2s_students <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_students.csv")

View(a2s_events)
View(a2s_progress)

install.packages("crosstable")
library(crosstable)
crosstable(a2s_data, userId)

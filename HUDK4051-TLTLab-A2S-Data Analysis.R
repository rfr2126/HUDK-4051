library(tidyverse)
a2s_events <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_events.csv")
a2s_progress <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_progress.csv")
a2s_logs <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_logs.csv")
a2s_students <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_students.csv")

save(a2s_events, file = "a2s_events.Rda")
save(a2s_progress, file = "a2s_progress.Rda") 
save(a2s_logs, file = "a2s_logs.Rda")
save(a2s_students, file = "a2s_students.Rda")


# Windows
a2s_events <- read.csv("C:\\Users\\Renato\\Desktop\\TLTLab\\netlogo_events.csv")
a2s_progress <- read.csv("C:\\Users\\Renato\\Desktop\\TLTLab\\netlogo_progress.csv")
a2s_logs <- read.csv("C:\\Users\\Renato\\Desktop\\TLTLab\\netlogo_logs.csv")
a2s_students <- read.csv("C:\\Users\\Renato\\Desktop\\TLTLab\\netlogo_students.csv")

View(a2s_events)
View(a2s_progress)
View(a2s_logs)
View(a2s_students)

# EXPLORATORY ANALYSIS ----------------------------------------------------
## Events ----------------------------------------------------
table(a2s_events$taskId)

table(a2s_events$journeyId)
#journeyId = 9: diffusion
#journeyId = 44: wildfires

table(a2s_events$taskId)
#taskId = 6 and 451: part of the diffusion journey
#taskId = 41 and 408: part of the wildfires journey

table(a2s_events$blockType)

### Block types by journey ----------------------------------------------------
# a table of block types by journey
blocktype_journey <- (table(a2s_events$blockType, a2s_events$journeyId))
colnames(blocktype_journey)[colnames(blocktype_journey) == "9"] <- "diffusion"
colnames(blocktype_journey)[colnames(blocktype_journey) == "44"] <- "wildfires"
as.data.frame(blocktype_journey)

sum(blocktype_journey$diffusion)

table(blocktype_journey)

# a table of the block types for journey "diffusion"
diffusion_blocktypes <- as.data.frame(blocktype_journey[, 'diffusion'])
View(diffusion_blocktypes)

# a table of the block types for journey "wildfires"
wildfires_blocktypes <- as.data.frame(blocktype_journey[, 'wildfires'])
View(wildfires_blocktypes)

### Action types by journey ----------------------------------------------------
# a table of action types by journey
action_journey <- (table(a2s_events$actionType, a2s_events$journeyId))
colnames(action_journey)[colnames(action_journey) == "9"] <- "diffusion"
colnames(action_journey)[colnames(action_journey) == "44"] <- "wildfires"
as.data.frame(action_journey)
action_journey

# a table of the action types for journey "diffusion"
diffusion_actiontypes <- as.data.frame(action_journey[, 'diffusion'])
View(diffusion_actiontypes)

# a table of the block types for journey "wildfires"
wildfires_actiontypes <- as.data.frame(action_journey[, 'wildfires'])
View(wildfires_actiontypes)

## Logs ----------------------------------------------------
# adding a column that will contain the type of action in the video (requires library(tibble))
library(tibble)
a2s_logs <- a2s_logs %>%
  add_column(VideoAction = NA)

library(jsonlite)
a2s_logs[1,6]

videos_df <- map(a2s_logs$message, jsonlite::fromJSON)
videos_df

videos_df <- data.frame(matrix(unlist(videos_df),ncol=4,byrow=T))

a2s_logs <- cbind(a2s_logs, videos_df)
View(a2s_logs)
colnames(a2s_logs)[7] <- "Data_type"
colnames(a2s_logs)[8] <- "Action"
colnames(a2s_logs)[9] <- "Video"
colnames(a2s_logs)[10] <- "Time"

recode(a2s_logs$Video <- recode(a2s_logs$Video,
                                'https://admin.a2s.fablevision-dev.com/assets/videos/u1_hot_water_default.mp4' = "Hot Water Default", 
                                'https://admin.a2s.fablevision-dev.com/assets/videos/u1_cold_water.mp4' = "Cold Water"))

       
table(a2s_logs$Video)
library(summarytools)
freq(a2s_logs$Video)

View(ctable(
  x = a2s_logs$Video,
  y = a2s_logs$Action
))

ctable(
  x = a2s_logs$Action,
  y = a2s_logs$userId
)

hist(a2s_logs$Time)

ctable(
  x = a2s_logs$Video,
  y = a2s_logs$userId
)

setwd("Users/renatorusso/Desktop/Ed.D./HUDK-4051/A2S")

library(tidyverse)
a2s_events <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_events.csv")
a2s_progress <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_progress.csv")
a2s_logs <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_logs.csv")
a2s_students <- read.csv("/Users/renatorusso/Desktop/TLTLAB/A2S Project/netlogo_students.csv")

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

## Adding a column for categories of block types-----

table(a2s_events$actionType)

table(a2s_events$blockTypeCategory)

table(a2s_events$userId)

a2s_events$blockTypeCategory = a2s_events$blockType

a2s_events$blockTypeCategory <- recode(a2s_events$blockTypeCategory,
                                       'ask_each_particle' = "Control", 
                                       'attach' = "Action",
                                       'blow' = "Action",
                                       'bounce_off' = "Action",
                                       'create_particles' = "Properties",
                                       'create_smoke' = "Properties",
                                       'interact' = "Action",
                                       'move' = "Action",
                                       'set' = "Set",
                                       'set_color' = "Set",
                                       'set_heading' = "Set",
                                       'set_mass' = "Set",
                                       'set_position' = "Set",
                                       'set_size' = "Set",
                                       'set_speed' = "Set",
                                       'set_type' = "Set",
                                       'controls_if' = "Control",
                                       'controls_when' = "Control",
                                       'apply_force_up' = "Apply",
                                       'apply_gravity' = "Apply",
                                       'apply_wind' = "Apply",
                                       'controls_if' = "Control",
                                       'controls_when' = "Control",
                                       'erase' = "Action",
                                       'logic_negate' = "Logic",
                                       'logic_operation' = "Logic",
                                       'temperature'= "Control"
                                       )

ggplot(a2s_events, aes(blockTypeCategory))


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

# use this to identify the structure of the column of interest
library(jsonlite)
a2s_logs[1,6]

# the code below parses the column "message", but it turns it into a separated list, 
# which is not a good format for analysis
videos_df <- map(a2s_logs$message, jsonlite::fromJSON)
View(videos_df)

# the code below turns the list above into a dataframe
videos_df <- data.frame(matrix(unlist(videos_df),ncol=4,byrow=T))

# the code below merges the original dataframe  with the newly one created above
a2s_logs_clean <- cbind(a2s_logs, videos_df)
View(a2s_logs)

# Now, I'm changing the column names to more descriptive ones
colnames(a2s_logs_clean)[7] <- "Data_type"
colnames(a2s_logs_clean)[8] <- "Action"
colnames(a2s_logs_clean)[9] <- "Video"
colnames(a2s_logs_clean)[10] <- "Time"

# and, here, I'm "recoding" the video urls to make them more comprehensible: now,
# each video is described by a name, instead of by the url:
recode(a2s_logs_clean$Video <- recode(a2s_logs_clean$Video,
                                'https://admin.a2s.fablevision-dev.com/assets/videos/u1_hot_water_default.mp4' = "Hot Water Default", 
                                'https://admin.a2s.fablevision-dev.com/assets/videos/u1_cold_water.mp4' = "Cold Water"))

View(a2s_logs_clean)
class(a2s_logs_clean$Time)
x <- chron(times=a2s_logs_clean$Time)


# then, I write a new data set, with a tidier structure:
save(a2s_logs_clean, file = "/Users/renatorusso/Desktop/Ed.D./HUDK-4051/A2S/a2s_logs_clean.Rda")

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

ctable(
  x = a2s_logs$Video,
  y = a2s_logs$userId
)

#Joining events and logs ------
events_logs <- full_join(
  a2s_events,
  a2s_logs)
View(events_logs)

save(events_logs, file = "events_logs.Rda")
save(a2s_events, file = "a2s_events.Rda")
save(a2s_progress, file = "a2s_progress.Rda") 
save(a2s_logs, file = "a2s_logs.Rda")
save(a2s_students, file = "a2s_students.Rda")

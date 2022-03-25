# DATA OVERVIEW -----------------------------------------------------------
# dateCreated - timestamp of action

# dateUpdated - seems to be the same as above

# uid - unique id of the event

# userId - internal id associated with the user that performed the action

# journeyId - the platform is made up of different curricular units that explore 
# a topic. This is the id of the unit that the student was working on when they did this action

# taskId - each unit (or journey) has a set of tasks associated with it. 
# Students make models for each task in the unit (so the model for journeyId: 1,

# taskId:1 is different from the model for journeyId: 1, taskId:2).
# This is the task students were working on when they did the action

# blockType - this is the kind of block that was added to the workspace during this event.
# The different types of blocks vary depending on when journey/task the event is from. 
# NULL indicates that no block was added.

# actionType - This is the kind of action in this event. Actions consist of either 
# creating/deleting a block from the workspace or setting up/running/interacting 
# with model defined by the blocks in the workspace

# workspace - this is an XML representation of the blocks currently in the workspace 
# when the action occurred. This is the format used to store a student’s work 
# and can be used to restore the state of the model workspace. Needs to be parsed.

# platform: https://admin.a2s.fablevision-dev.com/

# any patterns in how students are using the environment (for example, 
# maybe students are adding many blocks, but never actually running their models) 
# or using specific blocks (i.e. what is the first block students normally add to 
# their models for each unit?).

# is it possible to put Lukas in touch with the researchers
# engage more students in the analytics effort

# RAW DATA ----------------------------------------------------------------
data_a2s <- read.csv("/Users/renatorusso/Desktop/Ed.D./HUDK-4051/netlogo_events.csv")
View(data_a2s)

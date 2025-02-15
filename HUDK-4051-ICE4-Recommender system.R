library(tidyverse)
interest <- read_csv("interest.csv")
difficulty <- read_csv("difficulty.csv")
View(interest)
View(difficulty)

# EXPLORATORY ANALYSIS ----------------------------------------------------
## Data wrangling - creating a dataset with rows being the seven units while 
## the columns are the mean of the difficulty ratings and the interest ratings

# First, we get the mean for each column in the "interest" dataset
interest_means <- interest %>% 
  summarise_if(is.numeric, mean,  na.rm = TRUE)
interest_means
difficulty_means <- difficulty %>% 
  summarise_if(is.numeric, mean,  na.rm = TRUE)

# Then, I'll transpose the dataframes (i.e., columns become rows, rows become columns)
#library(data.table)
interest_means_t <- t(interest_means)
difficulty_means_t <- t(difficulty_means)

# But the new dataframes have no column name, so I'll use another function to use
# the names that appear in the original data frame as column names
rownames(interest_means_t) <- colnames(interest_means)
rownames(difficulty_means_t) <- colnames(difficulty_means)

# And the column will be renamed too:
setNames(interest_means_t, c("interest"))
setNames(difficulty_means_t, c("diffculty"))

# Then, I'll create a new dataset composed of two columns, one for each of the data
# frames above. But, first, I'll have to rename the rows in each, otherwise I think
# that the new dataframe won't be created, since the rows will have different names
row.names(interest_means_t)[row.names(interest_means_t) == "prediction.interest"] <- "prediction"
row.names(interest_means_t)[row.names(interest_means_t) == "nlp.interest"] <- "nlp"
row.names(interest_means_t)[row.names(interest_means_t) == "sna.interest"] <- "sna"
row.names(interest_means_t)[row.names(interest_means_t) == "neural.interest"] <- "neural"
row.names(interest_means_t)[row.names(interest_means_t) == "viz.interest"] <- "viz"
row.names(interest_means_t)[row.names(interest_means_t) == "loop.interest"] <- "loop"
row.names(interest_means_t)[row.names(interest_means_t) == "sql.interest"] <- "sql"

row.names(difficulty_means_t)[row.names(difficulty_means_t) == "prediction.difficulty"] <- "prediction"
row.names(difficulty_means_t)[row.names(difficulty_means_t) == "nlp.difficulty"] <- "nlp"
row.names(difficulty_means_t)[row.names(difficulty_means_t) == "sna.difficulty"] <- "sna"
row.names(difficulty_means_t)[row.names(difficulty_means_t) == "neural.difficulty"] <- "neural"
row.names(difficulty_means_t)[row.names(difficulty_means_t) == "viz.difficulty"] <- "viz"
row.names(difficulty_means_t)[row.names(difficulty_means_t) == "loop.difficulty"] <- "loop"
row.names(difficulty_means_t)[row.names(difficulty_means_t) == "sql.difficulty"] <- "sql"

#Changing column names
difficulty_interest <- cbind(difficulty_means_t, interest_means_t)
difficulty_interest <- as.data.frame(difficulty_interest)
difficulty_interest <- setNames(difficulty_interest, c("difficult","interest"))
difficulty_interest

# Pllotting metadata (interest and difficulty)
p <- ggplot(difficulty_interest, aes(difficulty,
                                     interest,
                                     label = rownames(difficulty_interest))) +
  geom_point() +
  geom_text(nudge_x = 0.02, nudge_y = 0.02)
p

# Following the same idea as KNN to measure the distance of any given point to 
# the rest of the points in the dataset
## First, select the first instance as the source item
x <- difficulty_interest[1,]
x

## Creating a data frame with 7 rows (same names as "difficulty_interest") all filled with NAs.
distance <- data.frame(d = rep(NA, 7), row.names = row.names(difficulty_interest))

## Loop through every row in difficulty_interest and measure the distance.
for (i in 1:nrow(difficulty_interest)) {
  y <- difficulty_interest[i,] #pick one of the rows as the target item
  d <- dist(rbind(x, y)) # measure the euclidean distance (by default) and assign to d
  distance[i, 1] <- d # insert the calculated distance to the distance data frame
}

arrange(distance, d)


# USING COSINE SIMILARITY TO MEASURE DISTANCE -----------------------------
# install.packages("lsa")
library(lsa)
## Converting the difficulty interest dataframe to matrix format and then transposing it
di <- difficulty_interest %>% 
  as.matrix() %>% 
  t()

## Generating the cosine similarity values as a new matrix.
di_sim <- cosine(di)

## We want to remove the matrix generated above because the items are similar to
## themselves in the diagonal
diag(di_sim) <- NA

## Quick query to find out what items are similar to any given item. 
item <- "viz" # a dataset item name

# Returns the 4 most similar items to the item defined above.
head(rownames(di_sim[order(di_sim[item,], decreasing = TRUE),]), n = 4)


# COLLABORATIVE FILTER ----------------------------------------------------
interest <- column_to_rownames(interest, var = "id") #move the id to row names
interestMatrix <- interest %>% 
  as.matrix() %>% t()
interestSim <- cosine(interestMatrix)
diag(interestSim) <- NA
person <- "s5"
head(rownames(interestSim[order(interestSim[person,], decreasing = TRUE),]))

library(tidyverse)
library(tm)

comments_bar <- read.csv("/Users/renatorusso/Desktop/Ed.D./HUDK-4051/comments_YT_barroso_raw.csv")
comments_bar

# creating a dataset with only the conments
comments_bar_text <- as_tibble(c(comments_bar$textOriginal, comments_bar$id))


# DATA CLEANING AND WRANGLING ---------------------------------------------

clean_text <- function(text){
  text <- tolower(text)
  text <- gsub("[[:digit:]]+", "", text)
  text <- gsub("[[:punct:]]+","", text)
  return(text)
}
# cleaning the text
comments_bar_text$value <- clean_text(comments_bar_text$value)

# creating a column for an id# for each comment
comments_bar_text <- comments_bar_text %>% 
  mutate(id = 1:nrow(comments_bar_text))

View(comments_bar_text)


# ORGANIZING DATA ---------------------------------------------------------
comment_token <- comments_bar_text %>% 
  tidytext::unnest_tokens(word, value) %>% 
  count(id, word)

# removing stopwords. I'm using a different method (with the tm package) 
# to include stop words in Portuguese
comment_token$word = removeWords(comment_token$word, stopwords("portuguese"))

# removing more stop words, now from a portuguese stop words bank that I created before
#updating the dataframe, now without the stop words frmo the custom list created above
comment_token <- comment_token %>% 
  anti_join(my_stopwords)

# with the line above, the data set now has lots of empty cells. I'll use the line 
# below to remove the empty cells from the dataset. It's impressive how smaller
# the dataset becomes after that exclusion.
comment_token <- comment_token[-which(comment_token$word == ""), ]

DTM <- comment_token %>% 
  tidytext::cast_dtm(id, word, n)

DTM


# EXPLORATORY ANALYSIS ----------------------------------------------------

comment_token %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))


# TOPIC MODELING ----------------------------------------------------------

# Finding the topics using Latent Dirichlet Allocation
library(topicmodels)
LDA <- topicmodels::LDA(DTM, k = 3, control = list(seed = 123))
LDA_td <- tidytext::tidy(LDA)
LDA_td

library(tidytext) #used to generate the charts for the LDA
topTerms <- LDA_td %>% 
  group_by(topic) %>% 
  top_n(7, beta) %>% 
  arrange(topic, -beta)

theme_set(theme_bw())

topTerms %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_x") +
  coord_flip() +
  scale_x_reordered()

# trying again, with 6 topics now
# Finding the topics using Latent Dirichlet Allocation
library(topicmodels)
LDA <- topicmodels::LDA(DTM, k = 6, control = list(seed = 123))
LDA_td <- tidytext::tidy(LDA)
LDA_td

library(tidytext) #used to generate the charts for the LDA
topTerms <- LDA_td %>% 
  group_by(topic) %>% 
  top_n(7, beta) %>% 
  arrange(topic, -beta)

theme_set(theme_bw())

topTerms %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_x") +
  coord_flip() +
  scale_x_reordered()

# TEXT CLASSIFIER ---------------------------------------------------------
convert <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels = c(0,1), labels = c("No", "Yes"))
  return(y)
}

datanaive <- apply(DTM, 2, convert)
dtmNaive <- as.data.frame(as.matrix(datanaive))

train_size = floor(0.8*nrow(comments_bar_text))
set.seed(456)
picked <- sample(seq_len(nrow(comments_bar_text)), size = train_size)

dtm_train <- dtmNaive[picked,]
dtm_train_labels <- comments_bar_text$value[picked]

dtm_test <- dtmNaive[-picked,]
dtm_test_labels <- comments_bar_text$value[-picked]

# implementing e1071 for Naive Bayes modeling
library(e1071)

# implementing care for the model evaluation
install.packages("caret")
library(caret)

nb_classifier <- naiveBayes(dtm_train, dtm_train_labels)
nb_pred = predict(nb_classifier, type = 'class', newdata = dtm_test)
confusionMatrix(nb_pred, as.factor(dtm_test_labels))

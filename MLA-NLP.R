library(tidyverse)

# GENERAL TWEETS FIRST DAYS ---------------------------------------------
load("/Users/renatorusso/Desktop/TLTLAB/Ukraine analysis/ukraine_feb_24.Rda")
ukr_early1 <- as_tibble(ukraine_feb_24_real)

# DATA CLEANING AND WRANGLING ---------------------------------------------
## creating a function to remove numbers and punctuation
## in preliminary analysis, I noticed that the prevalence of "Ukraine" made it
## challenging to draw any conclusion from the sentiment analysis, so I decided 
## to remove it too. I'm also using the custom function to remove a few words
## detected when I ran posterior parts of this analysis

clean_text <- function(text) {
  text <- tolower(text)
  text <- gsub("[[:digit:]]+", "", text)
  text <- gsub("[[:punct:]]+", "", text)
  text <- gsub("ukraine", "", text)
  return(text)
}

## cleaning the text
ukr_early1$text <- clean_text(ukr_early1$text)

## tokenizing the words in the "text" column
tweets_token <- ukr_early1 %>% 
  tidytext::unnest_tokens(word, text) %>% 
  count(status_id, word)

tweets_token

## removing stop words from tidy text's standard library
tweets_token <- tweets_token %>% 
  anti_join(tidytext::get_stopwords())

## removing more stop words by creating a custom list of stop words that appeared
## when I first ran posterior parts of this analysis
my_stopwords_ukr <- tibble(word = c(as.character(1:10),
                                    "like", "dont", "de", "la", "en",
                                    "amp", "et", "le", "les", "I", "à", "des", "pas",
                                    "guerre", "russie", "cest", "krieg", "breitbartnews",
                                    "cnn", "msnbc", "foxnews"))

tweets_token <- tweets_token %>% 
  anti_join(my_stopwords_ukr)

## creating a document-text matrix
DTM <- tweets_token %>% 
  tidytext::cast_dtm(status_id, word, n)

DTM

# EXPLORATORY ANALYSIS ----------------------------------------------------
## looking at the document-term matrix
tweets_token %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))


# TOPIC MODELING ----------------------------------------------------------
library(topicmodels)
## running Latent Drichlet Allocation (LDA)
LDA <- topicmodels::LDA(DTM, k = 4, control = list(seed = 123))
LDA_td <- tidytext::tidy(LDA)
LDA_td

## visualizing topics using ggplot2() and tidytext()
library(tidytext)

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
  scale_x_reordered() +
  labs(title = "Topics in general tweets early in the war")

NATOlibrary(widyr)
word_pairs_ukr_early <- tweets_token %>% 
  pairwise_count(word, status_id, sort = TRUE, upper = FALSE)

#network of co-occurring words
library(ggplot2)
library(igraph)
library(ggraph)

word_pairs_ukr_early %>%
  filter(n >= 200) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void() +
  labs(title = "Co-occurring terms in general tweets early in the war")


# GENERAL TWEETS 20 DAYS INTO THE WAR ---------------------------------------------
load("/Users/renatorusso/ukraine_mar_16.Rda")
ukr_20 <- as_tibble(ukraine_mar_16)

# DATA CLEANING AND WRANGLING ---------------------------------------------

## cleaning the text
ukr_20$text <- clean_text(ukr_20$text)

## tokenizing the words in the "text" column
tweets_token_20 <- ukr_20 %>% 
  tidytext::unnest_tokens(word, text) %>% 
  count(status_id, word)

## removing stop words from tidy text's standard library
tweets_token_20 <- tweets_token_20 %>% 
  anti_join(stop_words)

## words in German and French have not been removed with the "stop_words" native
## dataset (and they appear a lot), so I'll try to include the word databases 
## "manually"
stop_german <- data.frame(word = stopwords::stopwords("de"), stringsAsFactors = FALSE)

stop_french <- data.frame(word = stopwords::stopwords("fr"), stringsAsFactors = FALSE)

tweets_token_20 <-  tweets_token_20 %>% 
  anti_join(stop_words, by = c('word')) %>%
  anti_join(stop_german, by = c("word")) %>% 
  anti_join(stop_french, by = c("word"))

tweets_token_20 <- tweets_token_20 %>% 
  anti_join(my_stopwords_ukr)

## creating a document-text matrix
DTM_20 <- tweets_token_20 %>% 
  tidytext::cast_dtm(status_id, word, n)

# EXPLORATORY ANALYSIS ----------------------------------------------------
## looking at the document-term matrix
tweets_token_20 %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))


# TOPIC MODELING ----------------------------------------------------------
#library(topicmodels)
## running Latent Drichlet Allocation (LDA)
LDA_20 <- topicmodels::LDA(DTM_20, k = 4, control = list(seed = 123))
LDA_td_20 <- tidytext::tidy(LDA_20)
LDA_td_20

topTerms_20 <- LDA_td_20 %>% 
  group_by(topic) %>% 
  top_n(7, beta) %>% 
  arrange(topic, -beta)

topTerms_20 %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_x") +
  coord_flip() +
  scale_x_reordered() +
  labs(title = "Topics in general tweets 20 days into the war")

word_pairs_ukr_20 <- tweets_token_20 %>% 
  pairwise_count(word, status_id, sort = TRUE, upper = FALSE)

#network of co-occurring words
word_pairs_ukr_20 %>%
  filter(n >= 100) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void() +
  labs(title = "Co-occurring terms in general tweets 20 days into the war")

# CNN-RELATED EARLY TWEETS ---------------------------------------------
load("/Users/renatorusso/Desktop/TLTLAB/Ukraine analysis/ukraine_cnn_feb_25.Rda")
ukr_early_cnn <- as_tibble(ukraine_cnn_feb_25)
View(ukr_early_cnn)
# DATA CLEANING AND WRANGLING ---------------------------------------------

## cleaning the text
ukr_early_cnn$text <- clean_text(ukr_early_cnn$text)

## tokenizing the words in the "text" column
tweets_token_cnn_early <- ukr_early_cnn %>% 
  tidytext::unnest_tokens(word, text) %>% 
  count(status_id, word)

## removing stop words from tidy text's standard library
tweets_token_cnn_early <- tweets_token_cnn_early %>% 
  anti_join(stop_words)

tweets_token_cnn_early <-  tweets_token_cnn_early %>% 
  anti_join(stop_words, by = c('word')) %>%
  anti_join(stop_german, by = c("word")) %>% 
  anti_join(stop_french, by = c("word"))

tweets_token_cnn_early <- tweets_token_cnn_early %>% 
  anti_join(my_stopwords_ukr)

## creating a document-text matrix
DTM_early_cnn <- tweets_token_cnn_early %>% 
  tidytext::cast_dtm(status_id, word, n)

# EXPLORATORY ANALYSIS ----------------------------------------------------
## looking at the document-term matrix
tweets_token_cnn_early %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))


# TOPIC MODELING ----------------------------------------------------------
#library(topicmodels)
## running Latent Drichlet Allocation (LDA)
LDA_cnn_early <- topicmodels::LDA(DTM_early_cnn, k = 4, control = list(seed = 123))
LDA_cnn_early_td <- tidytext::tidy(LDA_cnn_early)
LDA_cnn_early

topTerms_cnn_early <- LDA_cnn_early_td %>% 
  group_by(topic) %>% 
  top_n(7, beta) %>% 
  arrange(topic, -beta)

topTerms_cnn_early %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_x") +
  coord_flip() +
  scale_x_reordered() +
  labs(title = "Topics in CNN-related tweets early in the war")

word_pairs_cnn_early <- tweets_token_cnn_early %>% 
  pairwise_count(word, status_id, sort = TRUE, upper = FALSE)

## network of co-occurring words
word_pairs_cnn_early %>%
  filter(n >= 200) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void() +
  labs(title = "Co-occurring terms in CNN-related tweets early in the war")

# CNN-RELATED 20 DAYS INTO THE WAR ---------------------------------------------
load("/Users/renatorusso/ukraine_cnn_mar_16.Rda")
ukr_d20_cnn <- as_tibble(ukraine_cnn_mar_16)
View(ukr_d20_cnn)
# DATA CLEANING AND WRANGLING ---------------------------------------------

## cleaning the text
ukr_d20_cnn$text <- clean_text(ukr_d20_cnn$text)

## tokenizing the words in the "text" column
tweets_token_d20_cnn <- ukr_d20_cnn %>% 
  tidytext::unnest_tokens(word, text) %>% 
  count(status_id, word)

## removing stop words from tidy text's standard library
tweets_token_d20_cnn <- tweets_token_d20_cnn %>% 
  anti_join(stop_words)

tweets_token_d20_cnn <-  tweets_token_d20_cnn %>% 
  anti_join(stop_words, by = c('word')) %>%
  anti_join(stop_german, by = c("word")) %>% 
  anti_join(stop_french, by = c("word"))

tweets_token_d20_cnn <- tweets_token_d20_cnn %>% 
  anti_join(my_stopwords_ukr)

## creating a document-text matrix
DTM_d20_cnn <- tweets_token_d20_cnn %>% 
  tidytext::cast_dtm(status_id, word, n)

# EXPLORATORY ANALYSIS ----------------------------------------------------
## looking at the document-term matrix
tweets_token_d20_cnn %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))


# TOPIC MODELING ----------------------------------------------------------
#library(topicmodels)
## running Latent Drichlet Allocation (LDA)
LDA_d20_cnn <- topicmodels::LDA(DTM_d20_cnn, k = 4, control = list(seed = 123))
LDA_d20_cnn_td <- tidytext::tidy(LDA_d20_cnn)
LDA_d20_cnn

topTerms_d20_cnn <- LDA_d20_cnn_td %>% 
  group_by(topic) %>% 
  top_n(7, beta) %>% 
  arrange(topic, -beta)

topTerms_d20_cnn %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_x") +
  coord_flip() +
  scale_x_reordered() +
  labs(title = "Topics in CNN-related tweets 20 days into the war")

word_pairs_d20_cnn <- tweets_token_d20_cnn %>% 
  pairwise_count(word, status_id, sort = TRUE, upper = FALSE)

## network of co-occurring words
word_pairs_d20_cnn %>%
  filter(n >= 250) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void() +
  labs(title = "Co-occurring terms in CNN-related tweets 20 days into the war")

# BREITBART-RELATED EARLY TWEETS ---------------------------------------------
load("/Users/renatorusso/Desktop/TLTLAB/Ukraine analysis/ukraine_bb_feb_25.Rda")
ukr_early_bb <- as_tibble(ukraine_bb_feb_25)
View(ukr_early_bb)
# DATA CLEANING AND WRANGLING ---------------------------------------------

## cleaning the text
ukr_early_bb$text <- clean_text(ukr_early_bb$text)

## tokenizing the words in the "text" column
tweets_token_bb_early <- ukr_early_bb %>% 
  tidytext::unnest_tokens(word, text) %>% 
  count(status_id, word)

## removing stop words from tidy text's standard library
tweets_token_bb_early <- tweets_token_bb_early %>% 
  anti_join(stop_words)

tweets_token_bb_early <-  tweets_token_bb_early %>% 
  anti_join(stop_words, by = c('word')) %>%
  anti_join(stop_german, by = c("word")) %>% 
  anti_join(stop_french, by = c("word"))

tweets_token_bb_early <- tweets_token_bb_early %>% 
  anti_join(my_stopwords_ukr)

## creating a document-text matrix
DTM_early_bb <- tweets_token_bb_early %>% 
  tidytext::cast_dtm(status_id, word, n)

# EXPLORATORY ANALYSIS ----------------------------------------------------
## looking at the document-term matrix
tweets_token_bb_early %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))


# TOPIC MODELING ----------------------------------------------------------
#library(topicmodels)
## running Latent Drichlet Allocation (LDA)
LDA_bb_early <- topicmodels::LDA(DTM_early_bb, k = 4, control = list(seed = 123))
LDA_bb_early_td <- tidytext::tidy(LDA_bb_early)
LDA_bb_early

topTerms_bb_early <- LDA_bb_early_td %>% 
  group_by(topic) %>% 
  top_n(7, beta) %>% 
  arrange(topic, -beta)

topTerms_bb_early %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_x") +
  coord_flip() +
  scale_x_reordered() +
  labs(title = "Topics in Breitbart-related tweets early in the war")

word_pairs_bb_early <- tweets_token_bb_early %>% 
  pairwise_count(word, status_id, sort = TRUE, upper = FALSE)

## network of co-occurring words
word_pairs_bb_early %>%
  filter(n >= 50) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void() +
  labs(title = "Co-occurring terms in Breitbart-related tweets early in the war")

# BREITBART-RELATED 20 DAYS INTO THE WAR TWEETS ---------------------------------------------
load("/Users/renatorusso/ukraine_bb_mar_16.Rda")
ukr_d20_bb <- as_tibble(ukraine_bb_mar_16)
View(ukr_d20_bb)

# DATA CLEANING AND WRANGLING ---------------------------------------------

## cleaning the text
ukr_d20_bb$text <- clean_text(ukr_d20_bb$text)

## tokenizing the words in the "text" column
tweets_token_d20_bb <- ukr_d20_bb %>% 
  tidytext::unnest_tokens(word, text) %>% 
  count(status_id, word)

## removing stop words from tidy text's standard library
tweets_token_d20_bb <- tweets_token_d20_bb %>% 
  anti_join(stop_words)

tweets_token_d20_bb <-  tweets_token_d20_bb %>% 
  anti_join(stop_words, by = c('word')) %>%
  anti_join(stop_german, by = c("word")) %>% 
  anti_join(stop_french, by = c("word"))

tweets_token_d20_bb <- tweets_token_d20_bb %>% 
  anti_join(my_stopwords_ukr)

## creating a document-text matrix
DTM_d20_bb <- tweets_token_d20_bb %>% 
  tidytext::cast_dtm(status_id, word, n)

# EXPLORATORY ANALYSIS ----------------------------------------------------
## looking at the document-term matrix
tweets_token_d20_bb %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))


# TOPIC MODELING ----------------------------------------------------------
#library(topicmodels)
## running Latent Drichlet Allocation (LDA)
LDA_d20_bb <- topicmodels::LDA(DTM_d20_bb, k = 4, control = list(seed = 123))
LDA_d20_bb_td <- tidytext::tidy(LDA_d20_bb)
LDA_d20_bb

topTerms_d20_bb <- LDA_d20_bb_td %>% 
  group_by(topic) %>% 
  top_n(7, beta) %>% 
  arrange(topic, -beta)

topTerms_d20_bb %>% 
  mutate(term = reorder_within(term, beta, topic)) %>% 
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free_x") +
  coord_flip() +
  scale_x_reordered() +
  labs(title = "Topics in Breitbart-related tweets 20-days into the war")

word_pairs_d20_bb <- tweets_token_d20_bb %>% 
  pairwise_count(word, status_id, sort = TRUE, upper = FALSE)

## network of co-occurring words
word_pairs_d20_bb %>%
  filter(n >= 25) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void() +
  labs(title = "Co-occurring terms in Breitbart-related tweets 20 days into the war")

library(tidyverse)
library(tidygraph)
library(tuber)
library(tidytext)
library(tm) #I use here to remove stop words
YT_client_id <- "113759878461-gp15t6i0l6v8cms91r1hp2v44que1dip.apps.googleusercontent.com"
YT_client_secret <- "vboHlA-0mghQVEyazNjwKFDv"

# use the youtube oauth 
yt_oauth(app_id = YT_client_id,
         app_secret = YT_client_secret,
         token = '')

#Get All the Comments Including Replies 
comments_YT_turismo <- get_all_comments(video_id = "bdfRebIp00c")
View(comments_YT_turismo)
as.data.frame(comments_YT_turismo)

comments_YT_turismo <- comments_YT_turismo %>% 
  unnest_tokens(word, textOriginal) %>% 
  anti_join(stop_words)

#removing stopword
comments_YT_turismo$word = removeWords(comments_YT_turismo$word, stopwords("portuguese"))

comments_YT_turismo %>%
  count(word, sort = TRUE)


#Removing more stop words by creating a custom list of stop words
my_stopwords <- tibble(word = c(as.character(1:10), 
                                "é", "vai", "pra", "vc", "ser", "canal", 
                                "aqui", "aí", "pois"))
#updating the dataframe, now without the sto pwords removed above
comments_YT_turismo <- comments_YT_turismo %>% 
  anti_join(my_stopwords)

# using pairwise_count() from the widyr package to count how many times each 
# pair of words occurs together in a title or description field.
install.packages("widyr")
library(widyr)

word_pairs <- comments_YT_turismo %>% 
  pairwise_count(word, id, sort = TRUE, upper = FALSE)

View(word_pairs)

#network of co-occurring words
library(ggplot2)
library(igraph)
library(ggraph)


word_pairs %>%
  filter(n >= 50) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void()

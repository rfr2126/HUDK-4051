library(tidyverse)
library(tidygraph)
library(tuber)
library(tidytext)
library(tm) #I use here to remove stop words
YT_client_id <- "113759878461-gp15t6i0l6v8cms91r1hp2v44que1dip.apps.googleusercontent.com"
YT_client_secret <- "GOCSPX-"

# use the youtube oauth 
yt_oauth(app_id = YT_client_id,
         app_secret = YT_client_secret,
         token = '')

#Get All the Comments Including Replies 
comments_YT_turismo <- get_all_comments(video_id = "bdfRebIp00c")
View(comments_YT_turismo)
as.data.frame(comments_YT_turismo)

comments_YT_Nov20 <- comments_YT_turismo

comments_YT_turismo <- comments_YT_turismo %>% 
  unnest_tokens(word, textOriginal) %>% 
  anti_join(stop_words)

#removing stop words
comments_YT_turismo$word = removeWords(comments_YT_turismo$word, stopwords("portuguese"))

#Removing more stop words by creating a custom list of stop words
my_stopwords <- tibble(word = c(as.character(1:10), 
                                "é", "vai", "pra", "vc", "ser", "canal", 
                                "aqui", "aí", "pois", "vai", "tudo", "pra",
                                "todos", "bom", "presidente", "deus", "abençoe", 
                                "vou", "fechou", "youtube", "https", "tirar",
                                "cara", "tá", "fez", "ainda", "vão", "quer", "anos",
                                "vez", "ver", "porque", "youtu.be", "ter", "vamos",
                                "agora", "gente", "homem", "obrigado", "todo", "opah",
                                "ah", "pessoas", "desde", "poderia", "votar", "abençoa",
                                "inscreva", "contra", "tarde", "ama", "brasil", "acima",
                                "nada", "frente", "jair", "esqueça", "semana", "mundo",
                                "melhor", "juntos", "brasileiros", "fechado", "bem",
                                "fazer", "dia", "senhor", "boa", "inscreve", "agradeço",
                                "paz", "atenção", "gratidão"))

#updating the dataframe, now without the stop words removed above
comments_YT_turismo <- comments_YT_turismo %>% 
  anti_join(my_stopwords)

#updating the data frame to remove rows with empty cells for the column "word"
comments_YT_turismo <- comments_YT_turismo[-which(comments_YT_turismo$word == ""), ]

comments_YT_turismo %>%
  count(word, sort = TRUE)

View(comments_YT_turismo)
# using pairwise_count() from the widyr package to count how many times each 
# pair of words occurs together in a title or description field.
#install.packages("widyr")
library(widyr)

word_pairs <- comments_YT_turismo %>% 
  pairwise_count(word, id, sort = TRUE, upper = FALSE)

# [not working: R crashes] using gsub to replace singular instance of "mayor" for the plural
# reference: https://statisticsglobe.com/r-replace-specific-characters-in-string
# gsub("prefeito", "prefeitos", word_pairs)

View(word_pairs)

#network of co-occurring words
library(ggplot2)
library(igraph)
library(ggraph)


word_pairs %>%
  filter(n >= 8) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void()

#correlation among terms
terms_cors <- comments_YT_turismo %>% 
  group_by(word) %>%
  filter(n() >= 50) %>%
  pairwise_cor(word, id, sort = TRUE, upper = FALSE)

#https://www.tidytextmining.com/nasa.html?q=nasa#how-data-is-organized-at-nasa


# Recent video ------------------------------------------------------------

comments_YT_turismo <- get_all_comments(video_id = "gOITkhNLUY4")
comments_YT_recent <- get_all_comments(video_id = "gOITkhNLUY4")

View(comments_YT_recent)
as.data.frame(comments_YT_turismo)

comments_YT_Nov20 <- comments_YT_turismo

comments_YT_turismo <- comments_YT_turismo %>% 
  unnest_tokens(word, textOriginal) %>% 
  anti_join(stop_words)

#removing stop words
comments_YT_turismo$word = removeWords(comments_YT_turismo$word, stopwords("portuguese"))

#Removing more stop words by creating a custom list of stop words
my_stopwords <- tibble(word = c(as.character(1:10), 
                                "é", "vai", "pra", "vc", "ser", "canal", 
                                "aqui", "aí", "pois", "vai", "tudo", "pra",
                                "todos", "bom", "presidente", "deus", "abençoe", 
                                "vou", "fechou", "youtube", "https", "tirar",
                                "cara", "tá", "fez", "ainda", "vão", "quer", "anos",
                                "vez", "ver", "porque", "youtu.be", "ter", "vamos",
                                "agora", "gente", "homem", "obrigado", "todo", "opah",
                                "ah", "pessoas", "desde", "poderia", "votar", "abençoa",
                                "inscreva", "contra", "tarde", "ama", "brasil", "acima",
                                "nada", "frente", "jair", "esqueça", "semana", "mundo",
                                "melhor", "juntos", "brasileiros", "fechado", "bem",
                                "fazer", "dia", "senhor", "boa", "inscreve", "agradeço",
                                "paz", "atenção", "gratidão"))

#updating the dataframe, now without the stop words removed above
comments_YT_turismo <- comments_YT_turismo %>% 
  anti_join(my_stopwords)

#updating the data frame to remove rows with empty cells for the column "word"
comments_YT_turismo <- comments_YT_turismo[-which(comments_YT_turismo$word == ""), ]

comments_YT_turismo %>%
  count(word, sort = TRUE)

View(comments_YT_turismo)
# using pairwise_count() from the widyr package to count how many times each 
# pair of words occurs together in a title or description field.
#install.packages("widyr")
library(widyr)

word_pairs <- comments_YT_turismo %>% 
  pairwise_count(word, id, sort = TRUE, upper = FALSE)

# [not working: R crashes] using gsub to replace singular instance of "mayor" for the plural
# reference: https://statisticsglobe.com/r-replace-specific-characters-in-string
# gsub("prefeito", "prefeitos", word_pairs)

View(word_pairs)

#network of co-occurring words
library(ggplot2)
library(igraph)
library(ggraph)


word_pairs %>%
  filter(n >= 8) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void()

#correlation among terms
terms_cors <- comments_YT_turismo %>% 
  group_by(word) %>%
  filter(n() >= 50) %>%
  pairwise_cor(word, id, sort = TRUE, upper = FALSE)

# Recent video ------------------------------------------------------------
library(httpuv)
library(tidyverse)
#library(tidygraph)
library(tuber)
library(tidytext) #used to most text analysis in this project 
library(tm) #used here to remove stop words
library(widyr) #used for pairwise count (pairwise_count())
library(ggraph) #used for the co-occurence chart
library(igraph) #used for the co-occurence chart

YT_client_id <- "113759878461-gp15t6i0l6v8cms91r1hp2v44que1dip.apps.googleusercontent.com"
YT_client_secret <- "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"

# use the youtube oauth
yt_oauth(app_id = YT_client_id,
         app_secret = YT_client_secret,
         token = '')

#Get All the Comments Including Replies
comments_YT_recent <- get_all_comments(video_id = "pWsxDp78XQY")

View(comments_YT_recent)
as.data.frame(comments_YT_recent)

comments_YT_recent <- comments_YT_recent %>% 
  unnest_tokens(word, textOriginal) %>% 
  anti_join(stop_words)

#removing stop words
comments_YT_recent$word = removeWords(comments_YT_recent$word, stopwords("portuguese"))

#Removing more stop words by creating a custom list of stop words
my_stopwords <- tibble(word = c(as.character(1:10), 
                                "é", "vai", "pra", "vc", "ser", "canal", 
                                "aqui", "aí", "pois", "vai", "tudo", "pra",
                                "todos", "bom", "presidente", "deus", 
                                "vou", "fechou", "youtube", "https", "tirar",
                                "cara", "tá", "fez", "ainda", "vão", "quer", "anos",
                                "vez", "ver", "porque", "youtu.be", "ter", "vamos",
                                "agora", "gente", "homem", "obrigado", "todo", "opah",
                                "ah", "pessoas", "desde", "poderia", "votar", "lá",
                                "inscreva", "contra", "tarde", "ama", "brasil", "acima",
                                "nada", "frente", "jair", "esqueça", "semana", "mundo",
                                "melhor", "juntos", "brasileiros", "fechado", "bem",
                                "fazer", "dia", "senhor", "boa", "inscreve", "agradeço",
                                "paz", "atenção", "gratidão", "muita", "dar", "muitos",
                                "sobre", "ta", "kkk", "onde", "outros", "vcs", "pro",
                                "ai", "kkkk", "olha", "tão", "coisas", "faz",
                                "hoje", "dizer", "continue", "meio", "acho"))

#updating the dataframe, now without the stop words removed above
comments_YT_recent <- comments_YT_recent %>% 
  anti_join(my_stopwords)

#updating the data frame to remove rows with empty cells for the column "word"
comments_YT_recent <- comments_YT_recent[-which(comments_YT_recent$word == ""), ]


comments_YT_recent %>%
  count(word, sort = TRUE)

View(comments_YT_recent)
# using pairwise_count() from the widyr package to count how many times each 
# pair of words occurs together in a title or description field.
#install.packages("widyr")
library(widyr)

word_pairs <- comments_YT_recent %>% 
  pairwise_count(word, id, sort = TRUE, upper = FALSE)

word_pairs %>%
  filter(n >= 8) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void()


#coding scheme  - 1st coding scheme to represent knowledge, then code 
  # with the coding scheme, simplify the network

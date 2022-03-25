library(httpuv) #httpuv package needed to run the ytoauth()
library(tidyverse) #used for the pipe operator %>%, part of magrittr; and tibble()
#library(tidygraph)
library(tuber) #used for yt_oauth(), get_all_comments()
library(tidytext) #used for unnest_tokens() other text analysis functions in this project 
library(tm) #used here to remove stop words
library(widyr) #used for pairwise count (pairwise_count())
library(ggraph) #used for the co-occurence chart
library(igraph) #used for the co-occurence chart

YT_client_id <- ""
YT_client_secret <- ""

# use the youtube oauth
yt_oauth(app_id = YT_client_id,
         app_secret = YT_client_secret,
         token = '')

#Get All the Comments Including Replies 
comments_YT_Nov20 <- get_all_comments(video_id = "bdfRebIp00c")

#just checking if data were imported correctly from YouTube
View(comments_YT_Nov20)

#converting imported data to dataframe
as.data.frame(comments_YT_Nov20)

#saving a local copy 
write.csv(comments_YT_Nov20, file = "comments_YT_Nov20.csv") 

# loading local file
comments_YT_Nov20 <- read_csv("comments_YT_Nov20.csv")

#unnesting tokens, that is, separating each word and assigning each one to a row
# of the dataframe
comments_YT_Nov20 <- comments_YT_Nov20 %>% 
  unnest_tokens(word, textOriginal) %>% 
  anti_join(stop_words)

#removing stop words
comments_YT_Nov20$word = removeWords(comments_YT_Nov20$word, stopwords("portuguese"))

#Removing more stop words by creating a custom list of stop words
my_stopwords <- tibble(word = c(as.character(1:10), 
                                "é", "vai", "pra", "vc", "ser", "canal", 
                                "aqui", "aí", "pois", "vai", "tudo", "pra",
                                "todos", "bom", "presidente", "deus", "aben?oe", 
                                "vou", "fechou", "youtube", "https", "tirar",
                                "cara", "tá", "fez", "ainda", "vão", "quer", "anos",
                                "vez", "ver", "porque", "youtu.be", "ter", "vamos",
                                "agora", "gente", "homem", "obrigado", "todo", "opah",
                                "ah", "pessoas", "desde", "poderia", "votar", "aben?oa",
                                "inscreva", "contra", "tarde", "ama", "brasil", "acima",
                                "nada", "frente", "jair", "esqueça", "semana", "mundo",
                                "melhor", "juntos", "brasileiros", "fechado", "bem",
                                "paz", "atenção", "gratidão", "nao", "parabéns",
                                "sim", "desse", "país", "ficar", "assim", "fala",
                                "sr", "pode", "coisa", "ninguém", "dr", "ctba",
                                "bruno", "engler", "allex", "emelly", "maria",
                                "angélica", "belo", "horizonte", "marcelo", "mindo",
                                "bvp", "engenharia", "mp6a5xi23bg", "assista", 
                                "próximas", "ganhar", "deixa", "viu", "coisas",
                                "falar", "existe", "mandou", "lindo", "toda",
                                "nome", "inscreve", "noite", "guarde", "obrigada",
                                "dá", "pouco", "pq", "disse", "queria",
                                "fazer", "dia", "senhor", "boa", "inscreve", "agradeço",
                                "paz", "atenção", "gratidão", "muita", "dar", "muitos",
                                "sobre", "ta", "kkk", "onde", "outros", "vcs", "pro",
                                "ai", "kkkk", "olha", "tão", "coisas", "faz",
                                "hoje", "dizer", "continue", "meio", "acho",
                                "vi", "fazer", "favor", "sendo", "então", "dar",
                                "querem", "dia"))

#updating the dataframe, now without the stop words frmo the custom list created above
comments_YT_Nov20 <- comments_YT_Nov20 %>% 
  anti_join(my_stopwords)

#updating the data frame to remove rows with empty cells for the column "word"
comments_YT_Nov20 <- comments_YT_Nov20[-which(comments_YT_Nov20$word == ""), ]

# creating a local file of the dataframe, without stopword identified and the blank spaces
write.csv(comments_YT_Nov20, file = "comments_YT_Nov20.csv") 

# loading updated local file
comments_YT_Nov20 <- read_csv("comments_YT_Nov20.csv")

# counting occurence of words
comments_YT_Nov20 %>%
  count(word, sort = TRUE)

#checking again, just to make sure the stop words and blank cells have been removed
View(comments_YT_Nov20)

word_pairs_nov20 <- comments_YT_Nov20 %>% 
  pairwise_count(word, id, sort = TRUE, upper = FALSE)

# the pair of write() and read() functions should not be executed, because they
# turn the tibble into a .csv file, which can't be properly read to generate the 
# plot of co-occurring words
# writing a local file with the word pairs
# write.csv(word_pairs_nov20, file = "word_pairs_Nov20.csv") 

#loading the local file for word_pairs_count
# word_pairs_nov20 <- read_csv("word_pairs_Nov20.csv")

# [not working: R crashes] using gsub to replace singular instance of "mayor" for the plural
# reference: https://statisticsglobe.com/r-replace-specific-characters-in-string
# gsub("prefeito", "prefeitos", word_pairs)

View(word_pairs_nov20)

#network of co-occurring words

word_pairs_nov20 %>%
  filter(n >= 9) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void()

#https://www.tidytextmining.com/nasa.html




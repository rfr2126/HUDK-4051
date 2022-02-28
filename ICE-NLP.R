library(tidyverse)
library(tm)

comments_bar <- read.csv("/Users/renatorusso/Desktop/Ed.D./HUDK-4051/comments_YT_barroso_raw.csv")
comments_bar

# creating a dataset with only the conments
comments_bar_text <- as_tibble(c(comments_bar$textOriginal, comments_bar$id))

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

comment_token <- comments_bar_text %>% 
  tidytext::unnest_tokens(word, value) %>% 
  count(id, word)

# removing stopwords. I'm using a different method (with the tm package) 
# to include stop words in Portuguese
comment_token$word = removeWords(comment_token$word, stopwords("portuguese"))

DTM <- comment_token %>% 
  tidytext::cast_dtm(id, word, n)

DTM

comment_token %>% 
  group_by(word) %>% 
  summarize(occurrence = sum(n)) %>% 
  arrange(desc(occurrence))

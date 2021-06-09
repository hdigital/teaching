library(tidytext)   # text analysis --- https://www.tidytextmining.com/
library(stopwords)  # stop words data (e.g. and, or, und, oder)
library(rtweet)     # get Twitter data --- https://docs.ropensci.org/rtweet/

library(tidyverse)


## Twitter data ----

get_token()       # is authorization set up on this machine?  --- see `setup-authorization.R`
language <- "en"  # set language for Twitter search and stopwords list

# tw_df <- search_tweets("covid19", n = 200, include_rts = FALSE, lang = "en")
tw_df <- get_timeline("potus", n = 200)

# rtweet::write_as_csv(tw_df, "tweets.csv")

ts_plot(tw_df, by = "week")  # options time interval: minute, hour, day, week, month, year


## Text analysis ----

# tweets text into tokens with tidytext
tw_tk <- 
  tw_df %>%
  mutate(text = str_replace_all(text, "\\W+", " ")) %>%  # remove all non-word characters
  unnest_tokens(word, text)

# clean-up tokens
words_to_remove <- c("https", "t.co")
tk_clean <- 
  tw_tk %>% 
  filter(
    ! word %in% stopwords(language = language),
    ! word %in% words_to_remove,
    str_length(word) > 3
)

# count number of tokens
tk_count <- 
  tk_clean %>% 
  count(word) %>%                       # count words
  slice_max(n, n = 15) %>%              # select top entries
  mutate(word = fct_reorder(word, n))   # create factor ordered for plot 

# plot most frequent tokens
pl <- 
  ggplot(tk_count, aes(x = word, y = n)) +
  geom_col() +   # bar chart for number of words
  xlab(NULL) +   # no label on x-axis
  coord_flip()   # words on y-axis

print(pl)
ggsave("tweets.png", pl, width = 4, height = 3)

library(tidyverse)
library(twitteR)
library(quanteda)


# Authentication Twitter ----

# ADD YOUR PERSONAL TWITTER API ACCESS (OAuth access token)
# see https://dev.twitter.com/oauth/overview/application-owner-access-tokens
options(httr_oauth_cache = FALSE)  # skip required user input next line
twitteR::setup_twitter_oauth(
  "YOUR_CONSUMER_KEY",
  "YOUR_CONSUMER_SECRET",
  "YOUR_ACCESS_TOKEN",
  "YOUR_ACCESS_TOKEN_SECRET"
)


# Search Twitter ----

search_term <- "covid"
tweets <- twitteR::searchTwitter(search_term, n = 250)
# tweets <- twitteR::userTimeline(search_term, n = 250)
tw_df <- twListToDF(tweets)


# Text analysis ----

tw_cp <- corpus(tw_df %>% select(id, created, text),
                text_field = "text")

tw_dfm <- 
  tw_cp %>% 
  tokens(remove_punct = TRUE) %>% 
  tokens_remove(phrase(c(stopwords("en"), search_term, "http*", "news", "rt", "t.co"))) %>% 
  dfm()


# Visualize results ----

textplot_wordcloud(tw_dfm)


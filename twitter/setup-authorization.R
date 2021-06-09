## see https://cran.r-project.org/web/packages/rtweet/vignettes/auth.html
## note — never permanently save your API keys (and share, commit, post them)

library(rtweet)

create_token(
  app = "YOUR_TWITTER_APP_NAME",
  consumer_key = "YOUR_CONSUMER_KEY",
  consumer_secret = "YOUR_CONSUMER_SECRET",
  access_token = "YOUR_ACCESS_TOKEN",
  access_secret = "YOUR_ACCESS_TOKEN_SECRET"
  )

# check if authorization is set up on this machine
get_token()

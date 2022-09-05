library(tidyverse)
library(haven)

## Data preparation ----

wid_raw <- read_dta("4-wid-bundeslaender/source__daten/widvote.dta")
laender <- read_csv("4-wid-bundeslaender/source__daten/laender-namen.csv")

wid_all <- 
  wid_raw %>% 
  filter(
    level == "ltw",
    ! party %in% c("divleft", "divright", "electors", "independent",
                   "invalid","other", "valid", "voters"),
    ! state %in% c("bd", "beo", "wb", "wh"),
    date > "1950-01-01",
    ! (date < "1990-01-01" & state %in% c("bb", "mv", "sn", "st", "th")),
    ! (date < "1990-01-01" & party == "linke"),
    ! (date < "1955-01-01" & state == "sl")
  ) %>% 
  left_join(laender)

write_csv(wid_all, "4-wid-bundeslaender/source__daten/wid-ergebnisse.csv", na = "")

votes_p_max <- 
  wid_all %>% 
  group_by(party) %>% 
  mutate(votes_p_max = max(votes_p)) %>% 
  filter(votes_p_max == votes_p) %>% 
  distinct(state, date, party, votes_p_max) %>% 
  arrange(desc(votes_p_max))


## Plot all states ----

party_main <- c("CDU", "SPD", "FDP", "B90GR", "LINKE", "rechts", "andere")
party_color <- c("#1F78B4", "#E31A1C", "#FDBF6F", "#33A02C", "#FB9A99", "#A6CEE3", "darkgrey")
names(party_color) <- party_main 
party_rechts <- c("AfD", "DVU", "NPD", "Rep", "Schill")

df_pl <-
  wid_all %>%
  mutate(
    party = case_when(
      party == "csu" ~ "cdu",
      party %in% tolower(party_rechts) ~ "rechts",
      TRUE ~ party
    ),
    party_upper = case_when(
      toupper(party) %in% party_main ~ toupper(party),
      party == "rechts" ~ "rechts",
      TRUE ~ "andere"
    )
  ) %>%
  group_by(state_name, date, party_upper) %>%
  summarise(votes_p = sum(votes_p, na.rm = TRUE)) %>%
  mutate(
    Jahr = lubridate::ymd(date),
    `Stimmen (%)` = votes_p,
    Partei = parse_factor(party_upper, party_main)
  ) %>% 
  filter(Jahr >= "1990-01-01")


### Line plot ----

pl1 <- 
  ggplot(df_pl, aes(x = Jahr, y = `Stimmen (%)`, color = Partei)) +
  scale_color_manual(values = party_color) +
  geom_hline(yintercept = 5, linetype = "dotted", color = "grey") +
  labs(caption = paste("[ rechts ] –", paste(party_rechts, collapse = ", "))) +
  geom_line() + 
  facet_wrap(~ state_name)

print(pl1)
ggsave("4-wid-bundeslaender/wid-ergebnisse-a.png", pl1, width = 8, height = 6)


### Area plot ----

party_lr <- c("rechts", "CDU", "FDP", "andere", "SPD", "B90GR", "LINKE")

df_pl2 <- 
  df_pl %>% 
  mutate(Partei = fct_relevel(Partei, party_lr))

pl2 <- 
  ggplot(df_pl2, aes(x = Jahr, y = `Stimmen (%)`, fill = Partei)) +
  scale_color_manual(values = party_color) +
  geom_area(position = "stack")  + 
  scale_fill_manual(values = map_chr(party_lr, ~ party_color[[.x]])) +
  geom_hline(yintercept = 50, linetype = "dotted", color = "grey") +
  labs(caption = paste("[ rechts ] –", paste(party_rechts, collapse = ", "))) + 
  facet_wrap(~ state_name)

print(pl2)
ggsave("4-wid-bundeslaender/wid-ergebnisse-b.png", pl2, width = 8, height = 6)


### Area plot (East) ----

df_pl3 <- 
  df_pl2 %>%
  left_join(laender) %>% 
  filter(east == 1 | state == "be")
  

pl3 <- 
  ggplot(df_pl3, aes(x = Jahr, y = `Stimmen (%)`, fill = Partei)) +
  scale_color_manual(values = party_color) +
  geom_area(position = "stack")  + 
  scale_fill_manual(values = map_chr(party_lr, ~ party_color[[.x]])) +
  geom_hline(yintercept = 50, linetype = "dotted", color = "grey") +
  labs(caption = paste("[ rechts ] –", paste(party_rechts, collapse = ", "))) + 
  facet_wrap(~ state_name)

print(pl3)
ggsave("4-wid-bundeslaender/wid-ergebnisse-c.png", pl3, width = 8, height = 6)

library(tidyverse)
library(haven)

## Daten aufbereiten ----------------------------------------------------------

wid_raw <- read_dta("daten/wahlen-in-dtl/widvote_long.dta")
laender <- read_csv("daten/wahlen-in-dtl/state_names.csv")

wid_all <- 
  wid_raw %>% 
  filter(
    ! party %in% c("divleft", "divright", "electors", "independent",
                   "invalid","other", "valid", "voters"),
    ! state %in% c("bd", "beo", "wb", "wh"),
    date > "1950-01-01",
    ! (date < "1990-01-01" & state %in% c("bb", "mv", "sn", "st", "th")),
    ! (date < "1990-01-01" & party == "linke"),
    ! (date < "1955-01-01" & state == "sl")
  ) %>% 
  mutate(
    party = ifelse(party == "csu", "cdu", party),
    party_upper = toupper(party)
    ) %>% 
  left_join(laender)

write_csv(wid_all, "daten/wahlen-in-dtl/wid-ergebnisse.csv")


## Graphs all states ----------------------------------------------------------

party_main <- c("CDU", "SPD", "FDP", "B90GR", "LINKE", "andere")
party_color <- c("#1F78B4", "#E31A1C", "#FDBF6F", "#33A02C", "#FB9A99", "darkgrey")

df_pl <- 
  wid_all %>%
  mutate(party_upper = ifelse(party_upper %in% party_main, party_upper, "andere")) %>% 
  group_by(state_name, date, party_upper) %>% 
  summarise(votes_p = sum(votes_p, na.rm = TRUE)) %>%
  mutate(
    Jahr = lubridate::ymd(date),
    `Stimmen (%)` = votes_p,
    Partei = parse_factor(party_upper, party_main)
    )

pl <- ggplot(df_pl, aes(x = Jahr, y = `Stimmen (%)`, color = Partei)) +
  scale_color_manual(values = party_color) +
  geom_hline(yintercept = 5, linetype = "dotted", color = "grey")
  
pl1 <- pl +
  geom_line() + 
  facet_wrap(~ state_name)

ggsave("wid-ergebnisse.png", pl1, width = 8, height = 6)

print(pl + geom_smooth(se = FALSE))


# Graphs by state in pdf-document ---------------------------------------------

pdf("wid-ergebnisse-laender.pdf")

for(select_state_name in sort(unique(wid_all$state_name))) {
  # election results for state and main parties only
  wid_state <- 
    wid_all %>% 
    filter(state_name == select_state_name) %>% 
    arrange(date, -votes_p) %>% 
    group_by(date) %>% 
    mutate(position = 1:n())

  parties <- 
    wid_state %>% 
    filter(position <= 6) %>% 
    group_by(party_upper) %>% 
    filter(n() >= 4) %>% 
    summarise(votes_p_sum = sum(votes_p, na.rm = TRUE)) %>% 
    arrange(-votes_p_sum) %>% 
    pull(party_upper)
  
  df_pl <- 
    wid_state %>% 
    filter(party_upper %in% parties) %>% 
    mutate(
      Jahr = lubridate::ymd(date),
      `Stimmen (%)` = votes_p,
      Partei = parse_factor(party_upper, parties),
      Sitze = case_when(seats > 0 ~ 'Ja', TRUE ~ 'Nein')
      )
  
  pl <- ggplot(df_pl, aes(x = Jahr, y = `Stimmen (%)`, color = Partei)) + 
    geom_line() + 
    geom_point(aes(shape = Sitze), color = "darkgrey", size = 1) +
    geom_hline(yintercept = 5, linetype = "dotted", color = "grey") + 
    # scale_color_brewer(palette = "Dark2") +  # Set1
    labs(title = wid_state %>% pull(state_name) %>% first())
         # caption = "(Quelle: wahlen-in-deutschland.de)")
  print(pl)
}

dev.off()

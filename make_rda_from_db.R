library(RPostgreSQL)
library(DBI)
library(dplyr)
library(data.table)

pg = dbDriver("PostgreSQL")
con = dbConnect(pg, user="felipe", password="", host="localhost", port=5432, dbname="ayd")




### GAMES.RDA

games = readRDS("./data/games.rda")

months = c('January', 'February', 'March', "April", "May", "June", "July", "August", "September", "October", "November", "December")
ayd_games = as.tbl(dbGetQuery(con, 'select * from ayd_games'))

n_games = ayd_games %>% mutate(date = paste0(months[month], " ", year)) %>% 
  select(date, school, league, game=round, white, black, result, winner=win_player,
         diff=win_score, season)

saveRDS(data.table(n_games), file = './data/n_games.rda')


### RATINGS.RDA

#ratings = readRDS("./data/old_data/ratings.rda")

ayd_ratings = as.tbl(dbGetQuery(con, 'select * from ayd_ratings'))

max_season = max(ayd_ratings$season)
active_players = ayd_ratings %>% group_by(player) %>%
  summarize(active = max(season) == max_season)

sequence = unique(ayd_ratings %>% select(year, month, round)) %>% 
  arrange(year, month, round)
sequence$seq = seq_along(sequence$year)

ayd_ratings_mod = merge(ayd_ratings, sequence, by = c('year', 'month', 'round'))
ayd_ratings_mod = as.tbl(merge(ayd_ratings_mod, active_players, by = 'player')) 

n_ratings = ayd_ratings_mod %>% 
  mutate(date = paste0(months[month], " ", year)) %>%
  mutate(game=as.integer(round)) %>%
  arrange(year, month, player) %>%
  select(date, player, school, game, rating, seq, active, season)
  
saveRDS(data.table(n_ratings), file = './data/n_ratings.rda')

# PLAYER STATS

#player_stats = readRDS("./data/old_data/player_stats.rda")

white = ayd_games %>% mutate(player=white, opponent=black) %>% 
  group_by(player, school) %>%
  summarise(white_wins = sum(win_color == 'white'),
            white_total = n(),
            white_win_rate = white_wins/white_total)

black = ayd_games %>% mutate(player=black, opponent=white) %>% 
  group_by(player, school) %>%
  summarise(black_wins = sum(win_color == 'black'),
            black_total = n(),
            black_win_rate = black_wins/black_total)

n_player_stats_mod = as.tbl(merge(white, black, by=c('player', 'school'))) %>%
  mutate(wins = white_wins+black_wins, total=white_total+black_total, win_rate=wins/total)

n_player_stats = as.tbl(merge(n_player_stats_mod, active_players, by="player"))

saveRDS(data.table(n_player_stats), file = './data/n_player_stats.rda')


## PLAYER STAT SEASONS

#player_stats_seasons = readRDS("./data/old_data/player_stats_seasons.rda")

white = ayd_games %>% mutate(player=white, opponent=black) %>% 
  group_by(player, school, season) %>%
  summarise(white_wins = sum(win_color == 'white'),
            white_total = n(),
            white_win_rate = white_wins/white_total)

black = ayd_games %>% mutate(player=black, opponent=white) %>% 
  group_by(player, school, season) %>%
  summarise(black_wins = sum(win_color == 'black'),
            black_total = n(),
            black_win_rate = black_wins/black_total)

n_player_stats_seasons_mod = as.tbl(merge(white, black, by=c('player', 'school', 'season'))) %>%
  mutate(wins = white_wins+black_wins, total=white_total+black_total, win_rate=wins/total)

n_player_stats_seasons = as.tbl(merge(n_player_stats_seasons_mod, active_players, by="player"))

saveRDS(data.table(n_player_stats_seasons), file = './data/n_player_stats_seasons.rda')


## PAIRINGS

#pairings = readRDS("./data/old_data/pairings.rda")

white = ayd_games %>% mutate(player=white, opponent=black) %>% 
  group_by(school, player, opponent) %>%
  summarise(white_wins = sum(win_color == 'white'),
            white_total = n())

black = ayd_games %>% mutate(player=black, opponent=white) %>% 
  group_by(school, player, opponent) %>%
  summarise(black_wins = sum(win_color == 'black'),
            black_total = n())

n_pairings_mod = as.tbl(merge(white, black, by=c('school', 'player', 'opponent'), all = TRUE))

n_pairings_mod$white_wins[is.na(n_pairings_mod$white_wins)] = 0
n_pairings_mod$black_wins[is.na(n_pairings_mod$black_wins)] = 0
n_pairings_mod$white_total[is.na(n_pairings_mod$white_total)] = 0
n_pairings_mod$black_total[is.na(n_pairings_mod$black_total)] = 0

n_pairings = n_pairings_mod %>%
  mutate(wins = white_wins+black_wins, total=white_total+black_total)

saveRDS(data.table(n_pairings), file = './data/n_pairings.rda')


## PAIRING SEASONS

#pairings_season = readRDS("./data/old_data/pairings_season.rda")

white = ayd_games %>% mutate(player=white, opponent=black) %>% 
  group_by(school, season, player, opponent) %>%
  summarise(white_wins = sum(win_color == 'white'),
            white_total = n())

black = ayd_games %>% mutate(player=black, opponent=white) %>% 
  group_by(school, season, player, opponent) %>%
  summarise(black_wins = sum(win_color == 'black'),
            black_total = n())

n_pairings_season_mod = as.tbl(merge(white, black, by=c('school', 'season', 'player', 'opponent'), all = TRUE))

n_pairings_season_mod$white_wins[is.na(n_pairings_season_mod$white_wins)] = 0
n_pairings_season_mod$black_wins[is.na(n_pairings_season_mod$black_wins)] = 0
n_pairings_season_mod$white_total[is.na(n_pairings_season_mod$white_total)] = 0
n_pairings_season_mod$black_total[is.na(n_pairings_season_mod$black_total)] = 0

n_pairings_season = n_pairings_season_mod %>%
  mutate(wins = white_wins+black_wins, total=white_total+black_total)

saveRDS(data.table(n_pairings_season), file = './data/n_pairings_season.rda')


## SEASON RANK

#season_rank = readRDS("./data/old_data/season_ranks.rda")

n_season_rank = ayd_ratings %>% group_by(school, season, player) %>%
  arrange(year, month, round) %>%
  summarise(rating=tail(rating,1)) %>%
  arrange(school, season)

n_season_rank$rank = ave(n_season_rank$rating, n_season_rank$school, n_season_rank$season, FUN = function(x) {length(x)+1-rank(x, ties.method='min')})

saveRDS(data.table(n_season_rank), file = './data/n_season_ranks.rda')

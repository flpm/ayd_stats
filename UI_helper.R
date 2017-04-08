# UI Helper data and functions

season_ranks = readRDS("./data/n_season_ranks.rda")
player_names = sort(season_ranks[school == school_name & season == season_num, player])
ordered_player_names = season_ranks[school == school_name & season == season_num][order(rank), player]
selected_player_default = ordered_player_names[1]

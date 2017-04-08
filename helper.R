
library(data.table)
library(ggvis)
library(dplyr)


#####################
### Aux functions ###
#####################

prepare_wins_str = function(wins, total) {
  total_is_zero = total == 0
  result = paste0(wins, " of ", total, " (", round(wins*100/total, digits = 1), "%)")
  result[total_is_zero] = ""
  return(result)
}

######################################
### Functions called from Server.R ###
######################################


get_tooltip = function(x) {
  paste0("<span style='font-family: sans-serif; font-size: 12px'> ", x$player, "</span>")
}

get_school_plot = function(player_name) {
  
  player_data = ratings[school == school_name & player == player_name][order(seq)]
  
  school_plot %>%
    layer_points(fill := "white", opacity := 1, size := 20, stroke := "black", data = player_data) %>%
    layer_paths(tension = ~player, stroke := "black", opacity := 0.5, opacity.hover := 0.8, strokeWidth := 6, strokeWidth.hover := 8, data = player_data) %>%
    scale_nominal("tension", range = c(0,0))
  
}

get_player_names = function() {
  active_players = sort(unique(player_stats[active == TRUE & school == school_name, player]))
  names(active_players) = active_players
  
  inactives_players = sort(unique(player_stats[active == FALSE & school == school_name, player]))
  names(inactives_players) = paste(inactives_players, "<inactive>")
  
  player_names = c(active_players, inactives_players)
}

get_initial_player = function() {
  season_rank_table_data[1, player]
}

get_player_plot <- function(player_name, num_of_seasons = 1) {
  player_seasons = tail(sort(unique(pairings_season[player == player_name & school == school_name, season])), num_of_seasons)
  opponents = unique(pairings_season[player == player_name & season %in% player_seasons, opponent])
  plot_data = ratings[school == school_name & player %in% c(opponents)]
  player_data = ratings[school == school_name & player == player_name][order(seq)]
  
  plot_data %>%
    ggvis(~seq, ~rating, stroke = ~player) %>% 
    layer_points(fill := "white", opacity := 1, size := 20) %>%
    layer_points(fill := "white", opacity := 1, size := 20, stroke := "black", data = player_data) %>%
    layer_paths(tension = ~player, stroke := "black", opacity := 0.5, opacity.hover := 0.8, strokeWidth := 6, strokeWidth.hover := 8, data = player_data) %>%
    #add_tooltip(get_tooltip, "hover")   %>%
    layer_lines(stroke = ~player, opacity := 0.3, opacity.hover := 0.7, strokeWidth := 2, strokeWidth.hover := 6) %>%
    add_tooltip(get_tooltip, "hover")   %>%
    hide_legend(c("stroke", "fill")) %>%
    set_options(width = 900, height = 450) %>%
    add_axis("x", title = "YD game rounds") %>%
    add_axis("y", title = "") %>%
    scale_nominal("tension", range = c(0,0))
}  

get_player_season_stats = function(school_name, player_name) {
  overall = player_stats[school == school_name & player == player_name] 
  overall[,season := "overall"]
  data = rbind(overall, player_stats_seasons[school == school_name & player == player_name][order(season, decreasing = TRUE)]) 
  data[, 
       .(
         season,
         "as white" = prepare_wins_str(white_wins, white_total),
         "as black" = prepare_wins_str(black_wins, black_total),
         total = prepare_wins_str(wins, total)
       )]
}

get_pairing_stats = function(school_name, player_name) {
  data = pairings[school == school_name & player == player_name][order(total, decreasing = TRUE)] 
  data[, 
       .(
         against=opponent,
         "as white" = prepare_wins_str(white_wins, white_total),
         "as black" = prepare_wins_str(black_wins, black_total),
         total = prepare_wins_str(wins, total)
       )]
}

get_season_rank_table = function() {
  season_ranks_str
}

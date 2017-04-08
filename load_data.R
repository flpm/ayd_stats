

source("./config.R")

# load analysis data

games = readRDS("./data/n_games.rda")
ratings = readRDS("./data/n_ratings.rda")
player_stats = readRDS("./data/n_player_stats.rda")
player_stats_seasons = readRDS("./data/n_player_stats_seasons.rda")
pairings = readRDS("./data/n_pairings.rda")
pairings_season = readRDS("./data/n_pairings_season.rda")
season_rank = readRDS("./data/n_season_ranks.rda")

### pre compute school plot

school_plot = ratings[school == school_name & active == TRUE] %>% 
  ggvis(~seq, ~rating, stroke = ~player) %>% 
  layer_points(fill := "white", opacity := 1, size := 20) %>%
  layer_lines(stroke = ~player, opacity := 0.3, opacity.hover := 0.7, strokeWidth := 2, strokeWidth.hover := 6) %>%
  add_tooltip(get_tooltip, "hover")   %>%
  hide_legend(c("stroke", "fill")) %>%
  set_options(width = 900, height = 600) %>%
  add_axis("x", title = "YD game rounds") %>%
  add_axis("y", title = "") 


### pre compute table of school rank changes

season_ranks_num = dcast.data.table(data = season_ranks[season %in% c(season_num-1, season_num)], 
                                    formula = school+player~season, value.var = c("rank", "rating"))

names(season_ranks_num) = c("school", "player", "previous_rank", "rank", "previous_rating", "rating")

get_delta_str = function(previous, current, invert_sign = FALSE) {
  alpha = 1
  sign_str = ""
  if(invert_sign) {
    alpha = -1
  }
  if(!is.na(previous)) {
    delta = current - previous
    if(delta > 0) {
      if(!invert_sign) sign_str = "+"
      res = paste0(current, " (", sign_str, alpha*delta,")")
    }
    else if(delta < 0){
      if(invert_sign) sign_str = "+"
      res = paste0(current, " (", sign_str, alpha*delta,")")
    }
    else
      res = paste0(current, " (+", delta,")")
  }
  else
    res = paste0(current, "") 
  
  return(res)
}

season_ranks_str = season_ranks_num[school == school_name][order(rank)][!is.na(rank) & !is.na(rating),
                                    .(
                                      rank = get_delta_str(previous_rank, rank, invert_sign = TRUE),
                                      rating = get_delta_str(previous_rating, rating)
                                    ),
                                    by = .(school, player)][, .(player, rank, rating)]

season_ranks_str$rank = format(season_ranks_str$rank, justify = "l")
season_ranks_str$rating = format(season_ranks_str$rating, justify = "l")

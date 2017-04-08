
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

source("./config.R")
source("./load_data.R")
source("./helper.R")
source("./UI_helper.R")


shinyServer(function(input, output) {
  
  player_plot = reactive({
    get_player_plot(input$input_select_player)
  })
  
  school_plot = reactive({
    get_school_plot(input$input_select_player)
  })
  
  school_plot %>% bind_shiny("plot_school_rating")
  
  player_plot %>% bind_shiny("plot_player_rating")
  
  
  output$table_season_player_stats = renderDataTable({
    get_player_season_stats(school_name, input$input_select_player)
  }, options = list(paging = FALSE, searching = FALSE, info = FALSE, ordering = FALSE))

  output$table_overall_pairings = renderDataTable({
    get_pairing_stats(school_name, input$input_select_player)
  }, options = list(paging = FALSE, searching = FALSE, info = FALSE, ordering = FALSE))  

  output$table_school_rank = renderDataTable({
    get_season_rank_table()
  }, options = list(paging = FALSE, searching = FALSE, info = FALSE, ordering = FALSE))
  
  output$highlight_table_line_css = renderUI(
      tags$style(paste("table.display tbody tr:nth-child(", match(input$input_select_player, ordered_player_names), ") td{ background-color: #B2F7D9 !important;}")))
  
  })

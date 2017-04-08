
library(shiny)
library(ggvis)

source("./config.R")
source("./UI_helper.R")

shinyUI(fixedPage(
  title = paste(school_name, "Season", season_num),

  fixedRow(
    column(8, 
           br(), 
           h2(paste(school_name, "Season", season_num))
    ),
    column(4,
           br(),
           selectInput("input_select_player",
                       label = "Select player",
                       choices = player_names,
                       selected = selected_player_default
           )
    )
  ),
  htmlOutput("oops_message"),
  br(),
  
  tabsetPanel(
    tabPanel("Player",
             br(),
             h2("Player Details", align="center"),
             helpText("hover over the lines to see the player names", align = "center"),
             br(),
             fixedRow(
             column(12, align="center",
                    ggvisOutput("plot_player_rating")
                    )
             ),
             br(),br(),
             fixedRow(
               column(2, br()),
               column(2,
                      br(),
                      h4("Winning Rates"),
                      helpText("Shows the wins per color for each season played.")
               ),
               column(6,
                      dataTableOutput("table_season_player_stats")
               ),
               column(2, br())
             ),
             br(),br(),
             fixedRow(
               column(2, br()),
               column(2,
                      br(),
                      h4("Opponents"),
                      helpText("Shows wins per color against opponents (from all seasons).")
               ),
               column(6,
                      dataTableOutput("table_overall_pairings")
               ),
               column(2,br())
             ),
              br(),br(),br()
    ),
    
  
    tabPanel("School",
             br(),
             h2("All Players", align="center"),
             helpText("hover over the lines to see the player names", align = "center"),
             fixedRow(
               column(12, align="center",
                      ggvisOutput("plot_school_rating")  
               )
             ),
             br(),br(),
             fixedRow(
               column(2, br()),
               column(2,
                      br(),
                      h4("Season Ranking"),
                      helpText("Shows the rank at the end of the season compared to the end of the previous season.")
               ),
               column(4,
                      htmlOutput("highlight_table_line_css"),
                      dataTableOutput("table_school_rank")
               ),
               column(4,br())
             ),
             br(),br(),br()
    )
  )

))

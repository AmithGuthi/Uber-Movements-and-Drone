# Load Library: shiny - Web Application Framework for R
library(shiny)

# Define Shine Web App UI - Fluid Page
shinyUI(fluidPage(

  # Application Title
  titlePanel("Find The Optimum Travel Time"),

  # Sidebar for User Preferences
  sidebarLayout(
    sidebarPanel(
      selectInput("originId", "Select Origin Location:",
                  movementIds,
                  selected = 744),
      selectInput("destinationId", "Select Destination Location:",
                  movementIds,
                  selected = 2339)
    ),

    # Main Panel with Plots and Data Summary
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Plots for Average Travel Times",
                           fluidRow(
                             column(6, plotOutput("plotColWeeklyAvg", height=200)),
                             column(6, plotOutput("plotColHourlyAvg", height=200))
                           ),
                           fluidRow(
                             column(12, plotOutput("plotHeatmap", height=350))
                           )),
                  tabPanel("Weekly Avg. Travel Times", tableOutput("tableWeeklyAvg")),
                  tabPanel("Hourly Avg. Travel Times", tableOutput("tableHourlyAvg")))
      )
  )
))

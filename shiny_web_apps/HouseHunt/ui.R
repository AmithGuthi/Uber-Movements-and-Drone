# Load Library: shiny - Web Application Framework for R
library(shiny)

# Define Shine Web App UI - Fluid Page
shinyUI(fluidPage(

  # Application Title
  titlePanel("Find Housing Locations To Minimize Travel Time To/From Office"),

  # Sidebar for User Preferences
  sidebarLayout(
    sidebarPanel(
      selectInput("destinationId", "Select Work Location:",
                  movementIds,
                  selected = 744),
      sliderInput("hourOfDayForTravelToDestination",
                  "When do you leave for work (hour of day)?",
                  min = 0,
                  max = 23,
                  value = 8),
      sliderInput("maxTravelTimeToDestination",
                  "Select maximum travel time to-work (in mins):",
                  min = 1,
                  max = 180,
                  value = 30),
      sliderInput("hourOfDayForTravelFromDestination",
                  "When do you leave from work (hour of day)?",
                  min = 1,
                  max = 23,
                  value = 18),
      sliderInput("maxTravelTimeFromDestination",
                  "Select maximum travel time back-from-work (in mins):",
                  min = 1,
                  max = 180,
                  value = 45)
    ),

    # Main Panel with Plots and Data Summary
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Plot of Recommended Housing Locations",
                           plotOutput("plot",
                                      height = 600)),
                  tabPanel("Summary of Travel Times", tableOutput("table")))
    )
  )
))

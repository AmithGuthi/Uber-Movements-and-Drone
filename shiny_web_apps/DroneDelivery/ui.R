# Load Library: shiny - Web Application Framework for R
library(shiny)

# Define Shine Web App UI - Fluid Page
shinyUI(fluidPage(

  # Application Title
  titlePanel("Selecting Location for a Site to Pilot a Drone-Delivery Project"),

  # Sidebar for User Preferences
  sidebarLayout(
    sidebarPanel(
      selectInput("originId", "Select drone site location:",
                  movementIds,
                  selected = 741),
      sliderInput("droneSpeed",
                  "Enter speed of drone (in mph)",
                  min = 1,
                  max = 100,
                  value = 50),
      sliderInput("droneDistance",
                  "Select distance covered by drone (in miles):",
                  min = 1,
                  max = 100,
                  value = 10),
      sliderInput("droneLoadingOffset",
                  "Enter drone loading offset (in mins):",
                  min = 0,
                  max = 30,
                  value = 2),
      sliderInput("droneUnloadingOffset",
                  "Enter drone un-loading offset (in mins):",
                  min = 0,
                  max = 30,
                  value = 3)
    ),

    # Main Panel with Plot
    mainPanel(
      span(textOutput("text_analysis_result"), style="color:#428bca;font-size:18px"),
      plotOutput("plot",
                 height = 600)
    )
  )
))

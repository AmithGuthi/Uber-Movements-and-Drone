# Load Library: shiny - Web Application Framework for R
library(shiny)

# Load Library: dplyr - A Grammar of Data Manipulatio
library(dplyr)

# Load Library: ggmap - Spatial Visualization with ggplot2
library(ggmap)

# Load Library: viridis - Default Color Maps from 'matplotlib'
library(viridis)

# Define Shiny Server
shinyServer(function(input, output) {

  # All Locations in San Fransisco
  dfUniqueMovementIds = dfUberCensusTracts %>%
    select(MovementId, DisplayName) %>%
    distinct()

  # Pre-Populate Location Selection Drop-Down
  movementIds <- setNames(dfUniqueMovementIds$MovementId, dfUniqueMovementIds$DisplayName)

  # Reactive Dataset - Average of Travel Times to/from Work
  dataset <- reactive({

    # Work Location Selected by User
    selectedDestinationId = input$destinationId

    # Preferred Start of Travel Time to Work
    hourOfDayForTravelToDestination = input$hourOfDayForTravelToDestination

    # Maximum Travel Time to Work Acceptable to User (in mins)
    maxTravelTimeToDestination = input$maxTravelTimeToDestination * 60

    # Preferred Start of Travel Time from Work
    hourOfDayForTravelFromDestination = input$hourOfDayForTravelFromDestination

    # Maximum Travel Time from Work Acceptable to User (in mins)
    maxTravelTimeFromDestination = input$maxTravelTimeFromDestination * 60

    # Get Average Travel Times to Work from All Locations in San Fransisco
    dfAvgTravelTimesToDestination =
      dfUberHourlyAggregate %>%
      filter(dstid == selectedDestinationId &
               ((hod == hourOfDayForTravelToDestination &
                   mean_travel_time <= maxTravelTimeToDestination) |
                  (hod == hourOfDayForTravelFromDestination &
                     mean_travel_time <= maxTravelTimeFromDestination))) %>%
      select(dstid, sourceid, hod, mean_travel_time, standard_deviation_travel_time) %>%
      group_by(dstid, sourceid) %>%
      summarise(mean_travel_time = mean(mean_travel_time) / 60)

    # Add Geospatial Data to Average Travel Times
    dfOriginsWithLeastTravelToDestination =
      right_join(dfUberCensusTracts,
                 dfAvgTravelTimesToDestination,
                 by = c("MovementId" = "sourceid"),
                 copy = FALSE,
                 suffix = c(".census_tracts", ".travel_times"))

  })

  # Reactive Dataset - Summary of Average Travel Times to/from Work
  datasetSummaryTable <- reactive({
    dfSummary = dataset() %>%
      group_by(DisplayName) %>%
      summarise(MeanTravelTime = mean(mean_travel_time)) %>%
      arrange(MeanTravelTime)

    names(dfSummary) <- c("Housing Option", "Mean Travel Time (in mins)")

    dfSummary
  })

  # Render Plot - Average of Travel Times to/from Work
  output$plot <- renderPlot({
    ggmap(SanFransisco_map) +
      geom_polygon(aes(x = Lat,
                       y = Long,
                       group = MovementId,
                       fill = mean_travel_time),
                   size = .2,
                   color = 'black',
                   data = dataset(),
                   alpha = 0.7) +
      scale_fill_viridis(direction = -1,
                         name="Avg. Travel Time (in minutes)") +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank(),
            legend.position = "bottom",
            legend.direction = "horizontal")
  })

  # Summary Table - Average of Travel Times to/from Work
  output$table <- renderTable({
    datasetSummaryTable()
  })
})

# Load Library: shiny - Web Application Framework for R
library(shiny)

# Load Library: dplyr - A Grammar of Data Manipulatio
library(dplyr)

# Load Library: ggmap - Spatial Visualization with ggplot2
library(ggmap)

# Load Library: viridis - Default Color Maps from 'matplotlib'
library(viridis)

# Load Library: geosphere - Spherical Trigonometry
library(geosphere)

# Define Shiny Server
shinyServer(function(input, output) {

  # All Locations in San Fransisco
  dfUniqueMovementIds = dfUberCensusTracts %>%
    select(MovementId, DisplayName) %>%
    distinct()

  # Pre-Populate Location Selection Drop-Down
  movementIds <- setNames(dfUniqueMovementIds$MovementId, dfUniqueMovementIds$DisplayName)

  # Reactive Dataset - Weekly and Hourly Average of Travel Times
  dataset <- reactive({

    # Origin ID of Drone Selected by User
    selectedOriginId = input$originId

    # Drone Speed Entered by User
    droneSpeed = input$droneSpeed

    # Drone Coverage Entered by User
    droneDistance = input$droneDistance

    # Drone Loading Offset (relative to on-road delivery) as Provided by User
    droneLoadingOffset = input$droneLoadingOffset

    # Drone Unloading Offset (relative to on-road delivery) as Provided by User
    droneUnloadingOffset = input$droneUnloadingOffset

    # Compute Center Coordinates of Each Location
    dfUberCensusTracts_WithCenterPoints = dfUberCensusTracts %>%
      group_by(MovementId, DisplayName) %>%
      summarise(centerLat = (min(Lat) + max(Lat)) / 2,
                 centerLng = (min(Long) + max(Long)) / 2)

    # Get Average On-Road Travel Time for Each Destination of Drone
    dfUberAvgTravel = dfUberHourlyAggregate %>%
      filter(sourceid == selectedOriginId) %>%
      group_by(sourceid, dstid) %>%
      summarize(mean_travel_time = mean(mean_travel_time) / 60)

    # Get Center Coordinates for Origin
    dfUberAvgTravel_WithCenterPoints = left_join(
      dfUberAvgTravel,
      dfUberCensusTracts_WithCenterPoints,
      by = c("sourceid" = "MovementId"),
      copy = FALSE,
      suffix = c(".hourly", ".center_point"))

    colnames(dfUberAvgTravel_WithCenterPoints)[5] <- "Source_CenterLat"
    colnames(dfUberAvgTravel_WithCenterPoints)[6] <- "Source_CenterLong"

    # Get Center Coordinates for Destination
    dfUberAvgTravel_WithCenterPoints = left_join(
      dfUberAvgTravel_WithCenterPoints,
      dfUberCensusTracts_WithCenterPoints,
      by = c("dstid" = "MovementId"),
      copy = FALSE,
      suffix = c(".hourly", ".center_point"))

    colnames(dfUberAvgTravel_WithCenterPoints)[8] <- "Destination_CenterLat"
    colnames(dfUberAvgTravel_WithCenterPoints)[9] <- "Destination_CenterLong"

    # Data Cleanup
    dfUberAvgTravel_WithCenterPoints = dfUberAvgTravel_WithCenterPoints %>%
      filter(!is.na(Source_CenterLong), !is.na(Source_CenterLat),
             !is.na(Destination_CenterLong), !is.na(Destination_CenterLat))

    # Calculate Straight-Line Distance in Miles from Origin to Destination
    dfUberAvgTravel_WithDistance = dfUberAvgTravel_WithCenterPoints %>%
      rowwise() %>%
      mutate(Distance = distm(
        c(Source_CenterLat, Source_CenterLong),
        c(Destination_CenterLat, Destination_CenterLong),
        fun = distGeo) / 1609)

    # Calculate Drone's Travel Time and Savings Relative to On-Road Travel
    dfUberAvgTravel_WithDroneCalc = dfUberAvgTravel_WithDistance %>%
      filter(Distance <= droneDistance) %>%
      mutate(drone_travel_time = ((Distance / droneSpeed) * 60) +
               droneLoadingOffset + droneUnloadingOffset) %>%
      mutate(avgTimeSavedByDrone = mean_travel_time - drone_travel_time)
  })

  # Reactive Dataset - Savings by Drone Delivery
  datasetDroneSavingCensusTracts <- reactive({
    right_join(dfUberCensusTracts,
              dataset(),
              by = c("MovementId" = "dstid"),
              copy = FALSE,
              suffix = c(".census_tracts", ".travel_times"))
  })

  # Render Plot - Savings by Drone Delivery
  output$plot <- renderPlot({
    ggmap(SanFransisco_map) +
      geom_polygon(aes(x = Lat,
                       y = Long,
                       group = MovementId,
                       fill = avgTimeSavedByDrone),
                   size = .2,
                   color = 'black',
                   data = datasetDroneSavingCensusTracts(),
                   alpha = 0.85) +
      scale_fill_gradient2(low = "red", high = "#229CC3",
                        name="Avg. Travel Saved (in minutes)") +
      theme(axis.title.x=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.y=element_blank(),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank(),
            legend.position = "bottom",
            legend.direction = "horizontal")
  })

  # Render Text - Total Average Time Saved by Drones per Delivery
  output$text_analysis_result <- renderText({
    avgTimeSavedByDrone = round(mean(dataset()$avgTimeSavedByDrone),
                                digits = 2)

    paste0("A drone-delivery station located at the selected site will save ",
           avgTimeSavedByDrone,
           " minutes per delivery")
  })
})

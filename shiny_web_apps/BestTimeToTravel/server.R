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

  # Reactive Dataset - Weekly and Hourly Average of Travel Times
  dataset <- reactive({

    # Origin ID Selected by User
    selectedOriginId = input$originId

    # Destination ID Selected by User
    selectedDestinationId = input$destinationId

    # Get Weeky and Hourly Data Aggregate
    dfUberDayOfWeekAndHourlyAggregare =
      inner_join(dfUberWeeklyAggregate %>%
                   filter(sourceid == selectedOriginId,
                          dstid == selectedDestinationId),
                 dfUberHourlyAggregate %>%
                   filter(sourceid == selectedOriginId,
                          dstid == selectedDestinationId),
                 by = c("sourceid", "dstid"),
                 copy = FALSE, suffix = c(".weekly", ".hourly")) %>%
      mutate(mean_travel_time =
               ((mean_travel_time.weekly +
                  mean_travel_time.hourly) / 2) / 60,
             standard_deviation_travel_time =
               ((standard_deviation_travel_time.weekly +
                  standard_deviation_travel_time.hourly) / 2) / 60) %>%
      select(sourceid, dstid, dow, hod, mean_travel_time, standard_deviation_travel_time)

    dfUberDayOfWeekAndHourlyAggregare$dow = wday(dfUberDayOfWeekAndHourlyAggregare$dow, label = TRUE)

    dfUberDayOfWeekAndHourlyAggregare
  })

  # Reactive Dataset - Weekly Average of Travel Times
  datasetWeeklyAvg <- reactive({
    dsWeeklyAvg = dataset() %>%
      group_by(dow) %>%
      summarize(mean_travel_time = mean(mean_travel_time))

    min_travel_time = min(dsWeeklyAvg$mean_travel_time)
    print(min_travel_time)

    dsWeeklyAvg = dsWeeklyAvg %>%
      mutate(lowest_time = ifelse(mean_travel_time == min_travel_time, "Y", "N"))
  })

  # Reactive Dataset - Hourly Average of Travel Times
  datasetHourlyAvg <- reactive({
    dsHourlyAvg = dataset() %>%
      group_by(hod) %>%
      summarize(mean_travel_time = mean(mean_travel_time))

    min_travel_time = min(dsHourlyAvg$mean_travel_time)
    print(min_travel_time)

    dsHourlyAvg = dsHourlyAvg %>%
      mutate(lowest_time = ifelse(mean_travel_time == min_travel_time, "Y", "N"))
  })

  # Render Plot - Weekly Average Travel Time
  output$plotColWeeklyAvg <- renderPlot({
    ggplot(datasetWeeklyAvg(),
           aes(x = factor(dow),
               y = mean_travel_time,
               fill = lowest_time)) +
      geom_col() +
      scale_fill_manual(values = c("#229CC3",
                                   "darkblue")) +
      ylab("Average Travel Time (in mins)") +
      xlab("Day of Week") +
      ggtitle("Weekly Average Travel Time") +
      theme_bw() +
      theme(legend.position = "none")
  })

  # Render Plot - Hourly Average Travel Time
  output$plotColHourlyAvg <- renderPlot({
    ggplot(datasetHourlyAvg(),
           aes(x = factor(hod),
               y = mean_travel_time,
               fill = lowest_time)) +
      geom_col() +
      scale_fill_manual(values = c("#229CC3",
                                   "darkblue")) +
      ylab("Average Travel Time (in mins)") +
      xlab("Hour of Day") +
      ggtitle("Hourly Average Travel Time") +
      theme_bw() +
      theme(legend.position = "none")
  })

  # Render Heatmap - Average Travel Time by DayOfWeek and HourOfDay
  output$plotHeatmap <- renderPlot({
    ggplot(dataset(),
           aes(x = dow,
               y = factor(hod),
               fill = mean_travel_time)) +
      geom_tile() +
      scale_fill_viridis(direction = -1,
                         option = "magma",
                         name = "Avg. Travel Time (in minutes)") +
      ylab("Hour of the Day") +
      xlab("") +
      ggtitle("Average Travel Time by DayOfWeek and HourOfDay") +
      theme_bw() +
      theme(legend.position = "bottom",
            legend.direction = "horizontal")
  })

  # Summary Table - Weekly Average
  output$tableWeeklyAvg <- renderTable({
    dsForTable = datasetWeeklyAvg()
    names(dsForTable) <- c("Day of Week", "Mean Travel Time (in mins)", "Is Lowest Time")
    dsForTable
  })

  # Summary Table - Hourly Average
  output$tableHourlyAvg <- renderTable({
    dsForTable = datasetHourlyAvg()
    names(dsForTable) <- c("Hour of Day", "Mean Travel Time (in mins)", "Is Lowest Time")
    dsForTable
  })
})

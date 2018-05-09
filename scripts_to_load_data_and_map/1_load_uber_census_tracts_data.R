# Load library: rjson - JSON in R
library(rjson)

# Load Uber's Census Tracts Geospatial Data from JSON File
uberCensusTractsJSON = fromJSON(file = '../data/uber/movements/san_francisco_censustracts.json')

# Initialize Empty Data Frame
dfUberCensusTracts <- data.frame(MovementId = integer(),
                                 DisplayName = character(),
                                 Lat = double(),
                                 Long = double(),
                                 stringsAsFactors = TRUE)

# Variable to Track Data Extraction Progress
totalNumberOfMovementIds = length(uberCensusTractsJSON$features)
numOfMovementIdsProcessed = 0

# Process Each Locations Data
sapply(uberCensusTractsJSON$features, function(feature) {
  movementId = as.integer(feature[['properties']][['MOVEMENT_ID']])
  displayName = feature[['properties']][['DISPLAY_NAME']]

  # Sub Data-Frame for Performance Optimization
  dfUberCensusTracts_SubSection <- data.frame(MovementId = integer(),
                                              DisplayName = character(),
                                              Lat = double(),
                                              Long = double(),
                                              stringsAsFactors = FALSE)

  # Extract Geospatial Data
  sapply(feature[['geometry']][['coordinates']][[1]][[1]],
         function(coordinate) {
           lat = coordinate[1]
           long = coordinate[2]
           dfUberCensusTracts_SubSection[nrow(dfUberCensusTracts_SubSection) + 1, ] <<-
             list(movementId, displayName, lat, long)
         })

  # Append Sub Data-Frame to Main Data-Frame
  dfUberCensusTracts <<- rbind(dfUberCensusTracts, dfUberCensusTracts_SubSection)

  # Update Progress
  numOfMovementIdsProcessed <<- numOfMovementIdsProcessed + 1
  percentComplete = round((numOfMovementIdsProcessed / totalNumberOfMovementIds) * 100,
                          digits = 2)
  print(paste0("Percent Completed: ", percentComplete, "%"))
})

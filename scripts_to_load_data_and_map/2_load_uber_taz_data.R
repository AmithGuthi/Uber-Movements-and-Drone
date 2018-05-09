# Load library: rjson - JSON in R
library(rjson)

# Load Uber's TAZ (Traffic Analysis Zone) Geospatial Data from JSON File
uberTazJSON = fromJSON(file = '../data/uber/movements/san_francisco_taz.json')

# Initialize Empty Data Frame
dfUberTaz <- data.frame(MovementId = character(),
                        DisplayName = character(),
                        State = character(),
                        County = character(),
                        Name = character(),
                        Taz = character(),
                        Lat = double(),
                        Long = double(),
                        stringsAsFactors = TRUE)

# Variable to Track Data Extraction Progress
totalNumberOfMovementIds = length(uberTazJSON$features)
numOfMovementIdsProcessed = 0

# Process Each Locations Data
sapply(uberTazJSON$features, function(feature) {
  movementId = feature[['properties']][['MOVEMENT_ID']]
  displayName = feature[['properties']][['DISPLAY_NAME']]
  state = feature[['properties']][['STATE']]
  county = feature[['properties']][['COUNTY']]
  name = feature[['properties']][['NAME']]
  taz = feature[['properties']][['TAZ']]

  # Sub Data-Frame for Performance Optimization
  dfUberTaz_SubSection <- data.frame(MovementId = character(),
                                     DisplayName = character(),
                                     State = character(),
                                     County = character(),
                                     Name = character(),
                                     Taz = character(),
                                     Lat = double(),
                                     Long = double(),
                                     stringsAsFactors = FALSE)

  # Extract Geospatial Data
  sapply(feature[['geometry']][['coordinates']][[1]],
         function(coordinate) {
           lat = coordinate[1]
           long = coordinate[2]
           dfUberTaz_SubSection[nrow(dfUberTaz_SubSection) + 1, ] <<-
             list(movementId, displayName, state, county, name, taz, lat, long)
         })

  # Append Sub Data-Frame to Main Data-Frame
  dfUberTaz <<- rbind(dfUberTaz, dfUberTaz_SubSection)

  # Update Progress
  numOfMovementIdsProcessed <<- numOfMovementIdsProcessed + 1
  percentComplete = round((numOfMovementIdsProcessed / totalNumberOfMovementIds) * 100,
                          digits = 2)
  print(paste0("Percent Completed: ", percentComplete, "%"))
})

# Load library: readr - Read Rectangular Text Data
library(readr)

# Load library: dplyr - A Grammar of Data Manipulation
library(dplyr)

# Load library: lubridate - Make Dealing with Dates a Little Easier
library(lubridate)

# Load Uber Movement's Traffic Hourly Aggregare Data
dfUberHourlyAggregate = read.csv('../data/uber/movements/san_francisco-censustracts-2018-1-All-HourlyAggregate.csv')

str(dfUberHourlyAggregate)

# Load Uber Movement's Weekly Hourly Aggregare Data
dfUberWeeklyAggregate = read.csv('../data/uber/movements/san_francisco-censustracts-2018-1-WeeklyAggregate.csv')

str(dfUberWeeklyAggregate)

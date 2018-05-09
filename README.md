# DSO 545: Uber Movement + Drone Delivery Analysis

Analyze Uber Movement's data to help users determine housing based on their work commute preferences, and enable companies like Amazon to determine ideal sites for piloting drone-delivery systems

## Instructions to Run the Projet

#### Download The Following Data-Sets from Uber Movement's Website, and Place in Folder Structure Mentioned Below:
- data/uber/movements/san_francisco_censustracts.json
- data/uber/movements/san_francisco_taz.json
- data/uber/movements/san_francisco-censustracts-2018-1-All-HourlyAggregate.csv
- data/uber/movements/san_francisco-censustracts-2018-1-WeeklyAggregate.csv

#### Execute Scripts to Load Data for Shiny App - Dashboards
- Execute 1_load_uber_census_tracts_data.R
- Execute 2_load_uber_taz_data.R
- Execute 3_load_uber_traffic_data.R
- Execute 4_load_san_fransisco_map.R

## Implemented Dashboards

#### **Dashboard 01:** Find Housing Locations to Minimize Travel Time From/To Office

To enable users looking for housing near their workplace, to make an informed decision based on travel times to and from work. Users can describe their preferences by varying the following parameters, and our algorithms provide average-travel time information keeping the user's preferences in mind.
 
- **Select work location:** User can select his/her work location from a pre-populated list of locations in San Francisco
- **When do you leave for work (hour of day):** Impact of traffic on travel-times is considered based on user-preference while going to work
- **Select maximum travel time to-work (in mins):** User’s limit of time he/she is acceptable with while going to work
- **When do you leave from work (hour of day):** Impact of traffic on travel-times is considered based on user-preference while coming back from work
- **Select maximum travel time back-from-work (in mins):** User might have a different preference around time spent travelling while coming back from work
 
#### **Dashboard 02:** Find The Optimum Travel Time

To help users identify the most-suitable time to make a journey. The time-savings can be substantial if it’s a recurring journey the user needs to make on a weekly basis, such as,
 
- **Select Origin Location:** User can select the starting point of his/her journey from a pre-populated list of locations in San Francisco
- **Select Destination Location:** Based on the finish-point, the weekly, hourly, and best-hours-in-a-day graphs are generated
 
#### **Dashboard 03:** Selecting Location for a Site to Pilot a Drone-Delivery Project

To facilitate companies like Amazon determine, which location to host a pilot for drone-delivery system like Amazon-Prime.
 
- **Select drone site location:** Select a site to act as base of operations for drone-delivery, from a pre-populated list of locations in San Francisco
Enter speed of drone (in mph): Speed to drone to, by default set at 50 mph based on Amazon Prime’s specifications
- **Select distance covered by drone (in miles):** Radius under which a drone can operate for deliveries
- **Enter drone loading offset (in mins):** Additional time required to load a drone for delivery as compared to on-road delivery vehicles.
- **Enter drone un-loading offset (in mins):** Additional time required to un-load and leave delivery at destination as compared to on-road delivery vehicles.

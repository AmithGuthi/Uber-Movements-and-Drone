# Load library: ggmap - Spatial Visualization with ggplot2
library(ggmap)

SanFransisco_map = get_googlemap(center = c(-122.114521, 37.489777), zoom = 10, size = c(640, 374), maptype="roadmap")

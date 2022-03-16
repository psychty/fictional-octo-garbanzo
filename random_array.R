library(tidyverse)
library(jsonlite)
library(spdplyr)
# library(sf)
library(geojsonio)
library(leaflet)

# Download UK boundaries from Open Geography Portal 
uk_geojson <- geojson_read("https://opendata.arcgis.com/datasets/e05662741ac2452081eaf663dfea92e3_0.geojson",  what = "sp")

# Number of clients
clients <- 27367

# Dummy dataset
array <- spsample(uk_geojson, 
                  n = clients,
                  "clustered")

leaflet(uk_geojson) %>% 
  addTiles() %>% 
  addPolygons(stroke = TRUE,
              color = 'purple',
              weight = 1,
              smoothFactor = 0.3, 
              fillOpacity = 0) %>% 
  addMarkers(data = array,
              clusterOptions = markerClusterOptions())

array_df <- data.frame(array@coords) %>% 
  mutate(Age = sample(c('18-64 years', '65+ years'), clients, replace = TRUE)) %>%
  rename(long = x,
         lat = y)
  
array_df %>% 
toJSON() %>%
  write_lines(paste0('~/GitHub/fictional-octo-garbanzo/random_points.json'))

# 

geojson_write(geojson_json(array_spdf), file = paste0('~/GitHub/fictional-octo-garbanzo/random_points.geojson'))



library(tidyverse)
library(jsonlite)
library(spdplyr)
# library(sf)
library(geojsonio)
library(leaflet)
library(maptools)

# Download UK boundaries from Open Geography Portal 
uk_geojson <- geojson_read("https://opendata.arcgis.com/datasets/e05662741ac2452081eaf663dfea92e3_0.geojson",  what = "sp")

Scot_Wales <- uk_geojson %>% 
  filter(CTRY21NM %in% c('Scotland', 'Wales'))

NI <- uk_geojson %>% 
  filter(CTRY21NM == 'Northern Ireland')

towns_cities <- geojson_read('https://opendata.arcgis.com/datasets/ca06d2ff61914ef78dff3d30a5f8f624_0.geojson', what = 'sp')

# Number of clients
clients <- 27367

# Dummy dataset - 15% clients all over UK
array_1 <- spsample(uk_geojson, 
                  n = clients * .15,
                  "random")

# 5% specifically from Scotland, Wales
array_2 <- spsample(Scot_Wales, 
                    n = clients * .05,
                    "random")

# 10% specifically from NI
array_3 <- spsample(NI, 
                    n = clients * .1,
                    "random")

# 70% only in major towns / cities England
array_4 <- spsample(towns_cities, 
                    n = clients * .7,
                    "random")

# combine - spRbind can only accept two arguments
array_12 <- spRbind(array_1, array_2)
array_34 <- spRbind(array_3, array_4)

# combine part two - spRbind can only accept two arguments
array <- spRbind(array_12, array_34)

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
  mutate(Age = sample(c('18-64 years', '65+ years'), nrow(.), replace = TRUE)) %>%
  rename(long = x,
         lat = y)
  
array_df %>% 
toJSON() %>%
  write_lines(paste0('~/GitHub/fictional-octo-garbanzo/random_points.json'))

array_spdf = SpatialPointsDataFrame(array, array_df)
 
geojson_write(geojson_json(array_spdf), file = paste0('~/GitHub/fictional-octo-garbanzo/random_points.geojson'))
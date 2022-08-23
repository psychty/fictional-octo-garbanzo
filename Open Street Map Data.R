
packages <- c('easypackages', 'tidyr', 'ggplot2', 'dplyr', 'scales', 'readxl', 'readr', 'purrr', 'spdplyr', 'geojsonio', 'jsonlite', 'sf', 'leaflet', 'htmlwidgets', 'PostcodesioR', 'osrm', 'viridis', 'osmdata')
install.packages(setdiff(packages, rownames(installed.packages())))
easypackages::libraries(packages)

# Choose an area 
# We take the string and use a function called st_read() to query the Open Geography Portal API
portsmouth_boundaries_sf <- st_read(query) %>% 
  filter(LAD21NM %in% c('Portsmouth')) # We also filter just for Portsmouth

# At the moment the object is sf format (spatial features), but we need to turn it into a spatial polygons dataframe
Ports_spdf <- as_Spatial(portsmouth_boundaries_sf, 
                           IDs = portsmouth_boundaries_sf$LAD21NM)

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = Ports_spdf)

# We need to get a bounding box to use in OSM extraction
area_bb <- bbox(Ports_spdf)

# The main function is opq( ) which build the final query. We add our filter criteria with the add_osm_feature( ) function. In this first query we will look for cinemas. 

# https://github.com/ropensci/osmdata

q1 <- area_bb %>% 
  opq() %>% 
  add_osm_feature(key = 'amenity', 
                  value = 'cinema') %>% 
  osmdata_sf() 

# At the moment the object is sf format (spatial features), but we need to turn it into a spatial points dataframe
cinema_spdf <- as_Spatial(q1$osm_points, 
                           IDs = q1$osm_points$osm_id) %>% 
  filter(!is.na(name))

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = Ports_spdf,
              fill = NA,
              weight = 1) %>%
  addCircleMarkers(data = cinema_spdf,
             fillColor = 'maroon',
             fillOpacity = 1,
             color = '#ffffff',
             opacity = 1,
             weight = 1,
             radius = 8,
             label = ~name,
             popup = paste0('<Strong>', cinema_spdf$name, '</Strong><br><br>', cinema_spdf$addr.place, '<br>', cinema_spdf$addr.postcode))

# What else is there?
# https://wiki.openstreetmap.org/wiki/Map_features

# OSM
available_features()


available_tags(key)
available_tags("amenity")

# Lets look for gambling settings ####
q2 <- area_bb %>% 
  opq() %>% 
  add_osm_feature(key = 'amenity', 
                  value = c('gambling', 'casino')) %>% 
  osmdata_sf() 

# At the moment I think I need to search separately for betting shops, as the key is 'shop', not 'amenity' and I do not know how to combine them
q3 <- area_bb %>% 
  opq() %>% 
  add_osm_feature(key = 'shop', 
                  value = c('bookmaker', 'lottery')) %>% 
  osmdata_sf() 

all_shop_tags <- available_tags('shop')
# all_shop_tags %>% View() 

# At the moment the object is sf format (spatial features), but we need to turn it into a spatial points dataframe
gambling_spdf <- as_Spatial(q2$osm_points, 
                          IDs = q2$osm_points$osm_id) %>% 
  filter(!is.na(name))

betting_spdf <- as_Spatial(q3$osm_points,
                           IDs = q3$osm_points$osm_id)

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = Ports_spdf,
              fill = NA,
              weight = 1) %>%
  addCircleMarkers(data = cinema_spdf,
                   fillColor = 'maroon',
                   fillOpacity = 1,
                   color = '#ffffff',
                   opacity = 1,
                   weight = 1,
                   radius = 8,
                   label = ~name,
                   popup = paste0('<Strong>', cinema_spdf$name, '</Strong><br><br>', cinema_spdf$addr.place, '<br>', cinema_spdf$addr.postcode)) %>% 
  addCircleMarkers(data = gambling_spdf,
                   fillColor = 'purple',
                   fillOpacity = 1,
                   color = '#ffffff',
                   opacity = 1,
                   weight = 1,
                   radius = 8,
                   label = ~name,
                   popup = paste0('<Strong>', gambling_spdf$name, '</Strong><br><br>', gambling_spdf$addr.place, '<br>', gambling_spdf$addr.street, '<br>', gambling_spdf$addr.postcode)) %>% 
  addCircleMarkers(data = betting_spdf,
                   fillColor = 'orange',
                   fillOpacity = 1,
                   color = '#ffffff',
                   opacity = 1,
                   weight = 1,
                   radius = 8,
                   label = ~name,
                   popup = paste0('<Strong>', betting_spdf$name, '</Strong><br><br>', betting_spdf$addr.place, '<br>', betting_spdf$addr.street, '<br>', betting_spdf$addr.postcode)) 

# Alternative querying - all OSM points of interest within a radius of a location ####

# This isn't very successful below, I need to spend some time understanding the outputs.

# osmdata::opq_around()
# 
# location_x <- postcode_lookup('')
# 
# poi_around_location <- opq_around(lon = location_x$longitude,
#            lat = location_x$latitude,
#            radius = 100,# This is metres radius (so 1,000 is a kilometre)
#            timeout = 60) %>%  
#   osmdata_sf()
# 
# 
# poi_polygons <- as_Spatial(poi_around_location$osm_polygons)
# 
# poi_polylines <- as_Spatial(poi_around_location$osm_lines)
# 
# leaflet() %>% 
#   addTiles() %>%
#   addPolygons(data = poi_polygons,
#               color = "#03F",
#               weight = 5,
#               opacity = 0.5,
#               fill = TRUE,
#               fillColor = 'green',
#               fillOpacity = 1) %>% 
#   addPolygons(data = poi_polylines,
#               color = "#03F",
#               weight = 5,
#               opacity = 0.5,
#               fill = TRUE,
#               fillColor = 'green',
#               fillOpacity = 1)


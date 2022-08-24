
packages <- c('easypackages', 'tidyr', 'ggplot2', 'dplyr', 'scales', 'readxl', 'readr', 'purrr', 'spdplyr', 'geojsonio', 'jsonlite', 'sf', 'leaflet', 'htmlwidgets', 'PostcodesioR', 'osrm', 'viridis', 'osmdata')
install.packages(setdiff(packages, rownames(installed.packages())))
easypackages::libraries(packages)

# Choose an area 

# We take the string and use a function called st_read() to query the Open Geography Portal API
wsx_clipped_boundaries_sf <- st_read('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_December_2021_GB_BGC/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson') %>% 
  filter(LAD21NM %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing')) # We also filter just for West Sussex LTLAs

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = wsx_clipped_boundaries_sf,
              fill = NA,
              weight = 3,
              opacity = 1)

# As you can see, this is clipped to the coast line and you can see at least two rivers cutting into the county around Arundel, and Shoreham by Sea.

# Instead, you can use full extent (of the realm) boundaries which exclude the coastline. These take a bit longer to download from Open Geography Portal as they are often a finer resolution
wsx_full_extent_boundaries_sf <- st_read('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_December_2021_GB_BFE/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json') %>% 
  filter(LAD21NM %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing')) # We also filter just for West Sussex LTLAs

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = wsx_full_extent_boundaries_sf,
              fill = NA,
              weight = 3,
              opacity = 1)

# This is better, but it does lose the clipping around Thorney Island and Chichester Harbour


# We could try using a combination of both the full extent and clipped boundaries
wsx_a <- wsx_clipped_boundaries_sf %>% 
  filter(LAD21NM == 'Chichester')
wsx_b <- wsx_full_extent_boundaries_sf %>% 
  filter(LAD21NM != 'Chichester')

wsx_boundaries_sf <- wsx_a %>% 
  rbind(wsx_b)

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = wsx_boundaries_sf,
              fill = NA,
              weight = 3,
              opacity = 1)

# Perfect, this will help for presentation purposes.

# We need to get a bounding box to use in OSM extraction. If you use base bbox() function it needs to be on a spatial polygons dataframe version

# At the moment the object is sf format (spatial features), but we need to turn it into a spatial polygons dataframe to plot more easily with Leaflet
wsx_spdf <- as_Spatial(wsx_boundaries_sf, 
                       IDs = wsx_boundaries_sf$LAD21NM)

area_bb <- bbox(wsx_spdf)

# The main function is opq( ) which build the final query. We add our filter criteria with the add_osm_feature( ) function. In this first query we will look for cinemas. 

# https://github.com/ropensci/osmdata

q1 <- area_bb %>% 
  opq() %>% 
  add_osm_feature(key = 'amenity', 
                  value = 'cinema') %>% 
  osmdata_sf() # converts the results into an sf object

# At the moment the object is sf format (spatial features), but we need to turn it into a spatial points dataframe
# We also only want to keep the points that fall within the polygons (the bounding box is a square/rectangle shape and may include some points outside of the ares)
cinema_spdf <- st_intersection(wsx_boundaries_sf, q1$osm_points) %>% 
  as_Spatial() 

# This is a bit messy as some data entries have 'name' filled in, and others do not, and for some cinemas, individual screens are including rather than the whole cinema. You may have to make some decisions on how to clean up the data.

cinema_spdf@data %>% View()

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = wsx_spdf,
              fill = NA,
              weight = 2,
              color = '#000000') %>%
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

gambling_spdf <- st_intersection(wsx_boundaries_sf, q2$osm_points) %>% 
  as_Spatial() 

betting_spdf <- st_intersection(wsx_boundaries_sf, q3$osm_points) %>% 
  as_Spatial() 

leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = wsx_spdf,
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


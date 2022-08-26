
# Defining coastal neighbourhoods

# There is no nationally agreed definition or consensus on what constitutes a ‘coastal community’. Academics, institutions, and policy makers haveadopted a variety of definitions. These range from the narrower specification of seaside resorts, to broader classifications which include every local authority with a coastline or estuary. 

# Beatty and Fothergill (2008), for example, in their benchmarking study, identified 37 principle Seaside towns in England, drawn up in consultation with the British Resorts Association 1. The study included towns with a population over 10,000 which share a number of features that distinguish them from other places along the coast or inland. This includes a “specialist tourist infrastructure (promenades, piers, parks etc), holiday accommodation (hotels, boarding houses, caravan sites) and a distinctive resort character that is often reflected in the built environment”. 

# Other examples include MHCLG who have commonly used the following definition “A coastal community is any coastal settlement within an English local authority area whose boundaries include English foreshore, including local authorities whose boundaries only include estuarine foreshore. 

# Coastal settlements include seaside towns, ports and other areas which have a clear connection to the coastal economy”. 

# Each definition has its limitations and there is commonly an element of subjectivity in the categorisation. Certain ‘sub-categories’, for example, port towns or seaside towns may sometimes be an appropriate narrower definition, depending on the purpose for categorisation e.g research, policy. 

# Definition at local authority level, however, is primarily avoided given that this does not provide granular enough information, especially in large local authorities with small coastlines where outcomes are likely to be masked.

# ONS approach - coastal towns ####

# 1,186 towns in England and Wales plus Built up areas and built up area sub divisions with populations about 225,000 in the 2011 census

# calculate the distance between the centroid and the boundary - mean low water mark boundaries are used to exclude towns next to estuaries and rivers

# There is a classification and boundary set for these areas either on the ons site or in the appendices of the 2021 CMO report 


# University of Plymouth outline a method for smaller geographies - For the purposes of this analysis, “coastal” LSOAs have therefore been defined as those which include or overlap built-up areas (which is residential) and which lies within 500m of the “Mean High Water Mark” (excluding tidal rivers). 

# MSOAs, meanwhile, have been defined as coastal if more than 50% of their 2019 mid-year population18 live in coastal LSOAs. 
# The extent of the coastal fringe differs slightly depending on whether it is defined using LSOAs or MSOAs but, overall, both approaches place about 18.5% of the English population in coastal areas (Table 2). This contrasts markedly with the 25.4% of people who live within local authorities which include coastal foreshore. 

# Adopting a more granular perspective means, for instance, that it is not necessary to treat everybody living in Northumberland as a “coastal resident”. 

# This local authority (and its geographically identical CCG) has a long coast (90km as the crow flies), but some parts lie fully 75km from the sea. Overall, less than 40% of people live in coastal LSOAs and, although in Northumberland the coastal population is slightly younger, it is, as elsewhere in the country, markedly more deprived than more inland areas (Figure 2). 

#

packages <- c('easypackages', 'tidyr', 'ggplot2', 'dplyr', 'scales', 'readxl', 'readr', 'purrr', 'stringr', 'PHEindicatormethods', 'rgdal', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'rgeos', 'sp', 'sf', 'maptools', 'leaflet', 'leaflet.extras')
install.packages(setdiff(packages, rownames(installed.packages())))
easypackages::libraries(packages)

output_directory <- './fictional-octo-garbanzo/Outputs'

lsoa_lookup <- read_csv('https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/845345/File_7_-_All_IoD2019_Scores__Ranks__Deciles_and_Population_Denominators_3.csv') %>% 
  select(LSOA11CD = `LSOA code (2011)`,  LTLA = `Local Authority District name (2019)`, IMD_Score = `Index of Multiple Deprivation (IMD) Score`, IMD_Decile = "Index of Multiple Deprivation (IMD) Decile (where 1 is most deprived 10% of LSOAs)") %>% 
  filter(LTLA %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing'))

if(file.exists(paste0(output_directory, "/lsoa_full_clipped_2011.geojson")) != TRUE){
  # You can just about get 101 records to paste together, so we only need five groups.
search_string <- gsub(' ', '', toString(sprintf("%%27%s%%20%%27", lsoa_lookup$LSOA11CD[1:101])))
query_x1<- paste0('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Lower_Layer_Super_Output_Areas_December_2011_Boundaries_EW_BFC_V2/FeatureServer/0/query?where=LSOA11CD%20IN%20(', search_string ,')&outFields=*&outSR=4326&f=geojson')
lsoa_1 <- st_read(query_x1)

search_string <- gsub(' ', '', toString(sprintf("%%27%s%%20%%27", lsoa_lookup$LSOA11CD[102:202])))
query_x2<- paste0('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Lower_Layer_Super_Output_Areas_December_2011_Boundaries_EW_BFC_V2/FeatureServer/0/query?where=LSOA11CD%20IN%20(', search_string ,')&outFields=*&outSR=4326&f=geojson')
lsoa_2 <- st_read(query_x2)

search_string <- gsub(' ', '', toString(sprintf("%%27%s%%20%%27", lsoa_lookup$LSOA11CD[203:303])))
query_x3<- paste0('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Lower_Layer_Super_Output_Areas_December_2011_Boundaries_EW_BFC_V2/FeatureServer/0/query?where=LSOA11CD%20IN%20(', search_string ,')&outFields=*&outSR=4326&f=geojson')
lsoa_3 <- st_read(query_x3)

search_string <- gsub(' ', '', toString(sprintf("%%27%s%%20%%27", lsoa_lookup$LSOA11CD[304:404])))
query_x4<- paste0('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Lower_Layer_Super_Output_Areas_December_2011_Boundaries_EW_BFC_V2/FeatureServer/0/query?where=LSOA11CD%20IN%20(', search_string ,')&outFields=*&outSR=4326&f=geojson')
lsoa_4 <- st_read(query_x4)

search_string <- gsub(' ', '', toString(sprintf("%%27%s%%20%%27", lsoa_lookup$LSOA11CD[405:505])))
query_x5<- paste0('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Lower_Layer_Super_Output_Areas_December_2011_Boundaries_EW_BFC_V2/FeatureServer/0/query?where=LSOA11CD%20IN%20(', search_string ,')&outFields=*&outSR=4326&f=geojson')
lsoa_5 <- st_read(query_x5)

lsoa <- rbind(lsoa_1, lsoa_2, lsoa_3, lsoa_4, lsoa_5)
# Write the sf (simple features) object to geojson, then read the geojson file using geojson_read() to returm a spatial polygons dataframe. This is the easiest type to work with that I am familiar with. Then use as required.
st_write(lsoa, paste0(output_directory, "/lsoa_full_clipped_2011.geojson"), delete_dsn = TRUE)
}

lsoa_df <- geojson_read(paste0(output_directory, "/lsoa_full_clipped_2011.geojson"), what = 'sp')

population_weighted_centroids <- st_read('https://ons-inspire.esriuk.com/arcgis/rest/services/Census_Boundaries/Lower_Super_Output_Areas_December_2011_Centroids/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson') %>% 
  filter(lsoa11cd %in% lsoa_lookup$LSOA11CD)

bua_population_2011 <- nomisr::nomis_get_data(id = 'NM_144_1',
                       time = 'latest',
                       geography = '1128267777...1128270836,1128270838...1128272832,1128272840,1128272842,1128272841,1128272833...1128272839,1128272843...1128273270,1119879169...1119882228,1119882230...1119885230,1119885232...1119885236,1119885238...1119885256,1119885263...1119885265,1119885267,1119885257...1119885262,1119885266,1119885268...1119885792',
                       c_age = 0)

?nomis_get_data()

BUA <- st_read('https://ons-inspire.esriuk.com/arcgis/rest/services/Census_Boundaries/Built_Up_Areas_December_2011_Boundaries_V2/MapServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson')

BUASD <- st_read('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Builtup_Area_Sub_Divisions_December_2011_Boundaries_BGG/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson')

# Note boundaries have been filtered to include BUASD and BUA that have a resident population only. The lookup table used is derived from the OA lookup to BUA - census tables only include areas with resident populations. Open geography boundaries contain areas that are built up but do not have a resident population (such as airports) which have then been filtered:
  
lsoa_to_bua_lookup <- st_read('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/LSOA11_BUASD11_BUA11_LAD11_RGN11_EW_LU/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=geojson') %>% 
  filter(LSOA11CD %in% lsoa_lookup$LSOA11CD)

england_boundary_bfc <- read_sf('https://opendata.arcgis.com/datasets/ad26732b081049d797620753db953185_0.geojson') %>% 
  filter(CTRY20NM == 'England')

england_boundary_ultra_clipped <- read_sf('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Countries_December_2021_GB_BUC/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson') %>% 
  filter(CTRY21NM == 'England')

wsx_full_extent_boundaries_sf <- st_read('https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Local_Authority_Districts_December_2021_GB_BFE/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json') %>% 
  filter(LAD21NM %in% c('Adur', 'Arun', 'Chichester', 'Crawley', 'Horsham', 'Mid Sussex', 'Worthing')) 

open_rivers <- st_read('C:/Users/ASUS/OneDrive/Documents/data/oprvrs_gb.gpkg') 

open_rivers_transform <- st_transform(open_rivers, crs = 'WGS84')

wsx_full_extent_boundaries_sf_transform <- st_transform(wsx_full_extent_boundaries_sf, crs = 'WGS84')

wsx_rivers <- st_intersection(wsx_full_extent_boundaries_sf_transform,
                              open_rivers_transform) 

leaflet %>% 
  addTiles() %>% 
  addPolygons(data = wsx_rivers)


leaflet() %>% 
  addTiles() %>% 
  addPolygons(data = england_boundary_bfc) %>% 
  addPolygons(data = england_boundary_ultra_clipped,
              color = 'red')

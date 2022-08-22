
packages <- c('easypackages', 'tidyverse','readxl', 'readr', 'glue', 'scales', 'sf', 'osrm', 'leaflet', 'leaflet.extras', 'spdplyr', 'geojsonio', 'rmapshaper', 'jsonlite', 'httr', 'rvest', 'stringr', 'rgeos', 'nomisr', 'parlitools', 'viridis', 'scales')
install.packages(setdiff(packages, rownames(installed.packages())))
easypackages::libraries(packages)

jsa_by_constituency <- nomis_get_data(id = "NM_1_1", 
                               time = "latest", 
                               measures = 20100,
                               item = 1,
                               sex = 7,
                               geography = "TYPE460") %>% 
  select(constituency_name = GEOGRAPHY_NAME, Sex = SEX_NAME, Measure = ITEM_NAME, Unit = MEASURES_NAME, Value = OBS_VALUE) %>% 
  mutate(constituency_name = gsub('Na h-Eileanan An Iar', 'Na h-Eileanan an Iar', gsub('St ', 'St. ', constituency_name))) %>% 
  mutate(Claimant_bins = ifelse(Value < 50, '1-49', ifelse(Value < 150, '50-149', ifelse(Value < 250, '150-249', ifelse(Value < 350, '250-349', '350+')))))

jsa_hex <- parlitools::west_hex_map %>% 
  inner_join(jsa_by_constituency, by = "constituency_name") 

ggplot(jsa_hex) + 
  geom_sf(aes(geometry = geometry, 
              fill = Claimant_bins), 
          color = "black") +
  coord_sf(datum = sf::st_crs(jsa_hex$geometry)) +
  # scale_fill_viridis(option = "E") + 
  labs(title = "JSA Claimants per Constituency",
       fill = "JSA Claimants")


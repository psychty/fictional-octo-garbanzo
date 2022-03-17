// CP towers geolocation on load
$.ajax({
  url: "https://api.postcodes.io/postcodes/po77yh",
  // dataType: "json",
  async: false,
  success: function(data) {
  CP_data = data;
  console.log('CP geolocation successfully loaded.')},
  error: function (xhr) {
    alert('Geolocation data not loaded - ' + xhr.statusText);
  },
});

// Load points data array, you could replace this with the results of your own lookup and data
// ! Note - I have written code for plotting these (also commented out) below, which loops through each record. However, that is not very efficient so if you can possibly help it, use a geojson format in which all points can be plotted together. This is kept here in case we cannot parse json array to geojson
// $.ajax({
//     url: "./random_points.json",
//     dataType: "json",
//     async: false,
//     success: function(data) {
//     Client_data = data;
//     console.log('Client data successfully loaded.')},
//     error: function (xhr) {
//       alert('Client data not loaded - ' + xhr.statusText);
//     },
// });

// Load points data array as a geojson file, you could replace this with the results of your own lookup and data
$.ajax({
  url: "./random_points.geojson",
  dataType: "json",
  async: false,
  success: function(data) {
  Client_data_geo = data;
  console.log('Client geo data successfully loaded.')},
  error: function (xhr) {
    alert('Client data not loaded - ' + xhr.statusText);
  },
});

 //  Load uk_boundary geojson file
var uk_geojson = $.ajax({
  url: "https://opendata.arcgis.com/datasets/e05662741ac2452081eaf663dfea92e3_0.geojson",
  dataType: "json",
  success: console.log("UK boundary data successfully loaded."),
  error: function (xhr) {
    alert(xhr.statusText);
  },
});

// Create a function to add stylings to the polygons in the leaflet map
function uk_boundary_colour(feature) {
  return {
    fillColor: 'none',
    color: 'purple',
    weight: 1,
    fillOpacity: 0.85,
  };
}

// ! Mapping in leaflet JS

// Define the background tiles for our maps - you can find more tiles here - https://leaflet-extras.github.io/leaflet-providers/preview/
// Note that for some background (ge SpinalMap) you need an api key

// This tile layer is coloured
var tileUrl_coloured = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";

// This tile layer is black and white
var tileUrl_bw = "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png";

// Define an attribution statement to go onto our maps
var attribution =
  '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Contains Ordnance Survey data © Crown copyright and database right 2022';

// Specify that this code should run once the Client_data data request is complete
$.when(uk_geojson).done(function () {

  // Add the UK boundary polygons, with the uk_boundary_colour style to map_1 
var uk_boundary_1 = L.geoJSON(uk_geojson.responseJSON, { style: uk_boundary_colour })

// ! Map one - UK only  
// Create a leaflet map (L.map) in the element map_1_id
var map_1 = L.map("map_1_id", {zoomControl: false , scrollWheelZoom: false, doubleClickZoom: false, touchZoom: false, }); // We have disabled zooming on this map

L.control.scale().addTo(map_1); // This adds a scale bar to the bottom left by default

// add the background and attribution to the map 
// Note - we have used the tileUrl_bw, swap this for tileUrl_coloured to see what happens
L.tileLayer(tileUrl_bw, { attribution })
 .addTo(map_1);

uk_boundary_1.addTo(map_1) // Note that this is the part that draws the polygons on the map itself
 
map_1.fitBounds(uk_boundary_1.getBounds()); // We use the uk_boundary polygons to zoom the map to the whole of the UK. This will happen regardless of whether we use addTo() to draw the polygons

// ! Map two - CP Towers
// Create a leaflet map (L.map) in the element map_1_id
var map_2 = L.map("map_2_id");
L.control.scale().addTo(map_2);


// add the background and attribution to the map 
// Note - we have used the tileUrl_bw, swap this for tileUrl_coloured to see what happens
L.tileLayer(tileUrl_coloured, { attribution })
 .addTo(map_2);

var uk_boundary_2 = L.geoJSON(uk_geojson.responseJSON, { style: uk_boundary_colour })
uk_boundary_2.addTo(map_2) // Note that this is the part that draws the polygons on the map itself

// add a single marker for the Code Potato Offices 
var cp_marker = L.marker([CP_data['result']['latitude'], CP_data['result']['longitude']])
.addTo(map_2)
.bindPopup(function (layer) {
    return (
     "Code Potato Towers"
      )
    })
.openPopup();
 
// map_2.fitBounds(uk_boundary.getBounds()); // We use the uk_boundary polygons to zoom the map to the whole of the UK. This will happen regardless of whether we use addTo() to draw the polygons

// Instead of zooming to the boundaries of our uk_boundary polygons, we can centre the lat long of CP_data
map_2.setView([CP_data['result']['latitude'], CP_data['result']['longitude']], 18); // Note the value 18 is zooming to building level

// ! Map three - all the dots 
// Create a leaflet map (L.map) in the element map_1_id
var map_3 = L.map("map_3_id");
L.control.scale().addTo(map_3);

// add the background and attribution to the map 
// Note - we have used the tileUrl_bw, swap this for tileUrl_coloured to see what happens
L.tileLayer(tileUrl_bw, { attribution })
 .addTo(map_3);

// This loops through the dataframe and plots a marker for every record. 
// for (var i = 0; i < Client_data.length; i++) {
// marker = new L.circleMarker([Client_data[i]['lat'], Client_data[i]['long']],
//      {
//      radius: 1,
//      color: '#000',
//      weight: .5,
//      fillColor: 'green',
//      fillOpacity: 1})
//    .addTo(map_3) 
//   }

var uk_boundary_3 = L.geoJSON(uk_geojson.responseJSON, { style: uk_boundary_colour }).addTo(map_3)

// These are styles for the markers
var clientMarkerOptions = {
  radius: .01,
  color: '#000',
  weight: .01,
  fillColor: 'green',
  fillOpacity: 1
};

// This plots the geojson file as circlemarkers
var client_locations = L.geoJSON(Client_data_geo, {
  pointToLayer: function (feature, latlng){
    return L.circleMarker(latlng, clientMarkerOptions)
  }})
  .bindPopup(function (layer) {
    return (
      "Age group: <Strong>" +
        layer.feature.properties.Age 
      )
    }) // add tooltip
  // .addTo(map_3); // draw it on the map

var baseMaps_map_3 = {
  "Show UK boundary": uk_boundary_3,
  "Show Client geolocations": client_locations, 
  };

L.control
 .layers(null, baseMaps_map_3, { collapsed: false })
 .addTo(map_3);

 map_3.fitBounds(uk_boundary_3.getBounds()); // In this case I have not added uk_boundary to map_3, I have just used it to set the zoom. 
// You must set the zoom some way (either fitbounds, setview, setzoom etc) for the map to 

// ! Map four - all the dots but by age 

// Create a leaflet map (L.map) in the element map_4_id
var map_4 = L.map("map_4_id");
L.control.scale().addTo(map_4);

// add the background and attribution to the map 
// Note - we have used the tileUrl_bw, swap this for tileUrl_coloured to see what happens
L.tileLayer(tileUrl_bw, { attribution })
 .addTo(map_4);

var uk_boundary_4 = L.geoJSON(uk_geojson.responseJSON, { style: uk_boundary_colour }).addTo(map_4)

// This time we want to plot the dots but sbe able to turn off one of the age bands.
// To do this we create a filter function that can be used when plotting the dots.

function age_1864_Filter(feature) {
  if (feature.properties.Age === '18-64 years') return true
}

// These are styles for the markers for 18-64 year olds
var clientMarker_1864_Options = {
  radius: 5,
  color: '#000',
  weight: .01,
  fillColor: 'orange',
  fillOpacity: 1
};

function age_65_plus_Filter(feature) {
  if (feature.properties.Age === '65+ years') return true
}

// These are styles for the markers for 65+ year olds
var clientMarker_65_plus_Options = {
  radius: 5,
  color: '#000',
  weight: .01,
  fillColor: 'purple',
  fillOpacity: 1
};

// ! You could have used a single styles options and included an additional function to decide colour or radius etc. We'll do this on map 5.

// This plots the geojson file as circlemarkers
var client_1864_locations = L.geoJSON(Client_data_geo, {
  filter: age_1864_Filter, 
  pointToLayer: function (feature, latlng){
    return L.circleMarker(latlng, clientMarker_1864_Options)
  }})
  .bindPopup(function (layer) {
    return (
      "Age group: <Strong>" +
        layer.feature.properties.Age 
      )
    }) // add tooltip
  // .addTo(map_4); // draw it on the map

// This plots the geojson file as circlemarkers
var client_65_plus_locations = L.geoJSON(Client_data_geo, {
  filter: age_65_plus_Filter, 
  pointToLayer: function (feature, latlng){
    return L.circleMarker(latlng, clientMarker_65_plus_Options)
  }})
  .bindPopup(function (layer) {
    return (
      "Age group: <Strong>" +
        layer.feature.properties.Age 
      )
    }) // add tooltip
  // .addTo(map_4); // draw it on the map

  var baseMaps_map_4 = {
  "Show UK boundary": uk_boundary_4,
  "Show clients aged 18-64 years": client_1864_locations, 
  "Show clients aged 65+ years": client_65_plus_locations, 
  };

L.control
 .layers(null, baseMaps_map_4, { collapsed: false })
 .addTo(map_4);

map_4.fitBounds(uk_boundary_4.getBounds()); // In this case I have not added uk_boundary to map_4, I have just used it to set the zoom. 
// You must set the zoom some way (either fitbounds, setview, setzoom etc) for the map to 
 
// ! Map five - all the dots clustered 
// Create a leaflet map (L.map) in the element map_1_id
var map_5 = L.map("map_5_id");
L.control.scale().addTo(map_5);

// add the background and attribution to the map 
// Note - we have used the tileUrl_bw, swap this for tileUrl_coloured to see what happens
L.tileLayer(tileUrl_bw, { attribution })
 .addTo(map_5);

var uk_boundary_5 = L.geoJSON(uk_geojson.responseJSON, { style: uk_boundary_colour }).addTo(map_5)

// TODO
// I realised that the only color function i use is d3, and i dont think we want to use an extra library for the sake of it. For now these are commented out
// setAgeColour

// These are styles for the markers
var clientMarkerAgeOptions = {
  radius: 5,
  color: '#000',
  weight: .01,
  // fillColor: setAgeColour(Client_data_geo[i]['Age']),
  fillColor: 'green',
  fillOpacity: 1
};

var client_locations_clustered_group = L.markerClusterGroup();

// This plots the geojson file as circlemarkers
var client_locations_clustered = L.geoJSON(Client_data_geo, {
  pointToLayer: function (feature, latlng){
    return  client_locations_clustered_group.addLayer(L.circleMarker(latlng, clientMarkerAgeOptions))
  }})
  .addTo(map_5); // draw it on the map


var baseMaps_map_5 = {
  "Show UK boundary": uk_boundary_5,
  "Show client geolocations": client_locations_clustered, 
  };

L.control
 .layers(null, baseMaps_map_5, { collapsed: false })
 .addTo(map_5);

 map_5.fitBounds(uk_boundary_5.getBounds()); // In this case I have not added uk_boundary to map_3, I have just used it to set the zoom. 
// You must set the zoom some way (either fitbounds, setview, setzoom etc) for the map to 

});




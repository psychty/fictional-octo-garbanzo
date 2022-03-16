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
$.ajax({
    url: "./random_points.json",
    dataType: "json",
    async: false,
    success: function(data) {
    Client_data = data;
    console.log('Client data successfully loaded.')},
    error: function (xhr) {
      alert('Client data not loaded - ' + xhr.statusText);
    },
});

// Load points data array, you could replace this with the results of your own lookup and data
// $.ajax({
//   url: "./random_points.geojson",
//   dataType: "json",
//   async: false,
//   success: function(data) {
//   Client_data_geo = data;
//   console.log('Client geo data successfully loaded.')},
//   error: function (xhr) {
//     alert('Client data not loaded - ' + xhr.statusText);
//   },
// });

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
var uk_boundary = L.geoJSON(uk_geojson.responseJSON, { style: uk_boundary_colour })

// ! Map one - UK only  
// Create a leaflet map (L.map) in the element map_1_id
var map_1 = L.map("map_1_id", {zoomControl: false , scrollWheelZoom: false, doubleClickZoom: false, touchZoom: false, }); // We have disabled zooming on this map

L.control.scale().addTo(map_1); // This adds a scale bar to the bottom left by default

// add the background and attribution to the map 
// Note - we have used the tileUrl_bw, swap this for tileUrl_coloured to see what happens
L.tileLayer(tileUrl_bw, { attribution })
 .addTo(map_1);

// uk_boundary.addTo(map_1) // Note that this is the part that draws the polygons on the map itself
 
map_1.fitBounds(uk_boundary.getBounds()); // We use the uk_boundary polygons to zoom the map to the whole of the UK. This will happen regardless of whether we use addTo() to draw the polygons

// create a control
var baseMaps_map_1 = {
  "Show UK boundary": uk_boundary
};

L.control
 .layers(null, baseMaps_map_1, { collapsed: false })
 .addTo(map_1);


// ! Map two - CP Towers
// Create a leaflet map (L.map) in the element map_1_id
var map_2 = L.map("map_2_id");
L.control.scale().addTo(map_2);


// add the background and attribution to the map 
// Note - we have used the tileUrl_bw, swap this for tileUrl_coloured to see what happens
L.tileLayer(tileUrl_coloured, { attribution })
 .addTo(map_2);

// UK boundary polygons are already defined so we can just add this to map_2 
uk_boundary.addTo(map_2) // Note that this is the part that draws the polygons on the map itself

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
for (var i = 0; i < Client_data.length; i++) {
marker = new L.circleMarker([Client_data[i]['lat'], Client_data[i]['long']],
     {
     radius: 1,
     color: '#000',
     weight: .5,
     fillColor: 'green',
     fillOpacity: 1})
   .addTo(map_3) 
  }

//  L.geoJSON(Client_data_geo).addTo(map_3);

  var baseMaps_map_3 = {
    "Show UK boundary": uk_boundary,
    // "Show Client Geolocations": clients_array, 
  };

  L.control
   .layers(null, baseMaps_map_3, { collapsed: false })
   .addTo(map_3);

// However, it is a hugely resource intensive process for the browser to do this and takes many seconds to load.

map_3.fitBounds(uk_boundary.getBounds()); // In this case I have not added uk_boundary to map_3, I have just used it to set the zoom. 
// You must set the zoom some way (either fitbounds, setview, setzoom etc) for the map to 


});




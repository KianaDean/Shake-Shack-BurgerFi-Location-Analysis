###BURGERFI VS SHAKE SHACK LOCATION ANALYSIS

#Load packages
library(tidyverse)
library(leaflet)
library(leaflet.extras)
library(tidycensus)
library(ggmap)

#read in the location files
burgerfistores <- read.csv("BurgerFiStores.csv")
shakeshackstores <- read.csv("ShakeShackStores.csv")

burgerfi_addresses <- burgerfistores %>%
  unite(Address, Street:State, sep=", ")

#geocode the addresses
library(tidygeocoder)
#osm_burgerfistores <- geo(
  #address = burgerfi_addresses$Address, method = "osm",
  #lat = latitude, long = longitude
#)

#using the cascade method to pull from the census then openstreetmap
osm_burgerfistores <- geo(
  address = burgerfi_addresses$Address, method = "cascade",
  lat = latitude, long = longitude
)

view(osm_burgerfistores)

#how many NA values
sum(is.na(osm_burgerfistores))

#create leaflet map
burgerfilocations <- 
  osm_burgerfistores %>% 
  leaflet() %>% 
  # Use addTiles to plot the stores on the default Open Street Map tile
  addTiles() %>%
  # Plot the stores using addCircles
  addCircles() 

burgerfilocations

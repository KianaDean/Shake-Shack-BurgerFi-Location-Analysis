###BURGERFI VS SHAKE SHACK LOCATION ANALYSIS

#Load packages
library(tidyverse)
library(leaflet)
library(leaflet.extras)
library(tidycensus)
library(ggmap)

# set up api key for Census Data API
census_api_key("my_api_key")

# read in the location files
burgerfistores <- read.csv("BurgerFiStores.csv")
shakeshackstores <- read.csv("ShakeShackStores.csv")

# combining the columns to create a single address
burgerfistores$X <- NULL
burgerfi_addresses <- burgerfistores %>%
  unite(Address, Street:State, sep=", ")

shakeshackstores$id <- NULL
shakeshack_addresses <- shakeshackstores %>%
  unite(Address, Street:Zipcode, sep=", ")

# geocode the addresses
library(tidygeocoder)
#osm_burgerfistores <- geo(
  #address = burgerfi_addresses$Address, method = "osm",
  #lat = latitude, long = longitude
#)

# using the cascade method to pull from the census then openstreetmap
osm_burgerfistores <- geo(
  address = burgerfi_addresses$Address, method = "cascade",
  lat = latitude, long = longitude
)

view(osm_burgerfistores)

osm_shakeshackstores <- geo(
  address = shakeshack_addresses$Address, method = "cascade",
  lat = latitude, long = longitude
)

view(osm_burgerfistores)

# show how many NA values
colSums(is.na(osm_burgerfistores))

colSums(is.na(osm_shakeshackstores))

# export to csv to replace the missing coordinates to make an accurate assessment
#write.csv(osm_shakeshackstores, "osm_shakeshackstores.csv")
#write.csv(osm_burgerfistores, "osm_burgerfistores.csv")

# read back in csv files with the NA values replaced
osm_burgerfistores <- read.csv("osm_burgerfistoresc.csv")
osm_shakeshackstores <- read.csv("osm_shakeshackstores.csv")

# combine the two location files
osm_burgerfistores$X <- NULL
osm_shakeshackstores$X <- NULL
osm_shakeshackstores$X.1 <- NULL

osm_burgerfistores$company <- "BurgerFi"
osm_shakeshackstores$company <- "Shake Shack"

storelocations <- rbind(osm_burgerfistores,osm_shakeshackstores)

# pull median household income and total population data
options(tigris_use_cache = TRUE)

my_vars <- c(
  total_pop = "B01003_001",
  median_income = "B19013_001"
)

#pull income data by county, if you want to look per zipcode change "county" to "zcta"
incomepopdata <- get_acs(geography = "county", 
                  variables = my_vars, year = 2019, geometry = TRUE)

head(incomepopdata)

incomedata <- incomepopdata %>%
  filter(variable == "median_income")

head(incomedata)

popdata <- incomepopdata %>%
  filter(variable == "total_pop")

head(popdata)

# plot the data

incomedata %>%
  ggplot(aes(fill = estimate)) + 
  geom_sf(color = NA) + 
  coord_sf(crs = 26911) + 
  scale_fill_viridis_c(option = "magma") 

popdata %>%
  ggplot(aes(fill = estimate)) + 
  geom_sf(color = NA) + 
  coord_sf(crs = 26911) + 
  scale_fill_viridis_c(option = "magma") 

# create leaflet map

pal <- colorFactor(palette = c("blue","green"),
                   levels = c("BurgerFi","Shake Shack"))

# Define the number of colors you want

#incomepal <- colorNumeric(palette = "Reds", domain = incomedata$estimate)
#previewColors(pal = incomepal, values = c(seq(25000,200000, by = 10000)))

incomepal <- colorQuantile(palette = "Reds", domain = incomedata$estimate, n = 9)

poppal <- colorQuantile(palette = "viridis", domain = popdata$estimate, n = 10)
  
storemaps <- 
  storelocations %>% 
  leaflet() %>% 
  # Use addTiles to plot the stores on the default Open Street Map tile
  addTiles() %>%
  # Plot the stores using addCircles
  addCircles(data = storelocations, color = ~pal(company), group = "All") %>%
  addCircles(data = osm_burgerfistores, color = ~pal(company), group = "BurgerFi") %>%
  addCircles(data = osm_shakeshackstores, color = ~pal(company), group = "Shake Shack") %>%
  addLayersControl(overlayGroups = c("All","Shake Shack","BurgerFi"), position = "bottomright")

storemaps
  
incomestoremaps <- 
    storelocations %>% 
    leaflet() %>% 
    # Use addTiles to plot the stores on the default Open Street Map tile
    addTiles() %>%
    addPolygons(data = incomedata, weight = 1, fillOpacity = .75, color = ~incomepal(estimate),
                label = ~paste0("Median Income: ", estimate),
                group = "Median Income") %>%
    addCircles(data = storelocations, color = ~pal(company), group = "All") %>%
    addCircles(data = osm_burgerfistores, color = ~pal(company), group = "BurgerFi") %>%
    addCircles(data = osm_shakeshackstores, color = ~pal(company), group = "Shake Shack") %>%
    addLayersControl(overlayGroups = c("All","Shake Shack","BurgerFi"), position = "bottomright") %>%
    addLegend("topright", 
              pal = incomepal, 
              values = incomedata$estimate,
              title = "Median Income",
              opacity = 1)
  
incomestoremaps

populationstoremaps <- 
  storelocations %>% 
  leaflet() %>% 
  # Use addTiles to plot the stores on the default Open Street Map tile
  addTiles() %>%
  addPolygons(data = popdata, weight = 1, fillOpacity = .75, color = ~poppal(estimate),
              label = ~paste0("Total Population: ", estimate),
              group = "Total Population") %>%
  #highlight = highlightOptions(weight = 3, color = "black", bringToFront = FALSE)) %>%
  # Plot the stores using addCircles
  addCircles(data = storelocations, color = ~pal(company), group = "All") %>%
  addCircles(data = osm_burgerfistores, color = ~pal(company), group = "BurgerFi") %>%
  addCircles(data = osm_shakeshackstores, color = ~pal(company), group = "Shake Shack") %>%
  addLayersControl(overlayGroups = c("All","Shake Shack","BurgerFi"), position = "bottomright") %>%
  addLegend("topright", 
            pal = poppal, 
            values = popdata$estimate,
            title = "Population percentiles",
            opacity = 1)

populationstoremaps

# quantiles
#quantile(incomedata$estimate, probs = seq(0,1, length = 9))
#quantile(popdata$estimate, probs = seq(0,1,length = 10))

# Most of the stores are in counties in the 9th percentile (highest range)
# These are counties with a median income between 68,596 and 142,299
# Filter for all counties that fall within the 9th percentile range

countiesMI_9P <- incomedata %>%
  filter(estimate > 68596)

# Most of the stores are in population area in the 10th percentile (highest range)
# These are counties with a total population between 206,674.70 and 10,081,570
# Filter for all counties that fall within the 10th percentile range

counties_10P <- popdata %>%
  filter(estimate > 206674)

# create a data frame for counties that meet both the median income and total population criteria
library(sf)
goodlocations <- merge(countiesMI_9P %>% as.data.frame(), counties_10P %>% as.data.frame(), by = "GEOID")
goodlocations$NAME.y <- NULL
goodlocations$geometry.y <- NULL

# create a county and state column
citystate <- data.frame(do.call('rbind', strsplit(as.character(goodlocations$NAME.x),',',fixed=TRUE)))
citystate <- citystate %>%
  rename(County = X1, State = X2)
goodlocations <- cbind(goodlocations,citystate)

# how many eligible counties per state
goodlocations %>%
  count(State) %>%
  arrange(desc(n))

# how many BurgerFi and Shake Shack locations are in each state
burgerfistores %>%
  count(State) %>%
  arrange(desc(n))

shakeshackstores %>%
  count(State) %>%
  arrange(desc(n))

# create a map highlighting the eligible counties plus store locations
goodlocations <- goodlocations %>% st_sf(sf_column_name = 'geometry.x')


potentialstorelocations <- 
  storelocations %>% 
  leaflet() %>% 
  # Use addTiles to plot the stores on the default Open Street Map tile
  addTiles() %>%
  addPolygons(data = goodlocations, weight = 1, fillOpacity = .75, color = "yellow") %>%
  #highlight = highlightOptions(weight = 3, color = "black", bringToFront = FALSE)) %>%
  # Plot the stores using addCircles
  addCircles(data = storelocations, color = ~pal(company), group = "All") %>%
  addCircles(data = osm_burgerfistores, color = ~pal(company), group = "BurgerFi") %>%
  addCircles(data = osm_shakeshackstores, color = ~pal(company), group = "Shake Shack") %>%
  addLayersControl(overlayGroups = c("All","Shake Shack","BurgerFi"), position = "bottomright")

potentialstorelocations

# I noticed that BurgerFi also had locations in lower median income areas compared to Shake Shack but they still focused on highly populated areas
# I'm creating a map that highlights those areas

countiesMI_5P <- incomedata %>%
  filter(estimate > 49908)

# create a data frame for counties that meet both the median income and total population criteria
library(sf)
goodlocations2 <- merge(countiesMI_5P %>% as.data.frame(), counties_10P %>% as.data.frame(), by = "GEOID")
goodlocations2$NAME.y <- NULL
goodlocations2$geometry.y <- NULL

# create a county and state column
citystate2 <- data.frame(do.call('rbind', strsplit(as.character(goodlocations2$NAME.x),',',fixed=TRUE)))
citystate2 <- citystate2 %>%
  rename(County = X1, State = X2)
goodlocations2 <- cbind(goodlocations2,citystate2)

# how many eligible counties per state
goodlocations2 %>%
  count(State) %>%
  arrange(desc(n))

# create a map highlighting the eligible counties plus store locations
goodlocations2 <- goodlocations2 %>% st_sf(sf_column_name = 'geometry.x')

potentialstorelocations2 <- 
  storelocations %>% 
  leaflet() %>% 
  # Use addTiles to plot the stores on the default Open Street Map tile
  addTiles() %>%
  addPolygons(data = goodlocations2, weight = 1, fillOpacity = .75, color = "yellow") %>%
  #highlight = highlightOptions(weight = 3, color = "black", bringToFront = FALSE)) %>%
  # Plot the stores using addCircles
  addCircles(data = storelocations, color = ~pal(company), group = "All") %>%
  addCircles(data = osm_burgerfistores, color = ~pal(company), group = "BurgerFi") %>%
  addCircles(data = osm_shakeshackstores, color = ~pal(company), group = "Shake Shack") %>%
  addLayersControl(overlayGroups = c("All","Shake Shack","BurgerFi"), position = "bottomright")

potentialstorelocations2

# save these maps
library(htmlwidgets)

saveWidget(storemaps, file = "storesmap.html")
saveWidget(incomestoremaps, file = "medianincomemap.html")
saveWidget(populationstoremaps, file = "totalpopmap.html")
saveWidget(potentialstorelocations, file = "potentialstorelocations.html")
saveWidget(potentialstorelocations2, file = "potentialstorelocations2.html")

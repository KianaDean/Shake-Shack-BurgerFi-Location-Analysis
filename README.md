# Shake-Shack-BurgerFi-Location-Analysis
Leaflet maps to help determine areas where Shake Shack and BurgerFi can  place new restaurants

## The Problem
I've been looking into potential stock investments and two companies I was curious about was Shake Shack and BurgerFi. Part of what can make a company's stock a good investment is the company's ability to expand and increase profits. I needed to a way to look at Shake Shack's and BurgerFi's current restaurant locations then based on where they were located currently determine if there were a lot of potential areas for them to still expand to.

## The Solution
Leaflet maps in R. I created a series of maps to look at potential store locations that Shake Shack and BurgerFi had yet to tap into.

## The Data
I needed to pull all of the current locations of Shake Shack and BurgerFi. 

For the Shake Shack data I used to the rvest package to webscrape [Shake Shack locations page](https://www.shakeshack.com/locations/).

For the BurgerFi data I copied and pasted their [locations](https://www.burgerfi.com/locations/) into a Word doc and used the officer package in R to scrape that information into a dataframe that could be exported to a csv.

If you would like to use the location data for your own analysis, I've stored the files in the data folder.

## Steps Taken
1. Read in the location files and combined the files into a single address dataframe
2. Using the tidygeocoder package, I pulled in the latitude and longitude of these addresses (for addresses where the coordinates weren't found, I manually entered them for accuracy purposes)
3. I pulled in the median household income and total population per county using the tidycensus package
4. Created leaflet maps
5. Saved the maps (if you would like to look at the maps created, the html files are in the maps folder)

## The Maps
* storesmap - plots all the Shake Shake and BurgerFi US store locations on a map
* medianincomemap - color codes the counties by median income levels along with the restaurant location markers on top
* totalpopmap - color codes the counties by total population levels along with the restaurant location markers on top
* potentialstorelocations - highlights the areas that are within the highest median household income and total population quantiles along with the restaurant location markers on top
 * potentialstorelocations2 - highlights the areas that are have a median household income greater than $49,908 and counties that have a total population greater than 206,674

#load packages
library(rvest)

# Set the URL to borrow the data.
ShakeShackURL <- paste0('https://www.shakeshack.com/locations/')

# Download the webpage.
ShakeShackWebpage <-
  ShakeShackURL %>%
  xml2::read_html()

# Get all of the store locations.
ShakeShackStores <- read_html(ShakeShackURL) %>% 
  html_nodes("div p") %>% 
  html_nodes(xpath = '//*[@class="address"]') %>%  
  html_text() %>%
  data.frame()

ShakeShackStores <- ShakeShackStores %>% 
  mutate(across(where(is.character), str_trim))

write.csv(ShakeShackStores,"C:\\Users\\kadea\\Desktop\\ShakeShackStores.csv")

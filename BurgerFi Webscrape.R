#load libraries
library(officer)
library(janitor)
library(ggtext)
library(tidyverse)
library(textreadr)

doc <- read_docx("BurgerFiShakeShackLocationAnalysis/BurgerFi locations.docx") %>%
  data.frame()

#pull only rows with a comma in them
burgerfistores <- burgerfilocationdoc %>%
  filter(str_detect(., ","))

#rename first column
names(burgerfistores)[1] <- "Street"

write.csv(burgerfistores,"C:\\Users\\kadea\\Desktop\\BurgerFiStores.csv")

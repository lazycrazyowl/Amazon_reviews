
library(tidyverse)
library(rvest)
library(lubridate)

url <- "https://www.amazon.com/Madden-NFL-20-Xbox-One/product-reviews/B07QPW7N6M/ref=cm_cr_arp_d_paging_btm_next_2?ie=UTF8&reviewerType=all_reviews&pageNumber=1"
html <- read_html(url)

title <- html %>%
  html_nodes("[data-hook='review-title']") %>%
  html_text() %>%
  str_trim() %>%
  .[3:12]

review <- html %>%
  html_nodes("[data-hook='review-body']") %>%
  html_text() %>%
  str_trim() 

stars <- html %>%
  html_nodes("[data-hook='review-star-rating']") %>%
  html_text() %>%
  str_split(" ") %>%
  map(1) %>% 
  unlist() %>%
  as.integer()

name <- html %>%
  html_nodes("[class='a-profile-name']") %>%
  html_text() %>%
  .[3:12]

verified <- html %>%
  html_nodes("[class='a-size-mini a-color-state a-text-bold']") %>%
  html_text()

date <- html %>%
  html_nodes("[data-hook='review-date']") %>%
  html_text() %>%
  mdy() 

df <- tibble(name,date,stars,title,review,verified)
  
  
  
  
  


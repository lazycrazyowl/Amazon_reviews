
library(tidyverse)
library(rvest)
library(lubridate)

base_url <- "https://www.amazon.com/Echo-Dot-3rd-Gen-Charcoal/product-reviews/B07FZ8S74R/ref=cm_cr_getr_d_paging_btm_prev_1?ie=UTF8&reviewerType=all_reviews&pageNumber="

page_lim <- 250

page_nums <- 1:page_lim

urls <- paste0(base_url,page_nums)

df <- NULL

for (url in urls) {
  print(url)
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
  
  row <- tibble(name,date,stars,title,review)
  
  df <- rbind(df,row)  
}

write_csv(df, "echo_dot_reviews.csv")
  
  


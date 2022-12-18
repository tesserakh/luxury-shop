#!/usr/bin/Rscript
# pkgs = c("DBI", "RSQLite", "dplyr")
library(dplyr, warn.conflicts = FALSE)

# import product table from sqlite3 using db connection
con <- DBI::dbConnect(RSQLite::SQLite(), "data/product.db")
product <- DBI::dbReadTable(con, "product") %>% as_tibble()
DBI::dbDisconnect(con)

# reformatting date and only use data with DKK currency
product <- product %>% 
  filter(currency == "DKK")%>% 
  mutate(date = as.Date(date))

# the last date from data become the day of analysis
analysis_day <- max(product$date)

# generate sales dataframe
sales <- product %>% 
  group_by(url) %>% 
  # calculate appearance, even when is not sold yet
  mutate(n_days = max(date) - min(date) + 1) %>% 
  # subset(date == max(date) | date == min(date)) %>% 
  mutate(
    id = gsub("^(.+)_\\d{8}$", "\\1", productid),
    # price calculation
    is_discount = if_else(is.na(discount), FALSE, TRUE),
    discount_pct = if_else(is_discount, (price-discount)/price, 0),
    price = if_else(is.na(discount), price, discount), # should be in last of price calculating
    # date calculation
    date_first = min(date),
    date_sale = case_when(
      date == max(date) & availability == "out stock" ~ date,
      max(date) < analysis_day & availability == "in stock" ~ max(date) # missing out of scraper
    ),
    # status or availability now, related to date calculation
    status = case_when(
      date == max(date) & availability == "out stock" ~ availability,
      max(date) < analysis_day & availability == "in stock" ~ "out stock", # missing out of scraper
      max(date) == analysis_day & availability == "in stock" ~ availability
    )
  ) %>% 
  # use only the last of appearance
  filter(date == max(date)) %>% 
  # select fields to save
  select(
    name, price, currency, is_discount, discount_pct,
    category, color, brand, date_first, date_sale, n_days, status,
    id, picture, url
  ) %>% 
  ungroup()

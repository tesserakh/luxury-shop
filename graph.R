library(ggplot2)
library(dplyr, warn.conflicts = FALSE)

source("sales.R")

# revenue
revenue <- sales %>% 
  group_by(date_sale) %>% 
  summarise(
    revenue = sum(price),
    currency = unique(currency),
    .groups = "drop"
  ) %>% 
  filter(!is.na(date_sale))

ggplot(data = revenue) +
  geom_line(aes(date_sale, revenue)) +
  labs(title = "Daily Revenue", y = "Revenue (DKK)") + 
  theme_linedraw() +
  theme(
    axis.title.x = element_blank()
  )

# best seller brand
popular_brand <- sales %>% 
  select(price, category, color, brand, date_sale, status, id) %>% 
  filter(status == "out stock") %>% 
  group_by(brand) %>% 
  summarise(count = n(), .groups = "drop") %>% 
  arrange(desc(count))

popular_brand <- bind_rows(
  popular_brand %>% 
    slice_head(n = 7) %>% 
    arrange(count),
  popular_brand %>% 
    slice_tail(n = nrow(.)-7) %>% 
    summarise(count = sum(count)) %>% 
    mutate(brand = "Others")) %>% 
  mutate(
    label = stringr::str_replace(brand, "\\s", "\n"),
    id_sort = row_number()
  )

ggplot(data = popular_brand) +
  geom_bar(aes(reorder(label, id_sort), count, fill = brand), stat = "identity") +
  labs(
    title = "Best Seller Brand",
    subtitle = "Since December 11, 2022"
  ) +
  theme_linedraw() +
  theme(
    axis.title = element_blank(),
    legend.position = "none"
  )

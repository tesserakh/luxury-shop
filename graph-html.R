library(dygraphs)
library(xts)

source("sales.R")

revenue <- sales %>% 
  group_by(date_sale) %>% 
  summarise(
    revenue = sum(price),
    currency = unique(currency),
    .groups = "drop"
  ) %>% 
  filter(!is.na(date_sale))

# creating the xts necessary to use dygraph
don <- xts(x = revenue$revenue, order.by = revenue$date_sale)

# plotting graph
p <- dygraph(don) %>%
  dyOptions(labelsUTC = TRUE, fillGraph=TRUE, fillAlpha=0.1, drawGrid = FALSE, colors="#D8AE5A") %>%
  dyRangeSelector() %>%
  dyCrosshair(direction = "vertical") %>%
  dyHighlight(highlightCircleSize = 5, highlightSeriesBackgroundAlpha = 0.2, hideOnMouseOut = FALSE)  %>%
  dyRoller(rollPeriod = 1)

# save the widget
# library(htmlwidgets)
# if (!dir.exists("htmlwidgets")) dir.create("htmlwidgets")
# saveWidget(p, file = paste0(getwd(), "/htmlwidgets/revenue.html"))
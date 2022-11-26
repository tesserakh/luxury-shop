# Data model for scrapy items
# Documentation: https://docs.scrapy.org/en/latest/topics/items.html

import scrapy


class ProductItem(scrapy.Item):
    name = scrapy.Field()
    price = scrapy.Field()
    discount = scrapy.Field()
    currency = scrapy.Field()
    availability = scrapy.Field()
    picture = scrapy.Field()
    category = scrapy.Field()
    color = scrapy.Field()
    brand = scrapy.Field()
    date = scrapy.Field()
    url = scrapy.Field()

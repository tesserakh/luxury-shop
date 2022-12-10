from datetime import datetime
from luxurybyho.items import ProductItem
import scrapy
import logging


class ShopSpider(scrapy.Spider):
    name = 'shop'
    allowed_domains = ['luxurybyho.com']
    start_urls = ['https://luxurybyho.com/shop?orderby=price-desc']

    def parse(self, response):
        for product in response.css('ul.products.products-list > li'):
            url = product.css('h3.product-title > a').attrib['href']
            yield response.follow(url, callback=self.parse_product)
        
        try:
            next_page = response.css('a.next.page-numbers').attrib['href']
        except:
            next_page = None
        if next_page is not None:
            yield response.follow(next_page, callback=self.parse)
    
    def parse_product(self, response):
        item = ProductItem()
        try:
            product = response.css('div.product > div.row')
            item['name'] = product.css('h1.product_title::text').get().strip()
            try:
                # price = normal price
                # discount = price when discount applied
                item['price'] = product.css('p.price > span.woocommerce-Price-amount > bdi::text').get().strip().replace('.','').replace(',','.')
                item['discount'] = None
            except:
                item['price'] = product.css('p.price > del > span.woocommerce-Price-amount > bdi::text').get().strip().replace('.','').replace(',','.')
                item['discount'] = product.css('p.price > ins > span.woocommerce-Price-amount > bdi::text').get().strip().replace('.','').replace(',','.')
            try:
                item['currency'] = product.css('span.woocommerce-Price-currencyCode::text').get().strip()
            except:
                item['currency'] = product.css('span.woocommerce-Price-currencySymbol::text').get().strip()
            item['availability'] = product.css('div.product-stock > span:nth-child(2)::text').get().strip().lower()
            #item['picture'] = product.css('div.img-thumbnail.slick-active > a.active').attrib['href']
            item['picture'] = product.css('div.woocommerce-product-gallery__image > a').attrib['href']
            product_attrib = response.css('table.woocommerce-product-attributes.shop_attributes')
            for row in product_attrib.css('tr'):
                field_name = row.css('th::text').get().lower()
                if field_name == 'category':
                    content = row.css('td > p > a')
                    text_content = ', '.join([a.css('::text').get() for a in content])
                    item[field_name] = text_content
                elif field_name in ('color', 'brand'):
                    text_content = row.css('td > p::text').get()
                    item[field_name] = text_content
                else:
                    pass
            item['date'] = datetime.utcnow().strftime('%Y-%m-%d')
            item['url'] = response.url
            item['productid'] = "%s_%s" % (
                item['url'].split('/')[-2].replace('-', '_'),
                item['date'].replace('-','')
            )
            yield item
        except Exception as e:
            logging.error(f'{e} ({response.url})')


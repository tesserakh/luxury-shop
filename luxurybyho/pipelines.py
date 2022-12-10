# Define your item pipelines here
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html
# useful for handling different item types with a single interface

from itemadapter import ItemAdapter
from datetime import datetime
import sqlite3

class LuxurybyhoPipeline:

    def __init__(self):
        self.con = sqlite3.connect('data/product.db')
        self.cur = self.con.cursor()
        self.create_table()

    def create_table(self):
        self.cur.execute("""CREATE TABLE IF NOT EXISTS product(
            name TEXT,
            price REAL,
            discount REAL,
            currency TEXT,
            availability TEXT,
            picture TEXT,
            category TEXT,
            color TEXT,
            brand TEXT,
            date DATE,
            url TEXT,
            productid TEXT PRIMARY KEY
        );""")

    def process_item(self, item, spider):
        self.cur.execute("""INSERT OR IGNORE INTO product VALUES (?,?,?,?,?,?,?,?,?,?,?,?);""",
            (
                item.get('name', None),
                item.get('price', None),
                item.get('discount', None),
                item.get('currency', None),
                item.get('availability', None),
                item.get('picture', None),
                item.get('category', None),
                item.get('color', None),
                item.get('brand', None),
                item.get('date', datetime.utcnow().strftime('%Y-%m-%d')),
                item.get('url'),
                item.get('productid')
            )
        )
        self.con.commit()
        return item
        

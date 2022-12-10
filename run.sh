#!/bin/bash

scrapy crawl shop --logfile logs.log -L WARNING
cat logs.log


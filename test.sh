#!/bin/bash

scrapy crawl shop --logfile logs.log -L WARNING -O test.json
SIZE=$(stat -c%s test.json)
if [ $SIZE -gt 0 ]; then
  exit 0
else
  exit 1
fi
Beats dashboards
================

This repository contains sample Kibana4 dashboards for visualizing the data
gathered by the Elastic [Beats](https://www.elastic.co/products/beats).

Installation
-------------

To load the dashboards, execute the script pointing to the Elasticsearch HTTP
URL:

        ./load.sh http://localhost:9200


If you want to use HTTP authentication for Elasticsearch, you can specify the
credentials as a second parameter:

        ./load.sh http://localhost:9200 'admin:password'

Technical details
-----------------
The `dashboards` folder contains the JSON files as exported from Kibana, by
using the simple python tool from the `save` directory. The loader is a simple
shell script so that you don't need python installed when loading the
dashboards.

Screenshots
-----------

  ![Packetbeat Statistics](/screenshots/Packetbeat-statistics.png)
  ![MySql performance](/screenshots/MySql-performance.png)
  ![Thrift performance](/screenshots/Thrift-performance.png)

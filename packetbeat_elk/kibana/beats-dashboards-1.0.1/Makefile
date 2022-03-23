VERSION?=$(shell git rev-parse --abbrev-ref HEAD)

.PHONY: dist
dist:
	git archive --format tar.gz --prefix beats-dashboards-$(VERSION)/ -o ../beats-dashboards-$(VERSION).tar.gz HEAD

.PHONY: upload
upload: dist
	aws s3 cp --acl public-read ../beats-dashboards-$(VERSION).tar.gz s3://download.elasticsearch.org/beats/dashboards/

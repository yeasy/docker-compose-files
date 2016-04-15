#!/bin/sh
# Script that builds a tar ball and uploads it to S3.

VERSION=$1

if [ -z $VERSION ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

git archive \
    --format tar.gz \
    --prefix packetbeat-dashboards-$VERSION/ \
    -o ../packetbeat-dashboards-$VERSION.tar.gz \
    v$VERSION

aws s3 cp \
    packetbeat-dashboards-$VERSION.tar.gz \
    s3://download.elasticsearch.org/beats/packetbeat/

#!/bin/sh

LATEST_SPARK_VERSION=3.4.1
LATEST_JUPYTER_VERSION=7.0.0

for SPARK_VERSION in 3.4.1
do
    for JUPYTER_VERSION in 7.0.0
    do
        CMD="docker buildx build --platform linux/arm64,linux/amd64
 --push --rm --no-cache
 --build-arg SPARK_BASE_IMAGE=loum/pyjdk:python3.10-openjdk11
 --build-arg SPARK_VERSION=$SPARK_VERSION
 --build-arg JUPYTER_VERSION=$JUPYTER_VERSION
 --build-arg JUPYTER_PORT=8889"

        if [ "$SPARK_VERSION" = "$LATEST_SPARK_VERSION" ] && [ "$JUPYTER_VERSION" = "$LATEST_JUPYTER_VERSION" ]
        then
            CMD="$CMD --tag loum/jupyter-pyspark:latest"
        fi

        CMD="$CMD --tag loum/jupyter-pyspark:$JUPYTER_VERSION-$SPARK_VERSION ."

        $CMD
    done
done

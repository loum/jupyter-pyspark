#!/bin/sh

LATEST_SPARK_VERSION=3.5.1
LATEST_JUPYTER_VERSION=7.1.2

for _SPARK_VERSION in 3.5.1
do
    for _JUPYTER_VERSION in 7.1.2
    do
        CMD="docker buildx build --platform linux/arm64,linux/amd64
 --push --rm --no-cache
 --build-arg SPARK_BASE_IMAGE=loum/pyjdk:python3.11-openjdk11
 --build-arg SPARK_VERSION=$_SPARK_VERSION
 --build-arg JUPYTER_VERSION=$_JUPYTER_VERSION
 --build-arg JUPYTER_PORT=8889"

        if [ "$_SPARK_VERSION" = "$LATEST_SPARK_VERSION" ] && [ "$_JUPYTER_VERSION" = "$LATEST_JUPYTER_VERSION" ]
        then
            CMD="$CMD --tag loum/jupyter-pyspark:latest"
        fi

        CMD="$CMD --tag loum/jupyter-pyspark:$_JUPYTER_VERSION-$_SPARK_VERSION ."

        $CMD
    done
done

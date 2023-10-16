#!/bin/sh

for _SPARK_VERSION in 3.5.0
do
    for _JUPYTER_VERSION in 7.0.5
    do
        CMD="docker buildx build --platform linux/arm64,linux/amd64
 --push --rm --no-cache
 --build-arg SPARK_BASE_IMAGE=loum/pyjdk:python3.10-openjdk11
 --build-arg SPARK_VERSION=$SPARK_VERSION
 --build-arg JUPYTER_VERSION=$JUPYTER_VERSION
 --build-arg JUPYTER_PORT=8889"

        if [ "$_SPARK_VERSION" = "$SPARK_VERSION" ] && [ "$_JUPYTER_VERSION" = "$JUPYTER_VERSION" ]
        then
            CMD="$CMD --tag loum/jupyter-pyspark:latest"
        fi

        CMD="$CMD --tag loum/jupyter-pyspark:$JUPYTER_VERSION-$SPARK_VERSION ."

        $CMD
    done
done

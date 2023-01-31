#!/bin/sh

docker buildx build --platform linux/arm64,linux/amd64\
 --push --rm --no-cache\
 --build-arg SPARK_BASE_IMAGE=loum/pyjdk:python3.10-openjdk11\
 --build-arg SPARK_VERSION=3.3.1\
 --build-arg JUPYTER_VERSION=6.5.2\
 --build-arg JUPYTER_PORT=8889\
 --tag loum/jupyter-pyspark:6.5.1-3.3.1 .

docker buildx build --platform linux/arm64,linux/amd64\
 --push --rm --no-cache\
 --build-arg SPARK_BASE_IMAGE=loum/pyjdk:python3.10-openjdk11\
 --build-arg SPARK_VERSION=3.3.1\
 --build-arg JUPYTER_VERSION=6.5.2\
 --build-arg JUPYTER_PORT=8889\
 --tag loum/jupyter-pyspark:6.5.2-3.3.1\
 --tag loum/jupyter-pyspark:latest .

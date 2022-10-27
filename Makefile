.DEFAULT_GOAL := help

MAKESTER__REPO_NAME := loum

SPARK_VERSION := 3.3.1
JUPYTER_VERSION := 6.5.1

# Tagging convention used: <jupyter-version>-<spark-version>-<image-release-number>
MAKESTER__VERSION := $(JUPYTER_VERSION)-$(SPARK_VERSION)
MAKESTER__RELEASE_NUMBER := 1

MAKESTER__CONTAINER_NAME := jupyter-pyspark

include makester/makefiles/makester.mk
include makester/makefiles/docker.mk
include makester/makefiles/python-venv.mk

SPARK_BASE_IMAGE := loum/pyjdk:python3.10-openjdk11

JUPYTER_PORT ?= 8889
MAKESTER__BUILD_COMMAND = $(DOCKER) build --rm\
 --no-cache\
 --build-arg SPARK_BASE_IMAGE=$(SPARK_BASE_IMAGE)\
 --build-arg SPARK_VERSION=$(SPARK_VERSION)\
 --build-arg JUPYTER_VERSION=$(JUPYTER_VERSION)\
 --build-arg JUPYTER_PORT=$(JUPYTER_PORT)\
 -t $(MAKESTER__IMAGE_TAG_ALIAS) .

MAKESTER__RUN_COMMAND := $(DOCKER) run --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --hostname $(MAKESTER__CONTAINER_NAME)\
 --env JUPYTER_PORT=$(JUPYTER_PORT)\
 --volume $(PWD)/notebooks:/home/dummy/notebooks\
 --publish 18080:18080\
 --publish $(JUPYTER_PORT):$(JUPYTER_PORT)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

init: clear-env makester-requirements

backoff:
	@$(PYTHON) makester/scripts/backoff -d "Web UI for Jupyter" -p $(JUPYTER_PORT) localhost

controlled-run: run backoff jupyter-server

jupyter-server:
	$(info ### enter the Jupyter Notebook server URL into your browser:)
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash -c "jupyter notebook list"

spark-version: backoff
	@$(DOCKER) exec $(MAKESTER__CONTAINER_NAME) bash -c ".local/bin/spark-submit --version" || true

pyspark: backoff
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash -c ".local/bin/pyspark"

spark: backoff
	@$(DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash -c ".local/bin/spark-shell"

help: makester-help docker-help python-venv-help
	@echo "(Makefile)\n\
  controlled-run       Start and wait until all container services stabilise\n\
  spark-version        Spark version in running container $(MAKESTER__CONTAINER_NAME)\"\n\
  pyspark              Start the pyspark REPL\n\
  spark                Start the spark REPL\n"

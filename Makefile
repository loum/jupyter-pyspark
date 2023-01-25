.SILENT:
.DEFAULT_GOAL := help

MAKESTER__CONTAINER_NAME := jupyter-pyspark

include makester/makefiles/makester.mk

MAKESTER__REPO_NAME := loum

SPARK_VERSION := 3.3.1
JUPYTER_VERSION := 6.5.1

# Tagging convention used: <jupyter-version>-<spark-version>-<image-release-number>
MAKESTER__VERSION := $(JUPYTER_VERSION)-$(SPARK_VERSION)
MAKESTER__RELEASE_NUMBER := 1

ifeq ($(MAKESTER__ARCH), arm64)
DOCKER_PLATFORM := linux/arm64/v8
else
DOCKER_PLATFORM := linux/amd64
endif

SPARK_BASE_IMAGE := loum/pyjdk:python3.10-openjdk11

DOCKER_BUILDX_BUILDER := multiarch
JUPYTER_PORT ?= 8889
MAKESTER__BUILD_COMMAND = --rm --no-cache\
 --builder $(DOCKER_BUILDX_BUILDER)\
 --platform $(DOCKER_PLATFORM)\
 --build-arg SPARK_BASE_IMAGE=$(SPARK_BASE_IMAGE)\
 --build-arg SPARK_VERSION=$(SPARK_VERSION)\
 --build-arg JUPYTER_VERSION=$(JUPYTER_VERSION)\
 --build-arg JUPYTER_PORT=$(JUPYTER_PORT)\
 --load\
 --tag $(MAKESTER__IMAGE_TAG_ALIAS) .

MAKESTER__RUN_COMMAND := $(MAKESTER__DOCKER) run\
 --rm -d\
 --platform $(DOCKER_PLATFORM)\
 --name $(MAKESTER__CONTAINER_NAME)\
 --hostname $(MAKESTER__CONTAINER_NAME)\
 --env JUPYTER_PORT=$(JUPYTER_PORT)\
 --volume $(PWD)/notebooks:/home/dummy/notebooks\
 --publish 18080:18080\
 --publish $(JUPYTER_PORT):$(JUPYTER_PORT)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

init: py-venv-clear py-venv-init py-install-makester

backoff:
	@venv/bin/makester backoff localhost $(JUPYTER_PORT) --detail "Web UI for Jupyter"

controlled-run: container-run backoff jupyter-server

jupyter-server:
	$(info ### enter the Jupyter Notebook server URL into your browser:)
	@$(MAKESTER__DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash -c "jupyter notebook list"

spark-version:
	@$(MAKESTER__DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash -c ".local/bin/spark-submit --version" || true

pyspark:
	@$(MAKESTER__DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash -c ".local/bin/pyspark"

spark:
	@$(MAKESTER__DOCKER) exec -ti $(MAKESTER__CONTAINER_NAME) bash -c ".local/bin/spark-shell"

help: makester-help
	@echo "(Makefile)\n\
  controlled-run       Start and wait until all container services stabilise\n\
  spark-version        Spark version in running container $(MAKESTER__CONTAINER_NAME)\"\n\
  pyspark              Start the pyspark REPL\n\
  spark                Start the spark REPL\n"

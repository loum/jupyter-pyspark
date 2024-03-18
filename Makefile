.SILENT:
.DEFAULT_GOAL := help

MAKESTER__REPO_NAME := loum
MAKESTER__CONTAINER_NAME := jupyter-pyspark
MAKESTER__INCLUDES=py docker

include makester/makefiles/makester.mk

#
# Makester overrides.
#
export SPARK_VERSION := 3.5.1
export JUPYTER_VERSION := 7.1.2

# Tagging convention used: <jupyter-version>-<spark-version>-<image-release-number>
MAKESTER__VERSION := $(JUPYTER_VERSION)-$(SPARK_VERSION)
MAKESTER__RELEASE_NUMBER := 1

SPARK_BASE_IMAGE := loum/pyjdk:python3.11-openjdk11

JUPYTER_PORT ?= 8889
MAKESTER__BUILD_COMMAND := --rm --no-cache\
 --build-arg SPARK_BASE_IMAGE=$(SPARK_BASE_IMAGE)\
 --build-arg SPARK_VERSION=$(SPARK_VERSION)\
 --build-arg JUPYTER_VERSION=$(JUPYTER_VERSION)\
 --build-arg JUPYTER_PORT=$(JUPYTER_PORT)\
 --tag $(MAKESTER__IMAGE_TAG_ALIAS) .

DRIVER_MEMORY ?= 2g
MAKESTER__RUN_COMMAND := $(MAKESTER__DOCKER) run\
 --rm -d\
 --name $(MAKESTER__CONTAINER_NAME)\
 --hostname localhost\
 --env JUPYTER_PORT=$(JUPYTER_PORT)\
 --env DRIVER_MEMORY=$(DRIVER_MEMORY)\
 --volume $(PWD)/notebooks:/home/user/notebooks\
 --publish 18080:18080\
 --publish $(JUPYTER_PORT):$(JUPYTER_PORT)\
 $(MAKESTER__SERVICE_NAME):$(HASH)

#
# Local Makefile targets.
#
# Initialise the development environment.
init: py-venv-clear py-venv-init py-install-makester

image-bulk-build:
	$(info ### Container image bulk build ...)
	scripts/bulkbuild.sh

image-pull-into-docker:
	$(info ### Pulling local registry image $(MAKESTER__SERVICE_NAME):$(HASH) into docker)
	$(MAKESTER__DOCKER) pull $(MAKESTER__SERVICE_NAME):$(HASH)

image-tag-in-docker: image-pull-into-docker
	$(info ### Tagging local registry image $(MAKESTER__SERVICE_NAME):$(HASH) for docker)
	$(MAKESTER__DOCKER) tag $(MAKESTER__SERVICE_NAME):$(HASH) $(MAKESTER__STATIC_SERVICE_NAME):$(HASH)

image-transfer: image-tag-in-docker
	$(info ### Deleting pulled local registry image $(MAKESTER__SERVICE_NAME):$(HASH))
	$(MAKESTER__DOCKER) rmi $(MAKESTER__SERVICE_NAME):$(HASH)

multi-arch-build: image-registry-start image-buildx-builder
	$(info ### Starting multi-arch builds ...)
	$(MAKE) MAKESTER__DOCKER_PLATFORM=linux/arm64,linux/amd64 image-buildx
	$(MAKE) image-transfer
	$(MAKE) image-registry-stop

backoff:
	@venv/bin/makester backoff $(MAKESTER__LOCAL_IP) $(JUPYTER_PORT) --detail "Web UI for Jupyter"

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

version: MAKESTER__VERSION_FILE := $(PWD)/VERSION
version: _RELEASE := $(MAKESTER__VERSION)-$(MAKESTER__RELEASE_NUMBER)
version:
	$(info ### Setting current version to $(_RELEASE) in $(MAKESTER__VERSION_FILE))
	$(shell which echo) $(_RELEASE) > $(MAKESTER__VERSION_FILE)

help: makester-help
	@echo "(Makefile)\n\
  controlled-run       Start and wait until all container services stabilise\n\
  image-bulk-build     Build all multi-platform container images\n\
  init                 Build the local development environment\n\
  multi-arch-build     Convenience target for multi-arch container image builds\n\
  pyspark              Start the pyspark REPL\n\
  spark                Start the spark REPL\n\
  spark-version        Spark version in running container \"$(MAKESTER__CONTAINER_NAME)\"\n\
  version              Write out release version\n"

.PHONY: version

# Jupyter Notebook (with PyPI Apache Spark)
- [Overview](#overview)
- [Quick Links](#quick-links)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Getting Help](#getting-help)
- [Docker Image Management](#docker-image-management)
  - [Image Build](#image-build)
  - [Image Searches](#image-searches)
  - [Image Tagging](#image-tagging)
- [Interact with Jupyter as Docker Container](#interact-with-jupyter-as-docker-container)

## Overview

[The Jupyter Notebook](https://jupyter-notebook.readthedocs.io/en/stable/) on Docker with its own Apache Spark compute engine.

## Quick Links

- [The Jupyter Notebook](https://jupyter-notebook.readthedocs.io/en/stable/)

## Quick Start

Impatient and just want Jupyter with Apache Spark quickly?  Place your notebooks under the `notebook` directory and optionally set your Python dependencies in your `requirements.txt` file. Then run:

```
docker run --rm -d\
 --name jupyter-pyspark\
 --hostname jupyter-pyspark\
 --env JUPYTER_PORT=8889\
 --volume $PWD/notebooks:/home/dummy/notebooks\
 --volume $PWD/requirements.txt:/requirements.txt\
 --publish 8889:8889\
 loum/jupyter-pyspark:latest
```

To get the URL of your local server:

```
docker exec -ti jupyter-pyspark bash -c "jupyter notebook list"
```

## Prerequisites

- [Docker](https://docs.docker.com/install/)
- [GNU make](https://www.gnu.org/software/make/manual/make.html)

## Getting Started

Get the code and change into the top level `git` project directory:

```
git clone https://github.com/loum/jupyter-pyspark.git && cd jupyter-pyspark
```

> **_NOTE:_** Run all commands from the top-level directory of the `git` repository.

For first-time setup, get the [Makester project](https://github.com/loum/makester.git):

```
git submodule update --init
```

Keep [Makester project](https://github.com/loum/makester.git) up-to-date with:

```
make submodule-update
```

Setup the environment:

```
make init
```

## Getting Help

There should be a `make` target to get most things done. Check the help for more information:

```
make help
```

### Image Build

```
make image-build
```

### Image Searches

Search for existing Docker image tags with command:

```
make image-search
```

### Image Tagging
By default, `makester` will tag the new Docker image with the current branch hash. This provides a degree of uniqueness but is not very intuitive. That's where the `tag-version` `Makefile` target can help. To apply tag as per project tagging convention `<jupyter-version>-<spark-version>-<image-release-number>`:

```
make image-tag-version
```

To tag the image as `latest`:

```
make image-tag-latest
```

## Interact with Jupyter as Docker Container

To start the container and wait for the Jupyter Notebook service to initiate:

```
make controlled-run
```

Once all services stablise you will should be presented with a list of running Jupyter Notebook servers:

```
Currently running servers:
http://0.0.0.0:8889/?token=5ffb5233ac5d52371fa4b7cfcc9aaaf425e749574ae32fc3 :: /home/dummy/notebooks
```

Browse to the URL to start interacting with the notebooks.

To stop:

```
make container-stop
```

---
[top](#jupyter-notebook-with-pypi-apache-spark)

# Jupyter Notebook (with PyPI Apache Spark)

- [Overview](#overview)
- [Quick links](#quick-links)
- [Quick start](#quick-start)
- [Prerequisites](#prerequisites)
- [Getting started](#getting-started)
- [Help](#help)
- [Docker container image management](#docker-container-image-management)
  - [Image build and tagging](#image-build-and-tagging)
  - [Image searches](#image-searches)
- [Interact with Jupyter as Docker Container](#interact-with-jupyter-as-docker-container)

## Overview

[The Jupyter Notebook](https://jupyter-notebook.readthedocs.io/en/stable/) on Docker with its own Apache Spark compute engine.

## Quick links

- [The Jupyter Notebook](https://jupyter-notebook.readthedocs.io/en/stable/)

## Quick start

Impatient and just want Jupyter with Apache Spark quickly? Place your notebooks under the `notebook` directory and optionally set your Python dependencies in your `requirements.txt` file. Then run:

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
- [Makester project](https://github.com/loum/makester.git)

## Getting started

[Makester](https://loum.github.io/makester/) is used as the Integrated Developer Platform.

Get the code and change into the top level `git` project directory:

```
git clone https://github.com/loum/jupyter-pyspark.git && cd jupyter-pyspark
```

> \[!NOTE
>
> Run all commands from the top-level directory of the `git` repository.

## Help

There should be a `make` target to get most things done. Check the help for more information:

```
make help
```

## Docker container image management

### Image build and tagging

```
make image-buildx
```

Container image build tagging convention used is:

- `<jupyter-version>-<spark-version>-<image-release-number>`
- `latest`

### Image searches

Search for existing Docker image tags with command:

```
make image-search
```

## Interact with Jupyter as Docker container

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

______________________________________________________________________

[top](#jupyter-notebook-with-pypi-apache-spark)

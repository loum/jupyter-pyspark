#!/bin/sh

# Start the Jupyter server.
PYSPARK_DRIVER_PYTHON=/home/dummy/.local/bin/jupyter\
 SPARK_HOME=/home/dummy/.local/lib/python3.10/site-packages/pyspark/\
 PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH\
 PYSPARK_DRIVER_PYTHON_OPTS="notebook\
 --no-browser\
 --ip 0.0.0.0\
 --notebook-dir=/home/dummy/notebooks/\
 --port=$JUPYTER_PORT"\
 /home/dummy/.local/bin/pyspark

# Block until we signal exit.
trap 'exit 0' TERM
while true; do sleep 0.5; done

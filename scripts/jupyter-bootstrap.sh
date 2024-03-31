#!/bin/sh

# Start the Jupyter server.
PYSPARK_DRIVER_PYTHON=/home/user/.local/bin/jupyter\
 SPARK_HOME=/home/user/.local/lib/python3.11/site-packages/pyspark/\
 PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH\
 PYSPARK_DRIVER_PYTHON_OPTS="notebook\
 --no-browser\
 --ip 0.0.0.0\
 --notebook-dir=/home/user/notebooks/\
 --port=$JUPYTER_PORT"\
 /home/user/.local/bin/pyspark\
 --packages io.delta:delta-spark_2.12:3.1.0\
 --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension"\
 --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"\
 --conf "spark.sql.repl.eagerEval.enabled=True"\
 --conf "spark.sql.ansi.enabled=True"\
 --conf "spark.sql.warehouse.dir=/home/user/spark-warehouse"\
 --driver-java-options "-Dderby.system.home=/home/user/derby"\
 --driver-memory "${DRIVER_MEMORY:-2g}"

# Block until we signal exit.
trap 'exit 0' TERM
while true; do sleep 0.5; done

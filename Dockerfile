# syntax=docker/dockerfile:1.4

ARG SPARK_BASE_IMAGE

FROM $SPARK_BASE_IMAGE AS builder

USER root

RUN apt-get update && apt-get install -y --no-install-recommends\
 gcc python3-dev &&\
 apt-get autoremove -yqq --purge &&\
 rm -rf /var/lib/apt/lists/*

USER user

ARG SPARK_VERSION
ARG JUPYTER_VERSION
RUN python -m pip install\
 --no-cache-dir\
 --user\
 delta-spark\
 numpy\
 pandas\
 pyspark==$SPARK_VERSION\
 notebook==$JUPYTER_VERSION &&\
 find .local/lib/python*/site-packages/ -depth\
   \(\
     \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
     -o \
     \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
   \) -exec rm -rf '{}' +;

### builder layer end

ARG SPARK_BASE_IMAGE

FROM $SPARK_BASE_IMAGE AS main
USER root

# Run everything as JUPYTER_USER.
ARG JUPYTER_USER=user
ARG JUPYTER_GROUP=user
ARG JUPYTER_HOME=/home/user

COPY scripts/jupyter-bootstrap.sh /jupyter-bootstrap.sh

WORKDIR $JUPYTER_HOME

WORKDIR $JUPYTER_HOME/.local
COPY --from=builder --chown=$JUPYTER_USER:$JUPYTER_GROUP $JUPYTER_HOME/.local $JUPYTER_HOME/.local/

ARG JUPYTER_PORT=8889
EXPOSE $JUPYTER_PORT

# Needed for additional kernel installs.
WORKDIR /usr/local/share/jupyter
RUN chown -R $JUPYTER_USER:$JUPYTER_GROUP .

WORKDIR $JUPYTER_HOME/.ipython/profile_default/startup
COPY scripts/startup/00-cell-magic-pyspark-sql.py 00-cell-magic-pyspark-sql.py
ENV PATH "$PATH:$JUPYTER_HOME/.local/bin"

# Set derby home and spark-warehouse
WORKDIR $JUPYTER_HOME/derby
WORKDIR $JUPYTER_HOME/spark-warehouse

RUN chown -R $JUPYTER_USER:$JUPYTER_GROUP $JUPYTER_HOME

WORKDIR $JUPYTER_HOME
USER $JUPYTER_USER

ENTRYPOINT [ "/jupyter-bootstrap.sh" ]
CMD []

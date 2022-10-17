# syntax=docker/dockerfile:1.4

ARG SPARK_BASE_IMAGE

ARG SPARK_BASE_IMAGE
FROM $SPARK_BASE_IMAGE as main

# Run everything as JUPYTER_USER
ARG JUPYTER_USER=dummy
ARG JUPYTER_GROUP=dummy
ARG JUPYTER_HOME=/home/dummy

COPY scripts/jupyter-bootstrap.sh /jupyter-bootstrap.sh

WORKDIR $JUPYTER_HOME

USER root
WORKDIR $JUPYTER_HOME/.local
RUN chown -R $JUPYTER_USER:$JUPYTER_GROUP $JUPYTER_HOME/.local

ARG JUPYTER_PORT=8889
EXPOSE $JUPYTER_PORT

WORKDIR $JUPYTER_HOME
USER $JUPYTER_USER
ENV PATH "$PATH:$JUPYTER_HOME/.local/bin"

ARG SPARK_VERSION
ARG JUPYTER_VERSION
RUN python -m pip install\
 --no-cache-dir\
 --user\
 pyspark==$SPARK_VERSION\
 notebook==$JUPYTER_VERSION &&\
 find .local/lib/python*/site-packages/ -depth\
   \(\
     \( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
     -o \
     \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
   \) -exec rm -rf '{}' +;

ENTRYPOINT [ "/jupyter-bootstrap.sh" ]
CMD = []

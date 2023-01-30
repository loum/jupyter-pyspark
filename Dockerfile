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

# Run everything as JUPYTER_USER
ARG JUPYTER_USER=user
ARG JUPYTER_GROUP=user
ARG JUPYTER_HOME=/home/user

COPY scripts/jupyter-bootstrap.sh /jupyter-bootstrap.sh

WORKDIR $JUPYTER_HOME

WORKDIR $JUPYTER_HOME/.local
COPY --from=builder --chown=$JUPYTER_USER:$JUPYTER_GROUP /home/user/.local $JUPYTER_HOME/.local/

ARG JUPYTER_PORT=8889
EXPOSE $JUPYTER_PORT

WORKDIR $JUPYTER_HOME
USER $JUPYTER_USER
ENV PATH "$PATH:$JUPYTER_HOME/.local/bin"

ENTRYPOINT [ "/jupyter-bootstrap.sh" ]
CMD []

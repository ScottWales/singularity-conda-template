FROM mambaorg/micromamba

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yaml docker /tmp

RUN  /tmp/docker/conda-install.sh

FROM mambaorg/micromamba

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yaml docker /tmp

RUN  /bin/bash /tmp/conda-install.sh

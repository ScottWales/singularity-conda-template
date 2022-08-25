FROM continuumio/miniconda3

COPY conda-install.sh environment.yaml .
RUN  ls -la
RUN  conda-install.sh

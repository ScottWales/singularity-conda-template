FROM continuumio/miniconda3

COPY conda-install.sh environment.yaml .
RUN  conda-install.sh

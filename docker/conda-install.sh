#!/bin/bash

set -eu

# Runs inside the docker container to create the conda environment

micromamba install -y -n base -f /tmp/environment.yaml
micromamba clean --all --yes

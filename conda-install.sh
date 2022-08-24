#!/bin/bash

# Runs inside the docker container to create the conda environment

# Update the root environment
conda env update -n root -f environment.yml

# Clean up
conda clean --all

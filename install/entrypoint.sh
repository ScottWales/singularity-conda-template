#!/bin/bash

# Initialise Micromamba
eval "$("${MAMBA_EXE}" shell hook --shell=bash)"

# Activate environment
micromamba activate /opt/conda

# Run command
exec "$@"

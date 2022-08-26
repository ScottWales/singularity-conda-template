#!/bin/bash
#  Copyright 2022 Bureau of Meteorology
#  Author Scott Wales

set -eu
set -o pipefail

# Only use libraries inside the image
export PYTHONNOUSERSITE=1
export PYTHONPATH=""

/opt/singularity/bin/singularity exec ./image.sif "/opt/conda/bin/$(basename $0)" "$@"

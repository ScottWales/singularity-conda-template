#!/bin/bash
#  Copyright 2022 Bureau of Meteorology
#  Author Scott Wales

set -eu
set -o pipefail

# Only use libraries inside the image
# SETUP: Comment out to allow user libraries
export PYTHONNOUSERSITE=1
export PYTHONPATH=""

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

module load singularity
singularity exec --bind /half-root $SCRIPT_DIR/image.sif "$SCRIPT_DIR/entrypoint.sh" "/opt/conda/bin/$(basename $0)" "$@"

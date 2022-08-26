#!/bin/bash
#  Copyright 2022 Bureau of Meteorology
#  Author Scott Wales

set -eu
set -o pipefail

# Only use libraries inside the image
export PYTHONNOUSERSITE=1
export PYTHONPATH=""

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

/opt/singularity/bin/singularity exec --env "PATH=/opt/conda/bin:$PATH" $SCRIPT_DIR/image.sif "/opt/conda/bin/$(basename $0)" "$@"

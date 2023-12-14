#!/bin/bash
#  Copyright 2023 Bureau of Meteorology
#  Author Scott Wales

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

rm -f build.log

qsub -P $PROJECT -V -W block=true build.sh &
QID=$!

tail -F build.log --pid=$QID &

wait $QID

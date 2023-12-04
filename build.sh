#!/bin/bash
#  Copyright 2023 Bureau of Meteorology
#  Author Scott Wales

#PBS -l copyq
#PBS -l ncpus=1
#PBS -l walltime=1:00:00
#PBS -l mem=4gb
#PBS -l jobfs=20gb
#PBS -l wd

set -eu
set -o pipefail

SCRIPT_DIR=${PBS_O_WORKDIR:-$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )}

WORKDIR=${TMPDIR}/squash
mkdir -p "$WORKDIR"

PATH=/scratch/hc46/saw562/tmp/container/bom-ngm-conda/bin:$PATH

if ! [ -d $WORKDIR/mamba ]; then
    conda env create --prefix $WORKDIR/mamba --file $SCRIPT_DIR/environment.yaml
fi

if ! [ -f "$WORKDIR/conda.squashfs" ]; then
    conda pack --prefix $WORKDIR/mamba --arcroot bom-ngm/mamba --output $WORKDIR/conda.squashfs --compress-level 0
fi

cp $SCRIPT_DIR/base.sif $WORKDIR/image.sif

apptainer sif add \
    --datatype 4 \
    --partfs 1 \
    --parttype 4 \
    --partarch 2 \
    --groupid 1 \
    $WORKDIR/image.sif \
    $WORKDIR/conda.squashfs

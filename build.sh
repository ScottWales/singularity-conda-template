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

NAME=conda
VERSION=202312
COMMANDS="python conda"

WORKDIR=${TMPDIR}/squash
STAGEDIR=/scratch/$PROJECT/$USER/ngm

mkdir -p "$WORKDIR"

PATH=/scratch/hc46/saw562/tmp/container/bom-ngm-conda/bin:$PATH

# Set up the conda environment
if ! [ -d $WORKDIR/conda ]; then
    conda env create --prefix $WORKDIR/conda --file $SCRIPT_DIR/environment.yaml
fi

# Pack the conda environment into squashfs
if ! [ -f "$WORKDIR/conda.squashfs" ]; then
    conda pack --prefix $WORKDIR/conda --arcroot bom-ngm/conda --output $WORKDIR/conda.squashfs --compress-level 0
fi

# Make a copy of the base image for this container
cp $SCRIPT_DIR/base.sif $WORKDIR/image.sif

# Add in conda squashfs to this container
singularity sif add \
    --datatype 4 \
    --partfs 1 \
    --parttype 4 \
    --partarch 2 \
    --groupid 1 \
    $WORKDIR/image.sif \
    $WORKDIR/conda.squashfs

# Stage the image
mkdir -p $STAGEDIR/apps/$NAME/$VERSION/etc
cp $WORKDIR/image.sif $STAGEDIR/apps/$NAME/$VERSION/etc/$NAME-$VERSION.sif
ln -sf $NAME-$VERSION.sif $STAGEDIR/apps/$NAME/$VERSION/etc/image.sif

# Stage commands
rm -rf $STAGEDIR/apps/$NAME/$VERSION/bin
mkdir -p $STAGEDIR/apps/$NAME/$VERSION/bin
cp imagerun $STAGEDIR/apps/$NAME/$VERSION/bin
for c in $COMMANDS; do
    ln -s imagerun $STAGEDIR/apps/$NAME/$VERSION/bin/$c
done

# Stage module
mkdir -p $STAGEDIR/modules/$NAME
cat > $STAGEDIR/modules/$NAME/$VERSION <<EOF
#%Module1.0

set name "$NAME"
set version "$VERSION"
set prefix "$STAGEDIR/apps/$NAME/$VERSION"
set git "$(cd $SCRIPT_DIR; git describe --tags)"

prepend-path PATH "\$prefix/bin"
EOF

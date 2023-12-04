#!/bin/bash
#  Copyright 2023 Bureau of Meteorology
#  Author Scott Wales

#PBS -q copyq
#PBS -l ncpus=1
#PBS -l walltime=1:00:00
#PBS -l mem=4gb
#PBS -l jobfs=20gb
#PBS -l wd
#PBS -j oe
#PBS -o build.log

set -eu
set -o pipefail

SCRIPT_DIR=${PBS_O_WORKDIR:-$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )}

# Module name
NAME=conda

# Module version
VERSION=202312

# Commands to expose to the user
COMMANDS="python conda"

# Install directory
STAGEDIR=/scratch/$PROJECT/$USER/ngm

# Scratch directory
WORKDIR=${TMPDIR}/squash
mkdir -p "$WORKDIR"

# Load conda
module use /scratch/$PROJECT/$USER/ngm/modules
module load conda

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
/opt/singularity/bin/singularity sif add \
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

cat <<EOF

$NAME-$VERSION installed

Load with
    module use $STAGEDIR/modules
    module load $NAME/$VERSION

Aliases call that command in the container:

EOF

ls $STAGEDIR/apps/$NAME/$VERSION/bin

cat <<EOF

Run an arbitrary command in the container with
    imagerun CMD
EOF

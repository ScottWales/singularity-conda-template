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
#PBS -o pbs.log
#PBS -W umask=0022

set -eu
set -o pipefail

set -x

exec > build.log
exec 2>&1

SCRIPT_DIR=${PBS_O_WORKDIR:-$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )}

# Module name
: ${NAME:=$(basename $SCRIPT_DIR)}

# Module version
: ${VERSION:=$(git rev-parse --abbrev-ref HEAD)}

# Commands to expose to the user
COMMANDS="python conda"

# Install directory
STAGEDIR=/scratch/$PROJECT/$USER/ngm

# Scratch directory
WORKDIR="${TMPDIR}/squash"
mkdir -p "$WORKDIR"

# Create base
export CONDA_PKGS_DIRS=$WORKDIR/pkgs
export MAMBA_ROOT_PREFIX=$WORKDIR/micromamba

export PATH=$MAMBA_ROOT_PREFIX/bin:$WORKDIR/bin:$PATH

curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C "$WORKDIR" bin/micromamba 
micromamba create -n base -c conda-forge conda-pack squashfs-tools

# Patch conda-pack
patch --strip 1 --directory $MAMBA_ROOT_PREFIX/lib/python3.1?/site-packages/conda_pack < conda-pack-all-root.patch

# Set up the conda environment
if ! [ -d $WORKDIR/conda ]; then
    micromamba create --prefix $WORKDIR/conda --file $SCRIPT_DIR/environment.yaml
fi

# Pack the conda environment into squashfs
if ! [ -f "$WORKDIR/conda.squashfs" ]; then
    conda-pack --prefix $WORKDIR/conda --arcroot bom-ngm/conda --output $WORKDIR/conda.squashfs --compress-level 0
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

cp $WORKDIR/conda.squashfs $SCRIPT_DIR

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
set git "$(cd $SCRIPT_DIR; git describe --tags --always)"

prepend-path PATH "\$prefix/bin"
EOF

cat <<EOF
================================================================================

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

Start a shell in the container with
    imagerun shell
EOF

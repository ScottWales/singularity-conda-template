#!/bin/bash

set -eu

module purge

: ${PREFIX:=/scratch/$PROJECT/$USER/ngm}
: ${NAME:=$(basename $PWD)}

VERSION=$(git symbolic-ref --short HEAD)
REPO=$(git remote get-url origin)
SHA=$(git rev-parse HEAD)
DATE=$(date --iso-8601=minutes)

APPDIR="${PREFIX}/apps/${NAME}/${VERSION}"
MODDIR="${PREFIX}/modules/${NAME}"

echo "Installing ${NAME}/${VERSION} to ${APPDIR}"

mkdir -p "$APPDIR"
mkdir -p "$MODDIR"

# Install image
mkdir -p "$APPDIR/etc"
cp image.sif $APPDIR/etc
cp install/run-image-command.sh $APPDIR/etc

# Create bin directory and link in any binaries
mkdir -p $APPDIR/bin
rm -f $APPDIR/bin/*

# SETUP: What commands should be made available?
# All commands
COMMANDS=$(/opt/singularity/bin/singularity exec $APPDIR/etc/image.sif ls /opt/conda/bin)
# or limited commands
# COMMANDS="cylc rose rosa rosie"

for f in $COMMANDS; do
    ln -sf "../etc/run-image-command.sh" "$APPDIR/bin/$(basename $f)"
done

# Create module
sed \
    -e "s;_NAME_;${NAME};" \
    -e "s;_VERSION_;${VERSION};" \
    -e "s;_REPO_;${REPO};" \
    -e "s;_DATE_;${DATE};" \
    -e "s;_SHA_;${SHA};" \
    -e "s;_APPDIR_;${APPDIR};" \
    install/module > "${MODDIR}/${VERSION}"

cat <<EOF
Install complete

Load module with
    module use $(dirname $MODDIR)
    module load ${NAME}/${VERSION}
EOF

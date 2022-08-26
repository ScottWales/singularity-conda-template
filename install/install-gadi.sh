#!/bin/bash

set -eu

PREFIX=/scratch/$PROJECT/$USER/ngm

NAME=$(basename $PWD)
VERSION=$(git symbolic-ref --short HEAD)
REPO=$(git remote get-url origin)
SHA=$(git rev-parse HEAD)
DATE=$(date --iso-8601=minutes)

APPDIR="${PREFIX}/apps/${NAME}/${VERSION}"
MODDIR="${PREFIX}/modules/${NAME}"

mkdir -p "$APPDIR"
mkdir -p "$MODDIR"

cp image.sif $APPDIR

sed \
    -e "s;_NAME_;${NAME};" \
    -e "s;_VERSION_;${VERSION};" \
    -e "s;_REPO_;${REPO};" \
    -e "s;_DATE_;${DATE};" \
    -e "s;_APPDIR_;${APPDIR};" \
    install/module > "${MODDIR}/${VERSION}"

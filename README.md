Conda Singularity Build
=======================

Stages:

 1. docker:  
    Builds a docker image by copying environment.yaml and the docker/ directory into the container and then running docker/install-conda.sh

 2. singularity:
    Converts the docker image to a singularity image

 3. install:
    Copies the singularity image to gadi and then runs install/install-gadi.sh

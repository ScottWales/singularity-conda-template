Conda Singularity Build
=======================

Places to configure are marked with SETUP
 - Conda environment in *docker/environment.yaml*
 - What commands should be exposed in *install/install-gadi.sh*
 - Should user libraries be allowed in *install/run-user-command.sh*

Stages:

 1. docker:  
    Builds a docker image by copying the docker/ directory into the container and then running docker/install-conda.sh
    * See the **docker** directory for the environment.yaml file and files installed *inside* the image

 2. singularity:
    Converts the docker image to a singularity image

 3. install:
    Copies the singularity image to gadi and then runs install/install-gadi.sh
    * See the **install** directory for files installed *outside* the image

Demo Singularity Conda environment
==================================

General Singularity instructions
--------------------------------

Copy this repository and upload to https://gitlab.nci.org.au/bom/ngm to be able to use gitlab-ci, e.g.

    git clone git@git.nci.org.au:bom/ngm/modules/singularity-conda-template MYENV
    cd MYENV
    git push --set-upstream git@git.nci.org.au:bom/ngm/modules/MYENV master

See https://git.nci.org.au/bom/ngm/documentation/-/wikis/User-Guides/Conda-Environments for detailled instructions

Modules are installed under /g/data/access/ngm

Each git branch creates a new module version, e.g. varpytools branch 2021.03.0
creates /g/data/access/ngm/modules/varpytools/2021.03.0

Places to configure are marked with SETUP
 - Module name in *.gitlab-ci.yml*
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

The Singularity image itself is 'etc/image.slf' under the install directory.
This can be copied to other sites, the Conda environment on the image is stored
in `/opt/conda`.

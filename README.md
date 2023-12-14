# Template Singularity Conda environment

## Setup Instructions

1. Copy this repository and upload to https://gitlab.nci.org.au/bom/ngm to be able to use gitlab-ci, e.g.

    ```bash
    git clone git@git.nci.org.au:bom/ngm/modules/singularity-conda-template $MYENV
    cd $MYENV
    git push --set-upstream git@git.nci.org.au:bom/ngm/modules/$MYENV master
    ```

2. Set up `environment.yaml` with the Conda packages you wish to use

3. In `build.sh` update `COMMANDS` to the list of commands to expose to the user

## Manual Build

Build the container manually by running:
```bash
./submit.sh
```
This will submit a job on copyq, with the image available with:
```bash
module use /scratch/$PROJECT/$USER/ngm/modules
module load $NAME/$VERSION
```
Name will be by default the name of this directory, and version the current git
branch name.

## CI Build

If the repository is under https://git.nci.org.au/bom/ngm/modules then CI will
automatically build the image when the repository is updated. The module will
be available with:
```bash
module use /scratch/hc46/hc46_gitlab/ngm/modules
module load $NAME/$VERSION
```
Name will be by default the name of the repository, and version the current git
branch name.

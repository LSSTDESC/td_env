#!/bin/bash

## To Run at NERSC
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml NERSC
## Note the inclusion of NERSC parameter skips the install of jupyterlab below

## To Run at other sites
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml


source /opt/lsst/software/stack/loadLSST.bash
conda install -c conda-forge -y mamba
mamba install -c conda-forge -y coloredlogs
#pip install --root /opt/software/desc keras-tcn --no-dependencies


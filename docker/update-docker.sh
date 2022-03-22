#!/bin/bash

## To Run at NERSC
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml NERSC
## Note the inclusion of NERSC parameter skips the install of jupyterlab below

## To Run at other sites
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml


source /opt/lsst/software/stack/loadLSST.bash
conda install -c conda-forge -y mamba

# Cori offers mpich 3.3.2
mamba install -c conda-forge -y mpich=3.3.*=external_*

mamba install -c conda-forge -y --file ./packlist.txt


#!/bin/bash

## To Run at NERSC
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml NERSC
## Note the inclusion of NERSC parameter skips the install of jupyterlab below

## To Run at other sites
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml



source /cvmfs/sw.lsst.eu/linux-x86_64/lsst_distrib/w_2021_40/loadLSST.bash

pip install --root /opt/software/desc coloredlogs
#pip install --root /opt/software/desc keras-tcn --no-dependencies





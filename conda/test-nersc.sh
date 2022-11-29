#!/bin/bash

#set -eo pipefail

if [ "$NERSC_HOST" == "cori" ]
then
  module unload python
  module swap PrgEnv-intel PrgEnv-gnu
  module unload craype-network-aries
  module unload cray-libsci
  module unload craype
  module load cray-mpich-abi/7.7.19
  export LD_LIBRARY_PATH=$CRAY_MPICH_BASEDIR/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH
else
  module load PrgEnv-gnu
  module load cpu
  module load cray-mpich-abi/8.1.15
fi

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

# Set to 1 to install into the common sofware area
installFlag=$1

commonIntBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-int
commonDevBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-dev
commonProdBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod


if [ "$CI_COMMIT_REF_NAME" = "integration" ];
then
    curBuildDir=$commonIntBuildDir/$CI_PIPELINE_ID
    echo "Integration Install Build: " $curBuildDir
elif [ "$CI_COMMIT_REF_NAME" = "dev" ];
then
    curBuildDir=$commonDevBuildDir/$CI_PIPELINE_ID
    echo "Dev Install Build: " $curBuildDir
elif [[ "$installFlag" ]];
then
    if [[ -z "$CI_COMMIT_TAG" ]];
    then
        prodBuildDir=$CI_PIPELINE_ID
    else
        prodBuildDir=$CI_COMMIT_TAG
    fi
    curBuildDir=$commonProdBuildDir/$prodBuildDir
    echo "Prod Build: " $curBuildDir
fi

source $curBuildDir/setup_td_env.sh

python -c 'import lsst.daf.butler'
python -c 'import coloredlogs'


#!/bin/bash

module unload python
module swap PrgEnv-intel PrgEnv-gnu
module unload craype-network-aries
module unload cray-libsci
module unload craype
module load cray-mpich-abi/7.7.10

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

# Set to 1 to install into the common sofware area
installFlag=$1


scratchBuildDir=/global/cscratch1/sd/heatherk/td_env-devbuilds
commonDevBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-dev
commonProdBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod

if [ "$installFlag" ] && [ "$CI_COMMIT_BRANCH"="dev" ]];
then
    curBuildDir=$commonDevBuildDir/$CI_JOB_ID
    echo "Dev Install Build: " $curBuildDir
elif [[ $"installFlag" ]];
then
    if [[ -z "$CI_COMMIT_TAG" ]];
    then
        prodBuildDir=$CI_JOB_ID
    fi
    curBuildDir=$commonProdBuildDir/$prodBuildDir
    echo "Prod Build: " $curBuildDir
elif [[ -z "$installFlag" ]];
then
    curBuildDir=$scratchBuildDir/$CI_JOB_ID
    echo "Dev Scratch Build: " $curBuildDir
fi

source $curBuildDir/loadLSST.bash

export LD_LIBRARY_PATH=/opt/cray/pe/mpt/7.7.10/gni/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH

python -c 'import george'


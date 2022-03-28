#!/bin/bash

module unload python
module swap PrgEnv-intel PrgEnv-gnu
module unload craype-network-aries
module unload cray-libsci
module unload craype
module load cray-mpich-abi/7.7.10

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

dmver=$1

# Set to 1 to install into the common sofware area
installFlag=$2


scratchBuildDir=/global/cscratch1/sd/heatherk/td_env-devbuilds
commonDevBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-dev
commonProdBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod

#echo "REF_NAME " $CI_COMMIT_REF_NAME
#echo "COMMIT_BRANCH " $CI_COMMIT_BRANCH
#echo "SLUG " $CI_COMMIT_REF_SLUG

#if [ "$CI_COMMIT_REF_NAME" = "dev" ];
#then
#    echo "Found DEV"!
#fi

if [ "$installFlag" ] && [ "$CI_COMMIT_REF_NAME" = "dev" ];  # Install dev
then
    curBuildDir=$commonDevBuildDir/$CI_PIPELINE_ID
    echo "Dev Install Build: " $curBuildDir
elif [[ "$installFlag" ]];  # Install Prod
then
    if [[ -z "$CI_COMMIT_TAG" ]];
    then
        prodBuildDir=$CI_PIPELINE_ID
    fi
    curBuildDir=$commonProdBuildDir/$prodBuildDir
    echo "Prod Build: " $curBuildDir
elif [[ -z "$installFlag" ]];   # Build dev on SCRATCH
then
    curBuildDir=$scratchBuildDir/$CI_PIPELINE_ID
    echo "Dev Scratch Build: " $curBuildDir
fi

mkdir -p $curBuildDir
cp conda/packlist.txt $curBuildDir
cp conda/piplist.txt $curBuildDir
cp nersc/setup_td_env.sh $curBuildDir
sed -i 's|$1|'$curBuildDir'|g' $curBuildDir/setup_td_env.sh
cd $curBuildDir


# Build Steps
curl -LO https://ls.st/lsstinstall

bash ./lsstinstall -T $1 -e (lsst-scipipe-$1)

source ./loadLSST.bash
eups distrib install -t $1 lsst_distrib

mamba install -c conda-forge -y mpich=3.3.*=external_*

export LD_LIBRARY_PATH=/opt/cray/pe/mpt/7.7.10/gni/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH

mamba install -c conda-forge -y --file ./packlist.txt
pip install -r ./piplist.txt

# Set permissions
setfacl -R -m group:lsst:rx $curBuildDir
setfacl -R -m user:desc:rwx $curBuildDir


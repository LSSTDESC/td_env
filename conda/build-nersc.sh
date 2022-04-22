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
#installFlag=$2


commonDevBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-dev
commonProdBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod

if [ "$CI_COMMIT_REF_NAME" = "dev" ];  # dev
then
    curBuildDir=$commonDevBuildDir/$CI_PIPELINE_ID
    echo "Dev Install Build: " $curBuildDir
elif [[ -z "$CI_COMMIT_TAG" ]];  # Not a tagged build, use dev area
then
    curBuildDir=$commonDevBuildDir/$CI_PIPELINE_ID
    echo "Dev Install Build: " $curBuildDir
else    # Tagged Release, build in production area
    curBuildDir=$commonProdBuildDir/$CI_COMMIT_TAG-$CI_PIPELINE_ID
    echo "Prod Build: " $curBuildDir
fi

mkdir -p $curBuildDir
cp conda/packlist.txt $curBuildDir
cp conda/piplist.txt $curBuildDir
cp nersc/setup_td_env.sh $curBuildDir
cp nersc/sitecustomize.py $curBuildDir
sed -i 's|$1|'$curBuildDir'|g' $curBuildDir/setup_td_env.sh
cd $curBuildDir


# Build Steps
curl -LO https://ls.st/lsstinstall
#export LSST_CONDA_ENV_NAME=lsst-scipipe-$1
bash ./lsstinstall -X $1 

source ./loadLSST.bash
eups distrib install -t $1 lsst_distrib

mamba install -c conda-forge -y mpich=3.3.*=external_*

export LD_LIBRARY_PATH=/opt/cray/pe/mpt/7.7.10/gni/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH

mamba install -c conda-forge -y --file ./packlist.txt
pip install --no-cache-dir -r ./piplist.txt

conda clean -y -a 

python -m compileall $curBuildDir

# Skipping this for now - they files are downloaded to the user's astropy cache
# Will revisit if it becomes an issue: https://docs.astropy.org/en/stable/utils/data.html
# Force data files to be dowloaded during installation
# python -c "import ligo.em_bright"

conda config --set env_prompt "(lsst-scipipe-$1)" --system

conda env export --no-builds > $curBuildDir/td_env-nersc-$CI_PIPELINE_ID-nobuildinfo.yml
conda env export > $curBuildDir/td_env-nersc-$CI_PIPELINE_ID.yml


# Set permissions
setfacl -R -m group::rx $curBuildDir
setfacl -R -d -m group::rx $curBuildDir

setfacl -R -m user:desc:rwx $curBuildDir
setfacl -R -d -m user:desc:rwx $curBuildDir



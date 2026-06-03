#!/bin/bash

module load gpu

unset PYTHONPATH

# Set to 1 to install into the common sofware area
#installFlag=$3

export BUILD_ID_DATE=`echo "$(date "+%F-%M-%S")"`

export CI_COMMIT_REF_NAME=dev
export CI_PIPELINE_ID=$BUILD_ID_DATE

snnBuildDir=$CFS/lsst/groups/TD/SOFTWARE/snn/snn-dev

if [ "$CI_COMMIT_REF_NAME" = "integration" ];  # integration
then
    curBuildDir=$commonIntBuildDir/$CI_PIPELINE_ID
    echo "Integration Install Build: " $curBuildDir
elif [ "$CI_COMMIT_REF_NAME" = "dev" ];  # dev
then
    curBuildDir=$snnBuildDir/$BUILD_ID_DATE
    echo "Dev Install Build: " $curBuildDir
elif [[ "$installFlag" ]];  # Install Prod
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

mkdir -p $curBuildDir
cd $curBuildDir

export PYTHONNOUSERSITE=1
export CONDA_CACHE_DIR=$curBuildDir/py/pkgs

echo $pwd


# Build Steps
#
# Need to install Mambaforge first
curl -LO https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh
bash ./Miniforge3-Linux-x86_64.sh -b -p $curBuildDir/py
source $curBuildDir/py/bin/activate base

python -m pip cache purge
export CONDA_CACHE_DIR=$curBuildDir/py/pkgs

git clone https://github.com/supernnova/supernnova.git
cd supernnova
conda env create -f env/conda_gpu_env.yml
conda activate supernnova-cuda
poetry install

conda clean -y -a 


conda env config vars set PYTHONNOUSERSITE=1

#conda config --set env_prompt "(desc-snn-$2)" --env

conda env export --no-builds > $curBuildDir/snn-dev-nersc-$CI_PIPELINE_ID-nobuildinfo.yml
conda env export > $curBuildDir/snn-dev-nersc-$CI_PIPELINE_ID.yml

unlink $snnBuildDir/dev
ln -s $curBuildDir $snnBuildDir/dev


# Set permissions
#setfacl -R -m group::rx $curBuildDir
#setfacl -R -d -m group::rx $curBuildDir

#setfacl -R -m user:desc:rwx $curBuildDir
#setfacl -R -d -m user:desc:rwx $curBuildDir



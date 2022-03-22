#!/bin/bash

linkName=$1

scratchBuildDir=/global/cscratch1/sd/heatherk/td_env-devbuilds
commonDevBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-dev
commonProdBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod

if [ "$CI_COMMIT_REF_NAME" = "dev" ];
then
    curBuildDir=$commonDevBuildDir/$CI_PIPELINE_ID
    echo "Dev Install Build: " $curBuildDir
else 
    if [[ -z "$CI_COMMIT_TAG" ]];
    then
        prodBuildDir=$CI_PIPELINE_ID
    fi
    curBuildDir=$commonProdBuildDir/$prodBuildDir
    echo "Prod Build: " $curBuildDir
fi

cd $curBuildDir/../
unlink $linkName
ln -s $curBuildDir $linkName



#!/bin/bash

set -o pipefail
set -e

if [ -z "$1" ]
then
  echo "Please provide an installation directory"
  exit 1
fi

if [ -z "$2" ]
then
  export CONDA_LOCK_INSTALL_DIR=/pbs/throng/lsst/users/hkelly/installation/bin
else
  export CONDA_LOCK_INSTALL_DIR=$2
fi

if [ "$NERSC_HOST" ]
then
  module unload python
  module unload cray-libsci
  module load cray-mpich-abi/8.1.30
else
  export PATH=$CONDA_LOCK_INSTALL_DIR:$PATH
fi

unset PYTHONPATH

setup_conda() {
    source $curBuildDir/py/bin/activate
}

config_cosmosis() {
   source ${CONDA_PREFIX}/bin/cosmosis-configure
}

export BUILD_ID_DATE=`echo "$(date "+%F-%M-%S")"`

curBuildDir=$1/$BUILD_ID_DATE
echo "Install Directory: " $curBuildDir

mkdir -p $curBuildDir
# Set permissions
chgrp lsst $curBuildDir
chmod g+rx $curBuildDir
if [ "$NERSC_HOST" ]
then
  setfacl -R -m user:desc:rwx $curBuildDir
  setfacl -R -d -m user:desc:rwx $curBuildDir
  setfacl -R -m user:desctd:rwx $curBuildDir
  setfacl -R -d -m user:desctd:rwx $curBuildDir
  setfacl -R -d -m group::rx $curBuildDir
fi

if [ "$NERSC_HOST" ]
then
  cp nersc/sitecustomize.py $curBuildDir
  cp nersc/setup_td_env.sh $curBuildDir
  sed -i 's|$1|'$curBuildDir'|g' $curBuildDir/setup_td_env.sh
fi

cp conda/td_env-lock.yml $curBuildDir
cp conda/pip.config $curBuildDir
mkdir $curBuildDir/extra
cp conda/update_package_setup.sh $curBuildDir/extra
cd $curBuildDir


# Build Steps
export PYTHONNOUSERSITE=1
export CONDA_PKGS_DIRS=$curBuildDir/pkgs

url="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
curl -LO "$url"

bash ./Miniforge3-Linux-x86_64.sh -b -p $curBuildDir/py
setup_conda
conda activate base

export PIP_CONFIG_FILE=$curBuildDir/pip.config
pip config -v list

conda-lock install --mamba -n td_env td_env-lock.yml

conda activate td_env

conda env config vars set CSL_DIR=${CONDA_PREFIX}/cosmosis-standard-library
cd ${CONDA_PREFIX}
config_cosmosis
cosmosis-build-standard-library main
cd $curBuildDir

echo "Set up cosmosis"

echo "Cleaning"


conda clean -y -a 

#conda config --set env_prompt "(desc-py)" --env

cd $curBuildDir
echo "Setting up copy of firecrown"
firecrown_ver=$(conda list firecrown | grep firecrown|tr -s " " | cut -d " " -f 2)
echo $firecrown_ver
curl -LO https://github.com/LSSTDESC/firecrown/archive/refs/tags/v$firecrown_ver.tar.gz
tar xvzf v$firecrown_ver.tar.gz
# Set up a common directory name without version info to set FIRECROWN_DIR more easily
ln -s firecrown-$firecrown_ver firecrown

conda env export --no-builds > $curBuildDir/desc-python-nersc-$CI_PIPELINE_ID-nobuildinfo.yml
conda env export > $curBuildDir/desc-python-nersc-$CI_PIPELINE_ID.yml


python -m compileall $curBuildDir/py/envs/desc-python
echo "Done compiling"

#!/bin/bash

isloaded="$(module list |& grep python)"
if [[ "$isloaded" ]];
then
  module unload python
fi

isloaded="$(module list |& grep PrgEnv-intel)"
if [[ "$isloaded" ]];
then
  module swap PrgEnv-intel PrgEnv-gnu
else
  module load PrgEnv-gnu
fi

isloaded="$(module list |& grep craype-network-aries)"
if [[ "$isloaded" ]];
then
  module unload craype-network-aries
fi

isloaded="$(module list |& grep cray-libsci)"
if [[ "$isloaded" ]];
then
  module unload cray-libsci
fi

isloaded="$(module list |& grep craype)"
if [[ "$isloaded" ]];
then
  module unload craype
fi

module load cray-mpich-abi/7.7.10

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

export LD_LIBRARY_PATH=$CRAY_MPICH_BASEDIR/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH

export DESC_LSST_INSTALL_DIR=$1

curshell=$(echo $0)
if [ $curshell = bash ];
then
  source $DESC_LSST_INSTALL_DIR/loadLSST.bash
else
  source $DESC_LSST_INSTALL_DIR/loadLSST.zsh
fi
setup lsst_distrib

# Add env var to point to bayeSN install
export BAYESN_INSTALL=$DESC_LSST_INSTALL/bayesn-public

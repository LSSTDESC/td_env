#!/bin/bash

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
  module load cray-mpich-abi/8.1.22
fi

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

export DESC_LSST_INSTALL_DIR=$1

curshell=$(echo $0)
if [ $curshell = bash ];
then
  source $DESC_LSST_INSTALL_DIR/loadLSST.bash
else
  source $DESC_LSST_INSTALL_DIR/loadLSST.zsh
fi
setup lsst_distrib

# For cosmosis and firecrown.  Should try to find a better way to set these
export CSL_DIR=$CONDA_PREFIX/lib/python3.8/site-packages/cosmosis/cosmosis-standard-library
export FIRECROWN_SITE_PACKAGES=$CONDA_PREFIX/lib/python3.8/site-packages
export FIRECROWN_DIR=$DESC_LSST_INSTALL_DIR/firecrown
export FIRECROWN_EXAMPLES_DIR=$FIRECROWN_DIR/examples

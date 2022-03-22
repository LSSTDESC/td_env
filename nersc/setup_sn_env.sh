#!/bin/bash

module unload python
module swap PrgEnv-intel PrgEnv-gnu
module unload craype-network-aries
module unload cray-libsci
module unload craype
module load cray-mpich-abi/7.7.10

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

export LD_LIBRARY_PATH=$CRAY_MPICH_BASEDIR/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH

export DESC_LSST_INSTALL_DIR=$1
source $DESC_LSST_INSTALL_DIR/loadLSST.bash
setup lsst_distrib

#!/bin/bash

module load PrgEnv-gnu
module load cpu
module load cray-mpich-abi
module load evp-patch

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
export CSL_DIR=$CONDA_PREFIX/lib/python3.10/site-packages/cosmosis/cosmosis-standard-library
export FIRECROWN_SITE_PACKAGES=$CONDA_PREFIX/lib/python3.10/site-packages
export FIRECROWN_DIR=$DESC_LSST_INSTALL_DIR/firecrown
export FIRECROWN_EXAMPLES_DIR=$FIRECROWN_DIR/examples
export TD_ASTRODASH_DIR=$CONDA_PREFIX/lib/python3.10/site-packages/astrodash


# Fixes missing support in the Perlmutter libfabric:
# https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#missing-support-for-matched-proberecv
export MPI4PY_RC_RECV_MPROBE=0

# Tries to prevent cosmosis from launching any subprocesses, since that is 
# not allowed on Perlmutter.
export COSMOSIS_NO_SUBPROCESS=1


#!/bin/bash

module load PrgEnv-gnu
module load cpu
module load cray-mpich-abi/8.1.30
#module load mpich/4.3.0

unset PYTHONPATH

export DESC_LSST_INSTALL_DIR=$1

setupconda() {
    source $DESC_LSST_INSTALL_DIR/py/bin/activate
    conda activate td_env
}

setupconda

# For cosmosis and firecrown.  Should try to find a better way to set these
#export CSL_DIR=$CONDA_PREFIX/lib/python3.12/site-packages/cosmosis/cosmosis-standard-library
export FIRECROWN_SITE_PACKAGES=$CONDA_PREFIX/lib/python3.12/site-packages
export FIRECROWN_DIR=$DESC_LSST_INSTALL_DIR/firecrown
export FIRECROWN_EXAMPLES_DIR=$FIRECROWN_DIR/examples
export TD_ASTRODASH_DIR=$CONDA_PREFIX/lib/python3.12/site-packages/astrodash


# Fixes missing support in the Perlmutter libfabric:
# https://docs.nersc.gov/development/languages/python/using-python-perlmutter/#missing-support-for-matched-proberecv
export MPI4PY_RC_RECV_MPROBE=0

# Tries to prevent cosmosis from launching any subprocesses, since that is 
# not allowed on Perlmutter.
export COSMOSIS_NO_SUBPROCESS=1


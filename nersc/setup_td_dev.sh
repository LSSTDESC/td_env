#!/bin/bash

# Nov 1 2022: HMK check NERSC_HOST
# Feb 19 2022: HK Use native install of LSST Sci Pipelines at NERSC
# Jan 27 2022: HK update to optionally setup LSST Sci Pipelines
# Mar 05 2021: define few things for CosmoMC (installed by Vivian)
# Feb 22 2021: R.Kessler - update & add ENVs for SNANA
# Aug 14 2020: load cfitsio & gsl
# Apr 25 2020: load root
# Feb 2020: install SNANA on Cori
#

wrapcosmosis() {
    source cosmosis-configure
}

echo "RUNNING TD_ENV DEVELOPMENT VERSION"

#SCRIPT=${BASH_SOURCE[0]}

#usage() {  # Function: Print a help message.
#  echo "-c  --Setup cosmosis."
#  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}"\\n
#  echo "Command line switches are optional. The following switches are recognized."
#  echo "-k  --Setup the env without doing module purge."
#  echo "-n  --Setup the env without the LSST Sci Pipelines."
#  echo "-s  --Setup the env for shifter."
#  exit 0
#}


# optional parameters
# -h help
# -n Do not setup the LSST Sci Pipelines
#while getopts e:n: flag
while getopts "chkns" flag
do
    case "${flag}" in
	c) cosmosis=1;;
        h) usage;;
        k) keepenv=1;;
        n) nolsst=1;;
        s) shifterenv=1;;
    esac
done

# Check to see if this setup script has already been run in this shell
#if [ $TD ]
#then
#    echo "td_env is already set up"
#    return 0
#fi

export TD=/global/cfs/cdirs/lsst/groups/TD
export TD_ALERTS=${TD}/ALERTS
export TD_DIA=${TD}/DIA
export TD_SL=${TD}/SL
export TD_SN=${TD}/SN
export TD_SOFTWARE=${TD}/SOFTWARE
export TD_PUBLIC=/global/cfs/cdirs/lsst/www/DESC_TD_PUBLIC

export PYSYN_CDBS=${TD_SOFTWARE}/bayeSN/synphot/grp/redcat/trds

export VERSION_LIBPYTHON=3.10


if [[ -z "$keepenv" ]] && [[ -z $SHIFTER_RUNTIME ]];
then
  module purge
fi

# setup without LSST Science Pipelines
# Broken since March 2022 Cori OS Upgrade
if [[ $nolsst ]];
then
  module unload python
  module unload PrgEnv-intel/6.0.5
  module load PrgEnv-gnu/6.0.5
  module swap gcc gcc/9.3.0
  module rm craype-network-aries
  module rm cray-libsci
  module unload craype
  module load cfitsio/3.47
  module load gsl
  module load root/6.18.00-py3
  module load intel/19.1.3.304  # for CosmoMC (Mar 5 2021)
  export CC=gcc

  export COSMOMC_DIR="$SN_GROUP/CosmoMCBBC"
  export PATH=$PATH:${COSMOMC_DIR}

  # Set up SN python
  export LSST_INST_DIR=/global/common/software/lsst/common/miniconda
  export SN_PYTHON_VER=sn-py
  module unload python
  unset PYTHONHOME
  unset PYTHONPATH
  export PYTHONNOUSERSITE=' '

  # Just in case GCRCatalogs is installed
  export DESC_GCR_SITE='nersc'

  source $LSST_INST_DIR/$SN_PYTHON_VER/etc/profile.d/conda.sh
  conda activate root
  OUTPUTPY="$(which python)"
  echo Now using "${OUTPUTPY}"

  # Aug 24 2020 RK - silly hack for CFITSIO
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CFITSIO_DIR/lib

elif [ $shifterenv ] || [ $SHIFTER_RUNTIME ]
then
  unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH
  # SHIFTER LSST Sci Pipelines env does not have the "-exact" suffice, while local NERSC builds do (mystery)
  export LSST_CONDA_ENV_NAME=lsst-scipipe-4.1.0
  source /opt/lsst/software/stack/loadLSST.bash
  setup lsst_distrib
  
  # For cosmosis and firecrown.  Should try to find a better way to set these
  export CSL_DIR=$CONDA_PREFIX/lib/python3.10/site-packages/cosmosis/cosmosis-standard-library
  export FIRECROWN_SITE_PACKAGES=$CONDA_PREFIX/lib/python3.10/site-packages
  export FIRECROWN_DIR=/opt/lsst/software/stack/firecrown
  export FIRECROWN_EXAMPLES_DIR=$FIRECROWN_DIR/examples

  # Fixes missing support in the Perlmutter libfabric:
  # https://docs.nersc.gov/development/languages/python/using-python-perlmutter/  #missing-support-for-matched-proberecv
  export MPI4PY_RC_RECV_MPROBE=0

  # Tries to prevent cosmosis from launching any subprocesses, since that is
  # not allowed on Perlmutter.
  export COSMOSIS_NO_SUBPROCESS=1

#
# Setup with LSST Science Pipelines
elif [ -z "$nolsst" ]
then
  echo "Setting up TD env with LSST Science Pipelines"
  
  #export DESC_TD_INSTALL=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod/stable
  export DESC_TD_INSTALL=/global/common/software/lsst/gitlab/td_env-dev/dev
  source $DESC_TD_INSTALL/setup_td_env.sh
    
  export GSL_DIR=$DESC_TD_INSTALL/conda/envs/$LSST_CONDA_ENV_NAME
  export CFITSIO_DIR=$DESC_TD_INSTALL/conda/envs/$LSST_CONDA_ENV_NAME
  export YAML_DIR=$DESC_TD_INSTALL/conda/envs/$LSST_CONDA_ENV_NAME
  export ROOT_DIR=$ROOTSYS

  export PYTHONPATH=$PYTHONPATH:$DESC_TD_INSTALL
  
  # SLURM_JOB_ID is set only on compute nodes
  # DESC_TD_KEEP_MPI will be user-controlled way to keep MPI set up 
  #if [[ -z "$DESC_TD_KEEP_MPI" && -z "$SLURM_JOB_ID" ]];
  #then
  #    export PYTHONSTARTUP=$DESC_TD_INSTALL/nompi4py.py
  #fi

fi

# DIA Environment Variables


# SL Environment Variables


# SN Environment Variables
export SNANA_DIR="$TD_SOFTWARE/SNANA"
export PYTHONPATH=$PYTHONPATH:$SNANA_DIR/src

export SNDATA_ROOT="$TD_SN/SNANA/SNDATA_ROOT"
export SNANA_TESTS="$TD_SN/SNANA/SNANA_TESTS"
export SNANA_SURVEYS="$TD_SN/SNANA/SURVEYS"

export SNANA_LSST_ROOT="$SNANA_SURVEYS/LSST/ROOT"
export SNANA_LSST_USERS="$SNANA_SURVEYS/LSST/USERS"
case $NERSC_HOST in
    "perlmutter")
        : # settings for Perlmutter
        export SNANA_SCRATCH="/pscratch/sd/d/desctd"
        ;;
    "cori")
        : # settings for Cori
        export SNANA_SCRATCH="/global/cscratch1/sd/kessler"
        ;;
esac

if [[ "$cosmosis" ]];
then
  wrapcosmosis
fi


export SNANA_LSST_SIM="$SNANA_SCRATCH/SNANA_LSST_SIM"

export SCRATCH_SIMDIR="$SNANA_LSST_SIM"
export SNANA_ZTF_SIM="$SNANA_SCRATCH/SNANA_ZTF_SIM"
export DES_ROOT="$SNANA_SURVEYS/DES/ROOT"
export PLASTICC_ROOT="$SNANA_SURVEYS/LSST/ROOT/PLASTICC"
export ELASTICC_ROOT="$SNANA_SURVEYS/LSST/ROOT/ELASTICC"
export PLASTICC_MODELS="$PLASTICC_ROOT/model_libs"
export PIPPIN_OUTPUT="$SNANA_SCRATCH/PIPPIN_OUTPUT"
export PIPPIN_DIR="$TD_SOFTWARE/Pippin"
export SBATCH_TEMPLATES="$SNANA_LSST_ROOT/SBATCH_TEMPLATES"
export SNANA_DEBUG="$SNANA_LSST_USERS/kessler/debug"
export SNANA_SETUP_COMMAND="source $TD/setup_td_dev.sh"
export TD_SETUP_COMMAND=$SNANA_SETUP_COMMAND
export SNANA_IMAGE_DOCKER="lsstdesc/td-env:dev"

# Add env var to point to bayeSN install
export BAYESN_INSTALL=$DESC_TD_INSTALL/bayesn-public


export PATH=$PATH:${SNANA_DIR}/bin:${SNANA_DIR}/util:${PIPPIN_DIR}


# For GCRCatalogs
export DESC_GCR_SITE='nersc'

export HDF5_USE_FILE_LOCKING=FALSE


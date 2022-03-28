
# Feb 19 2022: HK Use native install of LSST Sci Pipelines at NERSC
# Jan 27 2022: HK update to optionally setup LSST Sci Pipelines
# Mar 05 2021: define few things for CosmoMC (installed by Vivian)
# Feb 22 2021: R.Kessler - update & add ENVs for SNANA
# Aug 14 2020: load cfitsio & gsl
# Apr 25 2020: load root
# Feb 2020: install SNANA on Cori
#

SCRIPT=`basename ${BASH_SOURCE[0]}`

usage() {  # Function: Print a help message.
  echo -e \\n"Help documentation for ${BOLD}${SCRIPT}"\\n
  echo "Command line switches are optional. The following switches are recognized."
  echo "-n  --Setup the env without the LSST Sci Pipelines."
  exit 0
}


# optional parameters
# -h help
# -n Do not setup the LSST Sci Pipelines
#while getopts e:n: flag
while getopts "hn" flag
do
    case "${flag}" in
        h) usage;;
        n) nolsst=1;;
    esac
done


export TD=/global/cfs/cdirs/lsst/groups/TD
export TD_ALERTS=${TD}/ALERTS
export TD_DIA=${TD}/DIA
export TD_SL=${TD}/SL
export TD_SN=${TD}/SN
export TD_SOFTWARE=${TD}/SOFTWARE


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

# Setup with LSST Science Pipelines
elif [ -z "$nolsst" ]
then
  echo "Setting up TD env with LSST Science Pipelines"


  source /global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod/stable/setup_td_env.sh
  export GSL_DIR=$CONDA_PREFIX
  export CFITSIO_DIR=$CONDA_PREFIX

fi

# DIA Environment Variables


# SL Environment Variables


# SN Environment Variables
export SNANA_DIR="$TD_SOFTWARE/SNANA"

export SNDATA_ROOT="$TD_SN/SNANA/SNDATA_ROOT"
export SNANA_TESTS="$TD_SN/SNANA/SNANA_TESTS"
export SNANA_SURVEYS="$TD_SN/SNANA/SURVEYS"

export SNANA_LSST_ROOT="$SNANA_SURVEYS/LSST/ROOT"
export SNANA_LSST_USERS="$SNANA_SURVEYS/LSST/USERS"
export SNANA_LSST_SIM="/global/cscratch1/sd/kessler/SNANA_LSST_SIM"

export SCRATCH_SIMDIR="/global/cscratch1/sd/kessler/SNANA_LSST_SIM"
export SNANA_ZTF_SIM="/global/cscratch1/sd/kessler/SNANA_ZTF_SIM"
export DES_ROOT="$SNANA_SURVEYS/DES/ROOT"
export PLASTICC_ROOT="$SNANA_SURVEYS/LSST/ROOT/PLASTICC"
export ELASTICC_ROOT="$SNANA_SURVEYS/LSST/ROOT/ELASTICC"
export PLASTICC_MODELS="$PLASTICC_ROOT/model_libs"
export PIPPIN_OUTPUT="/global/cscratch1/sd/kessler/PIPPIN_OUTPUT"
export PIPPIN_DIR="$TD_SOFTWARE/Pippin"
export SBATCH_TEMPLATES="$SNANA_LSST_ROOT/SBATCH_TEMPLATES"
export SNANA_DEBUG="$SNANA_LSST_USERS/kessler/debug"

export PATH=$PATH:${SNANA_DIR}/bin:${SNANA_DIR}/util:${PIPPIN_DIR}


# For GCRCatalogs
export DESC_GCR_SITE='nersc'

export HDF5_USE_FILE_LOCKING=FALSE

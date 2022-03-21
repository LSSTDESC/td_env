
# Feb 19 2022: HK Use native install of LSST Sci Pipelines at NERSC
# Jan 27 2022: HK update to optionally setup LSST Sci Pipelines
# Mar 05 2021: define few things for CosmoMC (installed by Vivian)
# Feb 22 2021: R.Kessler - update & add ENVs for SNANA
# Aug 14 2020: load cfitsio & gsl
# Apr 25 2020: load root
# Feb 2020: install SNANA on Cori
#

shopt -s nocasematch

export SN_GROUP='/global/cfs/cdirs/lsst/groups/SN'

# setup without LSST Science Pipelines
if [[ "$1" == "nolsst" ]];
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
elif [ -z "$1" ] 
then
  echo "Setting up SN env with LSST Science Pipelines"


  source /global/common/software/lsst/cori-haswell-gcc/stack/v23.0.0/setup_sn_env.sh
  export GSL_DIR=$CONDA_PREFIX
  export CFITSIO_DIR=$CONDA_PREFIX

else
  echo $1 "is an invalid option, please provide no parameters or use lsst to set up the LSST Science Pipelines"
fi


# Set up for all cases

export SNANA_DIR="$SN_GROUP/snana/SNANA"   

export SNDATA_ROOT="$SN_GROUP/snana/SNDATA_ROOT"
export SNANA_TESTS="$SN_GROUP/snana/SNANA_TESTS"
export SNANA_SURVEYS="$SN_GROUP/snana/SURVEYS"
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
export PIPPIN_DIR="$SN_GROUP/Pippin"
export SBATCH_TEMPLATES="$SNANA_LSST_ROOT/SBATCH_TEMPLATES"
export SNANA_DEBUG="$SNANA_LSST_USERS/kessler/debug"

export PATH=$PATH:${SNANA_DIR}/bin:${SNANA_DIR}/util:${PIPPIN_DIR}

export HDF5_USE_FILE_LOCKING=FALSE
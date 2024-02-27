#!/bin/sh

if [ -z "$1" ]
then	
	echo "Please provide a full path install directory"
	exit 1
fi

DESC_TD_ENV_GPU_INSTALL_DIR=$1

setup_conda() {
  source $DESC_TD_ENV_GPU_INSTALL_DIR/etc/profile.d/conda.sh
  conda activate base
}

unset PYTHONPATH

export PYTHONDONTWRITEBYTECODE=1

# Try Mambaforge latest
url="https://github.com/conda-forge/miniforge/releases/latest/download"
url="$url/Mambaforge-Linux-x86_64.sh"
curl -LO "$url"

bash ./Mambaforge-Linux-x86_64.sh -b -p $DESC_TD_ENV_GPU_INSTALL_DIR
which python
#export PATH=$1/bin:$PATH
echo $DESC_TD_ENV_GPU_INSTALL_DIR
setup_conda
mamba install -c conda-forge -y mpich=4.1.2.*=external_*
which python
which conda
mamba install -c conda-forge -y --file $2
pip install --no-cache-dir -r $3 

conda clean -y -a 

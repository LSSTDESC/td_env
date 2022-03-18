#!/bin/sh

## To Run at NERSC
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml NERSC
## Note the inclusion of NERSC parameter skips the install of jupyterlab below

## To Run at other sites
## bash install-sn-env.sh <pathToExistingCondaInstall> ./sn-env-nersc-nobuildinfo.yml

if [ -z "$1" ]
then	
	echo "Please provide a full path install directory"
	exit 1
fi

unset PYTHONPATH

curl -LO https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh

bash ./Miniconda3-4.7.12.1-Linux-x86_64.sh -b -p $1
which python
export PATH=$1/bin:$PATH
which python

conda env create -n sn-env -f $2

source $1/etc/profile.d/conda.sh
conda activate sn-env
pip install keras-tcn --no-dependencies

# Install jupyterlab at CC
if [[ -z $3 ]]
then	
  pip install jupyterlab
fi

conda clean --all




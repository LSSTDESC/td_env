#!/bin/bash

#if [ "$NERSC_HOST" == "perlmutter" ]
#module load PrgEnv-gnu
#module load cpu
module load gpu
module load cray-mpich/8.1.25
module load evp-patch
#fi

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

curBuildDir=$1

cd $curBuildDir


# Build Steps

export PYTHONNOUSERSITE=1

source $curBuildDir/conda/etc/profile.d/conda.sh
conda create -y --name td-gpu python=3.10

conda activate td-gpu

mamba install -y jaxlib=*=*cuda* jax cuda-nvcc -c conda-forge -c nvidia
# Install pytorch was 11.7, trying 11.8
mamba install -y  pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
mamba install -c conda-forge -y --file ./condalist_gpu.txt
# Install mpi4py
#MPICC="cc -shared" pip install --force --no-cache-dir --no-binary=mpi4py mpi4py
pip install --no-cache-dir -r ./piplist_gpu.txt

#install bayeSN
git clone https://github.com/bayesn/bayesn.git
cd bayesn
python3 -m pip install --no-deps --no-cache-dir .

conda clean -y -a 

conda env config vars set PYTHONNOUSERSITE=1

#python -m compileall $curBuildDir

conda config --set env_prompt "({name})" --env

conda env export --no-builds > $curBuildDir/td_env-nersc-gpu-nobuildinfo.yml
conda env export > $curBuildDir/td_env-nersc-gpu.yml


# Set permissions
setfacl -R -m group::rx $curBuildDir
setfacl -R -d -m group::rx $curBuildDir

setfacl -R -m user:desc:rwx $curBuildDir
setfacl -R -d -m user:desc:rwx $curBuildDir



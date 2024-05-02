#!/bin/bash

#if [ "$NERSC_HOST" == "perlmutter" ]
#module load PrgEnv-gnu
#module load cpu
module load gpu
module load cray-mpich/8.1.28
module load evp-patch
#fi

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

curBuildDir=$1

cd $curBuildDir


# Build Steps

export PYTHONNOUSERSITE=1

source $curBuildDir/conda/etc/profile.d/conda.sh
conda create -y --name td-gpu python=3.11

conda activate td-gpu

CONDA_OVERRIDE_CUDA="11.8" mamba install -y "tensorflow==2.14.0=cuda118*" -c conda-forge
mamba install -y  pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
#mamba install -y jaxlib=*=*cuda* jax cuda-nvcc -c conda-forge -c nvidia
mamba install -c conda-forge -y --file ./condalist_gpu.txt
#
#
# Install mpi4py
#MPICC="cc -shared" pip install --force --no-cache-dir --no-binary=mpi4py mpi4py
# Using pip install for jax until I can sort out issue installing alongside 
# tensorflow using conda-forge
#
pip install --upgrade "jax[cuda11_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

pip install --no-cache-dir -r ./piplist_gpu.txt

#install bayeSN
#git clone https://github.com/bayesn/bayesn.git
# install v0.3.2 version
curl -LO https://github.com/bayesn/bayesn/archive/refs/tags/v0.3.2.tar.gz
tar xzf v0.3.2.tar.gz
ln -s bayesn-0.3.2 bayesn
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



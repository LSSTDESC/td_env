#!/bin/bash

cd /opt/lsst/software/stack
#source /opt/lsst/software/stack/loadLSST.bash
#source /opt/lsst/software/stack/conda/current/etc/profile.d/conda.sh
source /opt/lsst/software/stack/conda/current/bin/activate
conda create -y --name td-gpu python=3.11

conda activate td-gpu

CONDA_OVERRIDE_CUDA="11.8" mamba install -y "tensorflow==2.14.0=cuda118*" -c conda-forge
mamba install -y  pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
#mamba install -y jaxlib=*=*cuda* jax cuda-nvcc -c conda-forge -c nvidia
mamba install -c conda-forge -y --file ./condalist_gpu.txt
pip install --upgrade "jax[cuda11_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

pip install --no-cache-dir -r ./piplist_gpu.txt

#install bayeSN
git clone https://github.com/bayesn/bayesn.git
cd bayesn
python3 -m pip install --no-deps --no-cache-dir .

conda clean -y -a 

conda env config vars set PYTHONNOUSERSITE=1

conda config --set env_prompt "({name})" --env

conda env export --no-builds > /opt/lsst/software/stack/td_env-nersc-gpu-nobuildinfo.yml
conda env export > /opt/lsst/software/stack/td_env-nersc-gpu.yml

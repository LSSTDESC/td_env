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
  conda create -y --name td-gpu python=3.11
  conda activate td-gpu
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
CONDA_OVERRIDE_CUDA="11.8" mamba install -y "tensorflow==2.14.0=cuda118*" -c conda-forge
mamba install -y  pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia
mamba install -c conda-forge -y --file $2
pip install --upgrade "jax[cuda11_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html
pip install --no-cache-dir -r $3 

cd $DESC_TD_ENV_GPU_INSTALL_DIR
curl -LO https://github.com/bayesn/bayesn/archive/refs/tags/v0.3.1.tar.gz
tar xzf v0.3.1.tar.gz
ln -s bayesn-0.3.1 bayesn
cd bayesn
python3 -m pip install --no-deps --no-cache-dir .

conda clean -y -a 

conda config --set env_prompt "({name})" --env

conda env export --no-builds > $DESC_TD_ENV_GPU_INSTALL_DIR/td_env-nersc-gpu-nobuildinfo.yml
conda env export > $DESC_TD_ENV_GPU_INSTALL_DIR/td_env-nersc-gpu.yml

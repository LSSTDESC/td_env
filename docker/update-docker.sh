#!/bin/bash

source /opt/lsst/software/stack/loadLSST.bash
conda install -c conda-forge -y mamba

# Cori offers mpich 3.3.2
mamba install -c conda-forge -y mpich=3.3.*=external_*

mamba install -c conda-forge -y --file ./packlist.txt
pip install --no-cache-dir -r ./piplist.txt

conda clean -y -a 

# python -m compileall /opt/lsst/software/stack/conda 
# Backing off compileall for docker images: https://stackoverflow.com/questions/64808915/should-pycache-folders-be-included-in-production-containers

# Import of ligo.em_bright to cause associated data files to be downloaded into the image
python -c "import ligo.em_bright"

conda env export --no-builds > /opt/lsst/software/stack/td_env-image-nobuildinfo.yml
conda env export > /opt/lsst/software/stack/td_env-image.yml

conda config --set env_prompt "(lsst-scipipe-$1)" --system

cp ../nersc/setup_td_dev.sh /opt/lsst/software/stack

#!/bin/bash

source /opt/lsst/software/stack/loadLSST.bash
conda install -c conda-forge -y mamba

# Cori offers mpich 3.3.2
mamba install -c conda-forge -y mpich=3.3.*=external_*

mamba install -c conda-forge -y --file ./packlist.txt
pip install --no-cache-dir -r ./piplist.txt

conda clean -a

python -m compileall /opt/lsst/software/stack/conda

conda config --set env_prompt "(lsst-scipipe-$1)" --system

cp ../nersc/setup_td_dev.sh /opt/lsst/software/stack

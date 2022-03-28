#!/bin/bash

source /opt/lsst/software/stack/loadLSST.bash
conda install -c conda-forge -y mamba

# Cori offers mpich 3.3.2
mamba install -c conda-forge -y mpich=3.3.*=external_*

mamba install -c conda-forge -y --file ./packlist.txt
pip install -r ./piplist.txt

conda config --set env_prompt "(lsst-scipipe-{$1})" --system


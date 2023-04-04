#!/bin/bash

source /opt/lsst/software/stack/loadLSST.bash
conda install -c conda-forge -y mamba

mamba install -c conda-forge -y mpich=4.0.3=external_*

mamba install -c conda-forge -y --file ./packlist.txt
pip install --no-cache-dir -r ./piplist.txt

conda clean -y -a 

cp ../nersc/setup_td_dev.sh /opt/lsst/software/stack

cd /opt/lsst/software/stack
# Install bayeSN
#git clone https://github.com/bayesn/bayesn-public
## Skipping full set up until we deal with the required data files in $PYSYN_CDBS

#Install RESSPECT
git clone https://github.com/COINtoolbox/resspect
cd resspect
python setup.py install
cd ..

# Grab firecrown source so we have the examples subdirectory
firecrown_ver=$(conda list firecrown | grep firecrown|tr -s " " | cut -d " " -f 2)
echo $firecrown_ver
curl -LO https://github.com/LSSTDESC/firecrown/archive/refs/tags/v$firecrown_ver.tar.gz
tar xvzf v$firecrown_ver.tar.gz
# Set up a common directory name without version info to set FIRECROWN_DIR more easily
ln -s firecrown-$firecrown_ver firecrown


# python -m compileall /opt/lsst/software/stack/conda 
# Backing off compileall for docker images: https://stackoverflow.com/questions/64808915/should-pycache-folders-be-included-in-production-containers

# Skipping for now
# Import of ligo.em_bright to cause associated data files to be downloaded into the image
# python -c "import ligo.em_bright"

# Additional build steps -- Handlined in Dockerfile
# bash ./post-conda-build.sh

conda env export --no-builds > /opt/lsst/software/stack/td_env-image-nobuildinfo.yml
conda env export > /opt/lsst/software/stack/td_env-image.yml

conda config --set env_prompt "(lsst-scipipe-$1)" --system


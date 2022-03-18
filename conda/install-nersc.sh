#!/bin/bash

module unload python
module swap PrgEnv-intel PrgEnv-gnu
module unload craype-network-aries
module unload cray-libsci
module unload craype
module load cray-mpich-abi/7.7.10

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

pwd

mkdir /global/common/software/lsst/cori-haswell-gcc/stack/hmk-ci-test

cp conda/packlist.txt /global/common/software/lsst/cori-haswell-gcc/stack/hmk-ci-test
cd /global/common/software/lsst/cori-haswell-gcc/stack/hmk-ci-test

curl -LO https://ls.st/lsstinstall

bash ./lsstinstall -T v23_0_0 

source ./loadLSST.bash

mamba install -c conda-forge -y mpich=3.3.*=external_*

export LD_LIBRARY_PATH=/opt/cray/pe/mpt/7.7.10/gni/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH

mamba install -c conda-forge -y --file ./packlist.txt


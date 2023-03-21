#!/bin/bash

if [ "$NERSC_HOST" == "cori" ]
then
  module unload python
  module swap PrgEnv-intel PrgEnv-gnu
  module unload craype-network-aries
  module unload cray-libsci
  module unload craype
  module load cray-mpich-abi/7.7.19
  export LD_LIBRARY_PATH=$CRAY_MPICH_BASEDIR/mpich-gnu-abi/8.2/lib:$LD_LIBRARY_PATH
else
  module load PrgEnv-gnu
  module load cpu
  module load cray-mpich-abi/8.1.24
fi

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

dmver=$1

# Set to 1 to install into the common sofware area
installFlag=$2

commonIntBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-int
commonDevBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-dev
commonProdBuildDir=/global/common/software/lsst/cori-haswell-gcc/stack/td_env-prod

if [ "$CI_COMMIT_REF_NAME" = "integration" ];  # integration
then
    curBuildDir=$commonIntBuildDir/$CI_PIPELINE_ID
    echo "Integration Install Build: " $curBuildDir
elif [ "$CI_COMMIT_REF_NAME" = "dev" ];  # dev
then
    curBuildDir=$commonDevBuildDir/$CI_PIPELINE_ID
    echo "Dev Install Build: " $curBuildDir
elif [[ "$installFlag" ]];  # Install Prod
then
    if [[ -z "$CI_COMMIT_TAG" ]];
    then
        prodBuildDir=$CI_PIPELINE_ID
    else
        prodBuildDir=$CI_COMMIT_TAG
    fi
    curBuildDir=$commonProdBuildDir/$prodBuildDir
    echo "Prod Build: " $curBuildDir
fi

mkdir -p $curBuildDir
cp conda/packlist.txt $curBuildDir
cp conda/post-conda-build.sh $curBuildDir
cp conda/piplist.txt $curBuildDir
cp nersc/setup_td_env.sh $curBuildDir
cp nersc/sitecustomize.py $curBuildDir
sed -i 's|$1|'$curBuildDir'|g' $curBuildDir/setup_td_env.sh
cd $curBuildDir


# Build Steps
curl -LO https://ls.st/lsstinstall
#export LSST_CONDA_ENV_NAME=lsst-scipipe-$1
bash ./lsstinstall -X $1 

source ./loadLSST.bash
eups distrib install -t $1 lsst_distrib

mamba install -c conda-forge -y mpich=3.4.*=external_*

mamba install -c conda-forge -y --file ./packlist.txt
pip install --no-cache-dir -r ./piplist.txt

conda clean -y -a 

# Install bayeSN
git clone https://github.com/bayesn/bayesn-public

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

# Additional build steps
bash ./post-conda-build.sh


python -m compileall $curBuildDir

# Hard-coding this for now for building at NERSC
export PYSYN_CDBS=/global/cfs/cdirs/lsst/groups/TD/SOFTWARE/bayeSN/synphot/grp/redcat/trds
#python $curBuildDir/bayesn-public/fit_sn.py --model T21 --metafile $curBuildDir/bayesn-public/demo_lcs/meta/T21_demo_meta.txt --filters griz --opt $curBuildDir/bayesn-public/demo_lcs/Foundation_DR1/Foundation_DR1_ASASSN-16cs.txt .
python $curBuildDir/bayesn-public/fit_sn.py --model T21 --fittmax 5 --metafile $curBuildDir/bayesn-public/demo_lcs/meta/T21_demo_meta.txt --filters griz --opt $curBuildDir/bayesn-public/demo_lcs/Foundation_DR1/Foundation_DR1_ASASSN-16cs.txt $TMPDIR

# Skipping this for now - they files are downloaded to the user's astropy cache
# Will revisit if it becomes an issue: https://docs.astropy.org/en/stable/utils/data.html
# Force data files to be dowloaded during installation
# python -c "import ligo.em_bright"

conda config --set env_prompt "(lsst-scipipe-$1)" --system

conda env export --no-builds > $curBuildDir/td_env-nersc-$CI_PIPELINE_ID-nobuildinfo.yml
conda env export > $curBuildDir/td_env-nersc-$CI_PIPELINE_ID.yml


# Set permissions
setfacl -R -m group::rx $curBuildDir
setfacl -R -d -m group::rx $curBuildDir

setfacl -R -m user:desc:rwx $curBuildDir
setfacl -R -d -m user:desc:rwx $curBuildDir



#!/bin/bash


module load PrgEnv-gnu
module load cpu
module load cray-mpich-abi/8.1.25
module load evp-patch


unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH PYTHONPATH

dmver=$1

# Set to 1 to install into the common sofware area
installFlag=$2

export BUILD_ID_DATE=`echo "$(date "+%F-%M-%S")"`
export CI_COMMIT_REF_NAME=dev
export CI_PIPELINE_ID=$BUILD_ID_DATE

commonIntBuildDir=/global/common/software/lsst/gitlab/td_env-int
commonDevBuildDir=/global/common/software/lsst/gitlab/td_env-dev
commonProdBuildDir=/global/common/software/lsst/gitlab/td_env-prod

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
cp conda/piplist_gpu.txt $curBuildDir
cp conda/condalist_gpu.txt $curBuildDir
cp nersc/setup_td_env.sh $curBuildDir
cp nersc/sitecustomize.py $curBuildDir
sed -i 's|$1|'$curBuildDir'|g' $curBuildDir/setup_td_env.sh
cd $curBuildDir

export PYTHONNOUSERSITE=1
export CONDA_CACHE_DIR=$curBuildDir/conda/pkgs


# Build Steps
curl -LO https://ls.st/lsstinstall
#export LSST_CONDA_ENV_NAME=lsst-scipipe-$1
bash ./lsstinstall -X $1 

source ./loadLSST.bash
eups distrib install -t $1 lsst_distrib --nolocks

python -m pip cache purge

mamba install -c conda-forge -y mpich=3.4.*=external_*

mamba install -c conda-forge -y --file ./packlist.txt
pip install --no-cache-dir -r ./piplist.txt

conda clean -y -a 

export PYSYN_CDBS=/global/cfs/cdirs/lsst/groups/TD/SOFTWARE/bayeSN/synphot/grp/redcat/trds

# Install bayeSN
git clone https://github.com/bayesn/bayesn-public

#Install RESSPECT
git clone https://github.com/COINtoolbox/resspect
cd resspect
#python setup.py install
python3 -m pip install --no-deps --no-cache-dir .
cd ..

# install eazy from source due to inability to install via pip
git clone https://github.com/gbrammer/eazy-py.git
### Build the python code
cd eazy-py
### Install and run the test suite, which also downloads the templates and
### filters from the eazy-photoz repository if necessary
pip install --no-cache-dir .[test] -r requirements.txt
pytest
cd ..
pip install --no-cache-dir git+https://github.com/gbrammer/dust_attenuation.git

# Grab firecrown source so we have the examples subdirectory
firecrown_ver=$(conda list firecrown | grep firecrown|tr -s " " | cut -d " " -f 2)
echo $firecrown_ver
curl -LO https://github.com/LSSTDESC/firecrown/archive/refs/tags/v$firecrown_ver.tar.gz
tar xvzf v$firecrown_ver.tar.gz
# Set up a common directory name without version info to set FIRECROWN_DIR more easily
ln -s firecrown-$firecrown_ver firecrown

# Additional build steps
bash ./post-conda-build.sh

# Download astrodash models from zenodo as mentioned in astrodash README on github
cd $CONDA_PREFIX/lib/python3.10/site-packages/astrodash
curl -LO https://zenodo.org/record/7760927/files/models_v06.zip
unzip models_v06.zip
cd $curBuildDir

#python -m compileall $curBuildDir

# Hard-coding this for now for building at NERSC
export PYSYN_CDBS=/global/cfs/cdirs/lsst/groups/TD/SOFTWARE/bayeSN/synphot/grp/redcat/trds
#python $curBuildDir/bayesn-public/fit_sn.py --model T21 --metafile $curBuildDir/bayesn-public/demo_lcs/meta/T21_demo_meta.txt --filters griz --opt $curBuildDir/bayesn-public/demo_lcs/Foundation_DR1/Foundation_DR1_ASASSN-16cs.txt .
python $curBuildDir/bayesn-public/fit_sn.py --model T21 --fittmax 5 --metafile $curBuildDir/bayesn-public/demo_lcs/meta/T21_demo_meta.txt --filters griz --opt $curBuildDir/bayesn-public/demo_lcs/Foundation_DR1/Foundation_DR1_ASASSN-16cs.txt $TMPDIR

# Skipping this for now - they files are downloaded to the user's astropy cache
# Will revisit if it becomes an issue: https://docs.astropy.org/en/stable/utils/data.html
# Force data files to be dowloaded during installation
# python -c "import ligo.em_bright"

conda env config vars set PYTHONNOUSERSITE=1

conda config --set env_prompt "(lsst-scipipe-$1)" --env

conda env export --no-builds > $curBuildDir/td_env-nersc-$CI_PIPELINE_ID-nobuildinfo.yml
conda env export > $curBuildDir/td_env-nersc-$CI_PIPELINE_ID.yml


# Set permissions
setfacl -R -m group::rx $curBuildDir
setfacl -R -d -m group::rx $curBuildDir

setfacl -R -m user:desc:rwx $curBuildDir
setfacl -R -d -m user:desc:rwx $curBuildDir



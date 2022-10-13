# td_env
Defines, builds and installs a conda environment including the LSST Science Pipelines and Time Domain requested packages installable via [conda-forge](https://github.com/LSSTDESC/td_env/blob/main/conda/packlist.txt) or [pip](https://github.com/LSSTDESC/td_env/blob/main/conda/piplist.txt). 

## Currently Supported Installations

* Native NERSC Installation on Cori also available in Jupyter
* Docker images available on DockerHub and in Shifter at NERSC
* Development versions are also available to test pre-releases

## Running at NERSC
* To use the td_env installed at NERSC
    * `source /global/cfs/cdirs/lsst/groups/TD/setup_td.sh`
* OR access the `desc-td-env` Jupyter kernel by making sure you have [DESC jupyter kernels installed](https://confluence.slac.stanford.edu/display/LSSTDESC/Using+Jupyter+at+NERSC#UsingJupyteratNERSC-setup)
* OR use the available Shifter image
    * `lsstdesc/td-env:stable`
    ```
    shifter --image=lsstdesc/td-env:stable /bin/bash 
    source /global/cfs/cdirs/lsst/groups/TD/setup_td.sh
    ```
    
## Current Stable Release
https://github.com/LSSTDESC/td_env/releases/latest

## To Request Additional Packages, Report Problems, or Submit Questions
Please [open an issue](https://github.com/LSSTDESC/td_env/issues) on this repository.

## To Add New Packages to the td_env environment 

1. Clone this repo and checkout the "integration" branch
2. Add new package names to the `td_env/conda/packlist.txt` (for conda-forge) or `td_env/conda/piplist.txt` (for PyPI)
    * If this package is not installable from conda-forge or PyPI, please [open an issue](https://github.com/LSSTDESC/td_env/issues) on this repository.
3. Commit and push your changes to the integration branch
4. Once changes are pushed to the integration branch automated builds will be triggered:
    * Docker builds are handled by GitHub actions and will be triggered immediately. The builds can be followed by viewing the [Actions](https://github.com/LSSTDESC/td_env/actions) page.
        * A successful build will produce a new image available on [Dockerhub](https://hub.docker.com/r/lsstdesc/td-env/tags): `lsstdesc/td_env:integration`
    * Every 4 hours, a build is triggered at NERSC. 
        * Integration builds are installed in `/global/common/software/lsst/cori-haswell-gcc/stack/td_env-int`

## Known Issues
Due to changes in how cfitsion >=v4.0.0 handles version checking, some packages that depend on cfitsio are now issuing warnings like
```
WARNING: version mismatch between CFITSIO header (v4.000999999999999) and linked library (v4.01).
```
Those packages that depend on cfitsio, such as healpy, need to patch their code to deal with cfitsio's version handling which apparenly involves floats.
This warning is safe to ignore, and when LSST Science Pipelines updates packages such as healpy, this issue should disappear.

### For Developers
To export a full list of versions installed in the td_env conda environment without build info: 
`conda env export --no-builds > desc-python-env-nersc-install-nobuildinfo.yml`

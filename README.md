# td_env
Defines, builds and installs a conda environment includingTime Domain requested packages

## Currently Supported Installations

* Native NERSC Installation also available in Jupyter

## Running at NERSC
* To use the td_env installed at NERSC
    * `source /global/cfs/cdirs/lsst/groups/TD/setup_td.sh`
* OR access the `desc-td-env` Jupyter kernel by making sure you have [DESC jupyter kernels installed](https://confluence.slac.stanford.edu/display/LSSTDESC/Using+Jupyter+at+NERSC#UsingJupyteratNERSC-setup)

## Current Stable Release
https://github.com/LSSTDESC/td_env/releases/latest

## Running cosmosis + firecrown

The default `setup_td.sh` will prepare the environment by settting $CSL_DIR, $FIRECROWN_DIR, $FIRECROWN_EXAMPLES_DIR, $FIRECROWN_SITE_PACKAGES variables which points to the current build directory. Currently the default setup does NOT entirely complete the cosmosis set up and does not run `source cosmosis-configure`. However, this can be enabled by doing:  `source setup_td_int.sh -c`.

To run a test of cosmosis + firecrown after doing `source setup_td.sh` please try: `cosmosis $FIRECROWN_DIR/examples/des_y1_3x2pt/des_y1_3x2pt.ini`

## To Request Additional Packages, Report Problems, or Submit Questions
Please post a request on #desc-td-pipelines or [open an issue](https://github.com/LSSTDESC/td_env/issues) on this repository.

## To Add and Update Packages in the td_env environment 

If you are a member of the td_env team of maintainers, please refer to [these instructions](./update_env.md).


## Known Issues


#!/bin/bash
module load gpu

unset PYTHONPATH

export PYTHONNOUSERSITE=1

source /global/cfs/cdirs/lsst/groups/TD/SOFTWARE/snn/snn-stable/py/etc/profile.d/conda.sh
conda activate supernnova-cuda




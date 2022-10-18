#!/bin/bash

# Project- or dependency-specific setup commands to be
# run after a conda installation, for example to download
# additional data files


# Download and build the CosmoSIS standard library
# in a directory under the CosmoSIS python directory
cosmosis-build-standard-library -i

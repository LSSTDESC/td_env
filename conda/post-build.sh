#!/bin/bash

# Project- or dependency-specific setup commands to be
# run after a conda installation.


# Download and build the CosmoSIS standard library
# in a directory under the CosmoSIS python dir
cosmosis-build-standard-library -i

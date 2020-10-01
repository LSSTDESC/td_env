# sn_env
Creates conda environment and install SNANA in a docker image.

Docker images are stored on DockerHub and are accessible via
`docker pull lsstdesc/sn_env:latest`

Upon startup, the container will enable the sn_env conda environment which 
includes ROOT, gsl, and python packages requested by the SN WG.  

There is also an installation of [SNANA](https://github.com/RickKessler/SNANA), built using the conda-forge compilers and the installed dependencies, including ROOT.


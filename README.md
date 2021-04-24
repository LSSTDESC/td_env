# sn_env
Creates conda environment and install SNANA in a docker image.

dev branch Docker images are stored on DockerHub and are accessible via
`docker pull lsstdesc/sn-py-dev:dev`

To export a full list of versions without build info: 
`conda env export --no-builds > desc-python-env-nersc-install-nobuildinfo.yml`


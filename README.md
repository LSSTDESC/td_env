# td_env
Creates conda environment including the LSST Science Pipelines and TD requested packages. 

dev branch Docker images are stored on DockerHub and are accessible via
`docker pull lsstdesc/td-env:dev`

To export a full list of versions without build info: 
`conda env export --no-builds > desc-python-env-nersc-install-nobuildinfo.yml`


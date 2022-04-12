# td_env
Creates conda environment including the LSST Science Pipelines and TD requested packages. 

dev branch Docker images are stored on DockerHub and are accessible via
`docker pull lsstdesc/td-env:dev`

## Running at NERSC
* To use the td_env installed at NERSC
    * `source /global/cfs/cdirs/lsst/groups/TD/setup_td.sh`
* OR use the available Shifter image
    * `lsstdesc/td-env:dev`
    ```
    shifter --image=lsstdesc/td-env:dev /bin/bash 
    source /global/cfs/cdirs/lsst/groups/TD/setup_td.sh
    ```

## Known Issues
Due to changes in how cfitsion >=v4.0.0 handles version checking, some packages that depend on cfitsio are now issuing warnings like
```
WARNING: version mismatch between CFITSIO header (v4.000999999999999) and linked library (v4.01).
```
Those packages that depend on cfitsio, such as healpy, need to patch their code to deal with cfitsio's version handling which apparenly involves floats.
This warning is safe to ignore, and when LSST Science Pipelines updates packages such as healpy, this issue should disappear.

### For Developers
To export a full list of versions without build info: 
`conda env export --no-builds > desc-python-env-nersc-install-nobuildinfo.yml`

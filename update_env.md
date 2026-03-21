# How to Add or Update packages in the td_env conda environment

If you are a member of the td_env maintainence team please follow these instructions

* Log into a NERSC data transfer node (DTN), i.e. ssh dtn.nersc.gov
* Log into the desctd collaboration account, via `collabsu desctd`, you will need to provide your typical NERSC account password
  * You will see warnings about modules not found on the NERSC data transfer nodes, these messages can be ignored
* Once logged in as desctd, your environment is ready to pip install packages into the td_env PROD environment
   * To pip install a package that is already in the td_env, such as opencosmo
   
   `pip install --user --no-deps --no-build-isolation -U <packageName>`
  * To pip install a new package that is not already in td_env, drop the `-U` option:
  
    `pip install --user --no-deps --no-build-isolation <packageName>`

FROM condaforge/mambaforge-pypy3:23.11.0-0
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG PR_BRANCH=dev

ARG DESC_TD_ENV_DIR=/opt/desc

ENV PYTHONDONTWRITEBYTECODE 1

# Make, which we will need for everything
RUN apt-get update -y \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y make unzip \
    && apt-get clean all

# We need a C compiler temporarily to install MPICH, which we want so that we use
# vendored MPI with conda. Not sure if we can get away with removing the gcc and g++
# compilers afterwards to save space but will try. We will use the conda gcc for everything
# else, though ideally everything would come through conda-forge.
# I have found that using the conda-forge supplied MPICH does not work
# with shifter on NERSC.
RUN apt-get update -y  \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y gcc gfortran \
    && mkdir /opt/mpich \
    && cd /opt/mpich \
    && wget http://www.mpich.org/static/downloads/4.1.2/mpich-4.1.2.tar.gz \
    && tar xvzf mpich-4.1.2.tar.gz \
    && cd mpich-4.1.2 \
    && ./configure --disable-wrapper-rpath  --disable-cxx --with-device=ch3 && make -j 4 \
    && make install \
    && rm -rf /opt/mpich \
    && /sbin/ldconfig \
    && apt-get remove --purge -y gcc gfortran \
    && cd /tmp  \
    && git clone https://github.com/LSSTDESC/td_env  \
    && cd td_env  \
    && git checkout $PR_BRANCH  \
    && conda create -y --name td-gpu python=3.11 \
    && conda activate td-gpu \
    && mamba install -c conda-forge -y mpich=4.1.2.*=external_* \
    && CONDA_OVERRIDE_CUDA="11.8" mamba install -y "tensorflow==2.14.0=cuda118*" -c conda-forge \
    && mamba install -y  pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia \
    && mamba install -c conda-forge -y --file ./conda/condalist_gpu.txt \
    && pip install --upgrade "jax[cuda11_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html \
    && pip install --no-cache-dir -r ./conda/piplist_gpu.txt \ 
    && cd .. \
    && curl -LO https://github.com/bayesn/bayesn/archive/refs/tags/v0.3.1.tar.gz \
    && tar xzf v0.3.1.tar.gz \
    && ln -s bayesn-0.3.1 bayesn \
    && cd bayesn \
    && python3 -m pip install --no-deps --no-cache-dir . \
    && cd .. \
    && rm v0.3.1.tar.gz

    


#RUN apt update -y && \
##    apt install -y curl \
 ##   build-essential \
 ##   gfortran \
 #   git \
 #   patch \
 #   python3 \
 #   unzip \
 #   wget && \
 #   apt-get clean  && \
 #   rm -rf /var/cache/apt && \
 #   groupadd -g 1000 -r lsst && useradd -u 1000 --no-log-init -m -r -g lsst lsst && \
 #   usermod --shell /bin/bash lsst && \
 #   cd /tmp && \
 #   git clone https://github.com/LSSTDESC/td_env && \
 #   cd td_env && \
 #   git checkout $PR_BRANCH && \
#    bash ./docker/install-mpich-for-gpu.sh && \
#    cd /tmp && \
##    chown -R lsst td_env && \ 
 #   mkdir -p $DESC_TD_ENV_DIR && \
#    chown lsst $DESC_TD_ENV_DIR && \
#    chgrp lsst $DESC_TD_ENV_DIR && \
#    apt-get remove --purge -y python3

##ARG LSST_USER=lsst
#ARG LSST_GROUP=lsst

#WORKDIR $DESC_TD_ENV_DIR
   
#USER lsst

#
##RUN cd /tmp/td_env/docker && \ 
 #   bash install-gpu-td-env.sh /opt/desc/py ../conda/condalist_gpu.txt ../conda/piplist_gpu.txt && \
 ##   cd /tmp && \
  #  rm -Rf td_env
    
#USER root

#RUN ln -s /opt/desc/py /usr/local/py

#USER lsst
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''


#RUN echo "source /opt/desc/py/etc/profile.d/conda.sh" >> ~/.bashrc && \
#    echo "conda activate base" >> ~/.bashrc
    
#ENV PATH="${DESC_TD_ENV_DIR}/${PY_VER}/bin:${PATH}"
#SHELL ["/bin/bash", "--login", "-c"]


#CMD ["/bin/bash"]

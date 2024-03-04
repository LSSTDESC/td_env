FROM ubuntu:22.04
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG PR_BRANCH=dev

ARG DESC_TD_ENV_DIR=/opt/desc

RUN apt update -y && \
    apt install -y curl \
    build-essential \
    gfortran \
    git \
    patch \
    python3 \
    unzip \
    wget && \
    apt-get clean  && \
    rm -rf /var/cache/apt && \
    groupadd -g 1000 -r lsst && useradd -u 1000 --no-log-init -m -r -g lsst lsst && \
    usermod --shell /bin/bash lsst && \
    cd /tmp && \
    git clone https://github.com/LSSTDESC/td_env && \
    cd td_env && \
    git checkout $PR_BRANCH && \
    bash ./docker/install-mpich-for-gpu.sh && \
    cd /tmp && \
    chown -R lsst td_env && \ 
    mkdir -p $DESC_TD_ENV_DIR && \
    chown lsst $DESC_TD_ENV_DIR && \
    chgrp lsst $DESC_TD_ENV_DIR && \
    apt-get remove --purge -y python3

ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

WORKDIR $DESC_TD_ENV_DIR
   
USER lsst

ENV PYTHONDONTWRITEBYTECODE 1

RUN cd /tmp/td_env/docker && \ 
    bash install-gpu-td-env.sh /opt/desc/py condalist_gpu.txt piplist_gpu.txt && \
    find /$DESC_TD_ENV_DIR -name "*.pyc" -delete && \
    (find $DESC_TD_ENV_DIR -name "*.so" ! -path "*/xpa/*" | xargs strip -s -p) || true && \
    cd /tmp && \
    rm -Rf td_env
    
USER root

RUN ln -s /opt/desc/py /usr/local/py

USER lsst
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''


RUN echo "source /opt/desc/py/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
    
ENV PATH="${DESC_TD_ENV_DIR}/${PY_VER}/bin:${PATH}"
SHELL ["/bin/bash", "--login", "-c"]


#CMD ["/bin/bash"]

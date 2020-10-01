FROM centos:7
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

RUN yum update -y && \
    yum install -y bash \
    bison \
    blas \
    bzip2 \
    bzip2-devel \
    cmake \
    curl \
    flex \
    fontconfig \
    freetype-devel \
    gawk \
    gcc-c++ \
    gcc-gfortran \
    gettext \
    git \
    glib2-devel \
    java-1.8.0-openjdk \
    libcurl-devel \
    libuuid-devel \
    libXext \
    libXrender \
    libXt-devel \
    make \
    mesa-libGL \
    ncurses-devel \
    openssl-devel \
    patch  \
    perl \
    perl-ExtUtils-MakeMaker \
    readline-devel \
    sed \
    tar \
    which \
    zlib-devel 
    
RUN yum clean -y all && \
    rm -rf /var/cache/yum && \
    groupadd -g 1000 -r lsst && useradd -u 1000 --no-log-init -m -r -g lsst lsst && \
    cd /tmp && \
    git clone https://github.com/LSSTDESC/sn_env && \
    cd sn_env/conda && \
    bash install-sn-env.sh /usr/local/py3 sn-env.yml && \
    cp sn-env-setup.sh /usr/local/py3
    
    
ENV SNANA_DIR /usr/local/snana/SNANA-10_78c
ENV SNANA_ROOT /usr/local/snana/SNDATA_ROOT
ENV SNDATA_ROOT /usr/local/snana/SNDATA_ROOT
ENV CFITSIO_DIR /usr/local/py3/envs/sn-env
ENV GSL_DIR /usr/local/py3/envs/sn-env
ENV ROOT_DIR /usr/local/py3/envs/sn-env
ENV PATH="${SNANA_DIR}/bin:${SNANA_DIR}/util:${PATH}"

# SNANA
RUN mkdir /usr/local/snana && \
    cd /usr/local/snana && \
    curl -LO  https://github.com/RickKessler/SNANA/archive/v10_78c.tar.gz && \
    tar xvzf v10_78c.tar.gz && \
    mkdir -p $SNDATA_ROOT && \
    cd $SNDATA_ROOT && \
    curl -LO https://zenodo.org/record/4015325/files/SNDATA_ROOT_2020-09-04.tar.gz && \
    tar xvzf SNDATA_ROOT_2020-09-04.tar.gz && \
    cd .. && \
    cd $SNANA_DIR/src && \
    mv Makefile Makefile_ORG && \
    cp /tmp/sn_env/snana/Makefile . && \
    cat Makefile && \
    /bin/bash -c 'source /usr/local/py3/etc/profile.d/conda.sh; \
    conda activate sn-env; \
    which g++; \
    make all; \'

RUN cd /tmp && \
    rm -Rf sn_env
    
USER lsst
    
RUN echo "source /usr/local/py3/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate sn-env" >> ~/.bashrc
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''

ENV PATH="/usr/local/py3/bin:${PATH}"

ENV CONDA_DEFAULT_ENV sn-env

CMD ["/bin/bash"]

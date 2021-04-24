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

COPY conda /tmp
    
RUN yum clean -y all && \
    rm -rf /var/cache/yum && \
    groupadd -g 1000 -r lsst && useradd -u 1000 --no-log-init -m -r -g lsst lsst && \
    cd /tmp && \
    bash install-sn-env.sh /usr/local/py3 /tmp/sn-env-nersc-nobuildinfo.yml && \
    cp /tmp/sn-env-setup.sh /usr/local/py3
    
    
RUN cd /tmp && \
    rm -Rf conda 
    
USER lsst
    
RUN echo "source /usr/local/py3/etc/profile.d/conda.sh" >> ~/.bashrc
RUN echo "conda activate sn-env" >> ~/.bashrc
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''

ENV PATH="/usr/local/py3/bin:${PATH}"

ENV CONDA_DEFAULT_ENV sn-env

CMD ["/bin/bash"]

FROM centos:centos7.7.1908
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG GH_SHA
ARG LSST_TAG=w_2022_32
ARG LSST_STACK_DIR=/opt/lsst/software/stack

#RUN pwd && ls && echo $GH_SHA 

RUN yum update -y && \
    yum install -y bash \
    git \
    patch \
    wget \
    which && \
    yum clean -y all && \
    rm -rf /var/cache/yum && \
    groupadd -g 1000 -r lsst && useradd -u 1000 --no-log-init -m -r -g lsst lsst && \
    mkdir -p $LSST_STACK_DIR && \
    chown lsst $LSST_STACK_DIR && \
    chgrp lsst $LSST_STACK_DIR

ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

USER lsst

WORKDIR $LSST_STACK_DIR

RUN echo "Environment: \n" && env | sort && \
    curl -LO https://ls.st/lsstinstall && \
    bash ./lsstinstall ${LSST_TAG:+"-X"} $LSST_TAG && \
    /bin/bash -c 'source ./loadLSST.bash; \
                  eups distrib install ${LSST_TAG:+"-t"} $LSST_TAG lsst_distrib --nolocks;' && \
    rm -Rf python/doc && \
    rm -Rf python/phrasebooks && \
    find stack -name "*.pyc" -delete && \
    (find stack -name "*.so" ! -path "*/xpa/*" | xargs strip -s -p) || true && \
    (find stack -name "src" ! -path "*/Eigen/*" | xargs rm -Rf) || true && \
    (find stack -name "doc" | xargs rm -Rf) || true && \
    mkdir -p /tmp/gh && \
    cd /tmp/gh && \
    git clone https://github.com/LSSTDESC/td_env && \
    cd td_env && \
    git checkout $GH_SHA 

USER root 

RUN cd /tmp/gh/td_env && \
    bash ./docker/install-mpich.sh

USER lsst
RUN cd /tmp/gh/td_env/conda && \
    bash /tmp/gh/td_env/docker/update-docker.sh w_2022_32 && \
    bash post-conda-build.sh && \
    echo "source $LSST_STACK_DIR/loadLSST.bash" >> ~/.bashrc && \
    echo "setup lsst_distrib" >> ~/.bashrc && \
    rm -Rf /tmp/gh


ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''

ENV PATH="${LSST_STACK_DIR}:${PATH}"


CMD ["/bin/bash"]


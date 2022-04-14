FROM centos:centos7.7.1908
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG GH_SHA
ARG LSST_TAG=w_2022_10
ARG LSST_STACK_DIR=/opt/lsst/software/stack

RUN pwd && ls && ls -a /tmp && ls /tmp/.buildx-cache && echo $GH_SHA 

RUN yum update -y && \
    yum install -y bash \
    patch \
    wget \
    which && \
    yum clean -y all && \
    rm -rf /var/cache/yum 
    
RUN groupadd -g 1000 -r lsst && useradd -u 1000 --no-log-init -m -r -g lsst lsst
    
   
RUN mkdir -p $LSST_STACK_DIR && \
    chown lsst $LSST_STACK_DIR && \
    chgrp lsst $LSST_STACK_DIR

ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

USER lsst

WORKDIR $LSST_STACK_DIR


    
   
RUN echo "Environment: \n" && env | sort && \
    curl -LO https://ls.st/lsstinstall && \
    mkdir -p /tmp/gh && \
    cd /tmp/gh && \
    git clone https://github.com/LSSTDESC/td_env && \
    cd td_env && \ 
    git checkout $GH_SHA && \
    cd $LSST_STACK_DIR && \
    bash ./lsstinstall ${LSST_TAG:+"-X"} $LSST_TAG && \
    /bin/bash -c 'source ./loadLSST.bash; \
                  eups distrib install ${LSST_TAG:+"-t"} $LSST_TAG lsst_distrib --nolocks;'
                  
                  
USER root 

RUN cd /tmp/gh/td_env && \
    bash ./docker/install-mpich.sh


USER lsst
RUN cd /tmp/gh/td_env && \
    bash ./docker/update-docker.sh $LSST_TAG
    
RUN echo "source $LSST_STACK_DIR/loadLSST.bash" >> ~/.bashrc
##RUN echo "conda activate sn-env" >> ~/.bashrc
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''

ENV PATH="${LSST_STACK_DIR}:${PATH}"


CMD ["/bin/bash"]



#COPY conda /tmp

#RUN /bin/bash -c 'source ./loadLSST.bash; \
#                  ./docker/install-mpich.sh;
                  
#                   conda config --set env_prompt "(lsst-scipipe-$LSST_TAG)" --system; \

    
#    && \
#    cd /tmp && \
#    bash install-sn-env.sh /usr/local/py3 /tmp/sn-env.yml && \
#    cp /tmp/sn-env-setup.sh /usr/local/py3
    
    
#RUN cd /tmp && \
#    rm -Rf conda 
#ENV CONDA_DEFAULT_ENV sn-env

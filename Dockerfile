FROM centos:centos7.7.1908
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_TAG=w_2022_10
ARG LSST_STACK_DIR=/opt/lsst/software/stack

RUN pwd && ls

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


#COPY conda /tmp
    
   
RUN echo "Environment: \n" && env | sort && \
    curl -LO https://ls.st/lsstinstall && \
    bash ./lsstinstall ${LSST_TAG:+"-X"} $LSST_TAG && \
    /bin/bash -c 'source ./loadLSST.bash; \
                  eups distrib install ${LSST_TAG:+"-t"} $LSST_TAG lsst_distrib --nolocks; \
                  conda clean -y -a; \
                  python -m compileall $LSST_STACK_DIR; \
                  conda env export --no-builds > $LSST_STACK_DIR/td_env-docker-nobuildinfo.yml; \
                  conda env export > $LSST_STACK_DIR/td_env-docker.yml;'
                  
                  
USER root
                  
#                   conda config --set env_prompt "(lsst-scipipe-$LSST_TAG)" --system; \

    
#    && \
#    cd /tmp && \
#    bash install-sn-env.sh /usr/local/py3 /tmp/sn-env.yml && \
#    cp /tmp/sn-env-setup.sh /usr/local/py3
    
    
#RUN cd /tmp && \
#    rm -Rf conda 

USER lsst
    
    
RUN echo "source $LSST_STACK_DIR/loadLSST.bash" >> ~/.bashrc
#RUN echo "conda activate sn-env" >> ~/.bashrc
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''

ENV PATH="${LSST_STACK_DIR}:${PATH}"

#ENV CONDA_DEFAULT_ENV sn-env

CMD ["/bin/bash"]

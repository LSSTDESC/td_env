FROM centos:centos7.7.1908
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_TAG
ARG LSST_STACK_DIR=/opt/lsst/software/stack

RUN yum update -y && \
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


#COPY conda /tmp
    
   
RUN echo "Environment: \n" && env | sort && \
    /bin/bash -c 'curl -LO https://ls.st/lsstinstall; \
                  bash ./lsstinstall ${LSST_TAG:+"-X"}; \
                  source ./loadLSST.bash; \
                  eups distrib install ${LSST_TAG:+"-t"} $LSST_TAG lsst_distrib --nolocks; \
                  conda clean -y -a; \
                  python -m compileall $LSST_STACK_DIR; \
                  conda env export --no-builds > $LSST_STACK_DIR/td_env-docker-nobuildinfo.yml; \
                  conda env export > $curBuildDir/td_env-docker.yml;'
                  
                  #                   conda config --set env_prompt "(lsst-scipipe-$LSST_TAG)" --system; \

    
#    && \
#    cd /tmp && \
#    bash install-sn-env.sh /usr/local/py3 /tmp/sn-env.yml && \
#    cp /tmp/sn-env-setup.sh /usr/local/py3
    
    
#RUN cd /tmp && \
#    rm -Rf conda 
    
    
#RUN echo "source /usr/local/py3/etc/profile.d/conda.sh" >> ~/.bashrc
#RUN echo "conda activate sn-env" >> ~/.bashrc
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''

ENV PATH="${LSST_STACK_DIR}:${PATH}"

#ENV CONDA_DEFAULT_ENV sn-env

CMD ["/bin/bash"]

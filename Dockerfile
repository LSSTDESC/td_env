## DOCKERFILE Not IN USE 

ARG LSST_TAG
FROM lsstsqre/centos:7-stack-lsst_distrib-$LSST_TAG
MAINTAINER Heather Kelly <heather@slac.stanford.edu>

ARG LSST_TAG
ARG LSST_STACK_DIR=/opt/lsst/software/stack

ARG LSST_USER=lsst
ARG LSST_GROUP=lsst

WORKDIR $LSST_STACK_DIR

USER root
RUN yum install -y wget \
    which

COPY conda /tmp
    
   
RUN echo "Environment: \n" && env | sort && \
    cd /tmp && \
    /bin/bash -c 'source $LSST_STACK_DIR/loadLSST.bash; \
                  pip freeze > $LSST_STACK_DIR/require.txt; \
                  eups distrib install ${EUPS_TAG2:+"-t"} $EUPS_TAG2 $EUPS_PRODUCT2 --nolocks; \
                  export EUPS_PKGROOT=https://eups.lsst.codes/stack/src; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_THROUGH --nolocks; \
                  eups distrib install ${EUPS_THROUGH_TAG:+"-t"} $EUPS_THROUGH_TAG $EUPS_SKY --nolocks;'
    
#    && \
#    cd /tmp && \
#    bash install-sn-env.sh /usr/local/py3 /tmp/sn-env.yml && \
#    cp /tmp/sn-env-setup.sh /usr/local/py3
    
    
RUN cd /tmp && \
    rm -Rf conda 
    
USER lsst
    
#RUN echo "source /usr/local/py3/etc/profile.d/conda.sh" >> ~/.bashrc
#RUN echo "conda activate sn-env" >> ~/.bashrc
    
ENV HDF5_USE_FILE_LOCKING FALSE
ENV PYTHONSTARTUP ''

#ENV PATH="/usr/local/py3/bin:${PATH}"

#ENV CONDA_DEFAULT_ENV sn-env

CMD ["/bin/bash"]

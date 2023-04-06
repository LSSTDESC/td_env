#!/bin/bash

# yum install -y wget which  # Handled in dockerfile

source /opt/lsst/software/stack/loadLSST.bash

export mpich=3.4
export mpich_prefix=mpich-$mpich

curl -LO https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz 
tar xvzf $mpich_prefix.tar.gz                                      
cd $mpich_prefix                                                        
unset F90
./configure                                                           
make -j 4                                                               
make install                                                           
make clean                                                        
cd ..                                                              
rm -rf $mpich_prefix
rm $mpich_prefix.tar.gz 
/sbin/ldconfig

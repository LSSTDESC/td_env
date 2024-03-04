#!/bin/bash

export mpich=4.2.0
export mpich_prefix=mpich-$mpich

curl -LO https://www.mpich.org/static/downloads/$mpich/$mpich_prefix.tar.gz 
tar xvzf $mpich_prefix.tar.gz                                      
cd $mpich_prefix                                                        
unset F90
./configure FFLAGS=-fallow-argument-mismatch FCFLAGS=-fallow-argument-mismatch --disable-wrapper-rpath --disable-cxx --with-device=ch3                                                          
make -j 4                                                               
make install                                                           
make clean                                                        
cd ..                                                              
rm -rf $mpich_prefix
rm $mpich_prefix.tar.gz 
/sbin/ldconfig

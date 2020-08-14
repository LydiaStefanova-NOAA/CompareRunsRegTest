#!/bin/bash

  module load intel/18.0.5.274 
  module load netcdf/4.7.0
  CDF=/apps/netcdf/4.7.0/intel/18.0.5.274

# How many experiments are to be compared with one another?
  nexp=2  #number of experiments

# What are the paths to each experiment?
  rootpath1="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/forRegTest/IPD/"
  rootpath2="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/forRegTest/CCPP/"
  rootpath3="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/forRegTest/Wave/"  #this directory  currently does not exist, just an example

# Specify experiment names (for each of the above directories) - used for labeling output
  expname1="IPD"
  expname2="CCPP"
  expname3="Wave" # this one currently does not exist
  
# Specify domain (atm/ocn/ice). File name ("file") phyf/ocn/ice) and extention ("extn") may have to be changed as needed. 
  domain="atm"; file="phyf"; extn="840.tile"
  #domain="ocn"; file="ocn"; extn="_2013_04_01_03.nc"
  #domain="ice"; file="ice"; extn="h_06h.2013-04-11-00000.nc"



case "$file" in
    "phyf") nx=384; ny=384; ntile=6; nkind=3; varmin=4; varmax=134; domask=1 ;;
    "dynf") nx=384; ny=384; ntile=6; nkind=3 ; varmin=4; varmax=10; domask=0 ;;
    "ocn")  nx=1440; ny=1080; ntile=1; nkind=1 ; varmin=22; varmax=39;domask=0 ;;
    "ice")  nx=1440; ny=1080; ntile=1; nkind=1 ; varmin=13; varmax=60; domask=0 ;;
esac

# Create parameter file
cat << EOF > param.F90
  module param
  implicit none
  integer, parameter  :: nx = $nx, ny = $ny, nt=1, ntile=$ntile, nkind=$nkind, nexp=$nexp 
  integer, parameter  :: domask=$domask, varmin=$varmin, varmax=$varmax
  end module param
EOF

cat << EOF > Makefile
CDF=$CDF
FOPT = -O2
F90 = ifort
opt1 = -Duse_m6c5
opt2 = -mcmodel=medium 
optall = \$(opt1) \$(opt2) \$(opt3) \$(opt4)
OBJS = param.o ncsubs.o stats.o compare_models.o 
runcompare: \$(OBJS) 
	\$(F90) \$(FOPT) -o runcompare \$(OBJS) -L\$(CDF)/lib -lnetcdff -lnetcdf 
%.o: %.F90
	\$(F90) \$(FOPT) \$(optall) -c -I\$(CDF)/include $<
	cpp \$(optall) -I\$(CDF)/include \$*.F90>\$*.i
clean:
	/bin/rm -f runcompare *.o *.i *.mod
EOF

make clean
make

# String up the file and experiment names to provide as arguments to the executable
  declare -a path=($rootpath1 $rootpath2 $rootpath3)
  declare -a expname=($expname1 $expname2 $expname3)
  for (( i=0 ; i<$nexp; i+=1 )) ; do
    echo $i
    patharg="${patharg} ${path[$i]}$file$extn"
    exparg="${exparg} ${expname[$i]}"
  done
  echo $patharg
  echo $exparg
  
 ./runcompare $patharg $exparg  20120101

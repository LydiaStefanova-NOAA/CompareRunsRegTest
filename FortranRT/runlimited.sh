#!/bin/bash


# THIS sets up to compare files from ice and ocean output, optionally by date

  module load intel/18.0.5.274 
  module load netcdf/4.7.0
  CDF=/apps/netcdf/4.7.0/intel/18.0.5.274

  nexp=2

# ICs
  ddic=1
  mmic=4
  hh=0
  hh=$(printf "%02d" $hh)

  leadstart=1
  leadend=35
  leadstep=5

  yyyyicA=2014 
  yyyyicB=2014
  
  mmic=$(printf "%02d" $mmic)
  ddic=$(printf "%02d" $ddic)
  dateicA=${yyyyicA}${mmic}${ddic}
  dateicB=${yyyyicB}${mmic}${ddic}

  echo $dateicA

#
  rootpath1="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/test/preUFSp4/gfs.${dateicA}/00/"
  rootpath2="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/test/UFSp4_base/gfs.${dateicA}/00/"

  expname1="PreYes"
  expname2="Base"

  domain="ice"; declare -a varlist=(aice_h Tsfc_h) 
  domain="ocn_2D_"; declare -a varlist=(SST MLD_0125 sensible) 
  
  for varname in ${varlist[@]}; do 
    length=${#varname}
    echo $varname
    case "$domain" in
        "phyf") nx=384; ny=384; ntile=6; nkind=3; varmin=4; varmax=134; domask=1 ;;
        "dynf") nx=384; ny=384; ntile=6; nkind=3 ; varmin=4; varmax=10; domask=0 ;;
        "ocn_2D_")  nx=1440; ny=1080; ntile=1; nkind=1 ; varmin=6; varmax=6;domask=0 ;;
        "ice")  nx=1440; ny=1080; ntile=1; nkind=1 ; varmin=16; varmax=16; domask=2 ;;
    esac

# Create parameter file
    cat << EOF > param.F90
       module param
       implicit none
       integer, parameter  :: nx = $nx, ny = $ny, nt=1, ntile=$ntile,nkind=$nkind, nexp=$nexp 
       integer, parameter  :: domask=$domask, varmin=$varmin, varmax=$varmax
       character (len=$length)  :: varwant="$varname"
       end module param
EOF

    cat << EOF > Makefile
CDF=$CDF
FOPT = -O2
F90 = ifort
opt1 = -Duse_m6c5
opt2 = -mcmodel=medium 
optall = \$(opt1) \$(opt2) \$(opt3) \$(opt4)
OBJS = param.o ncsubs.o stats.o limited.o 
runlimited: \$(OBJS) 
	\$(F90) \$(FOPT) -o runlimited \$(OBJS) -L\$(CDF)/lib -lnetcdff -lnetcdf 
%.o: %.F90
	\$(F90) \$(FOPT) \$(optall) -c -I\$(CDF)/include $<
	cpp \$(optall) -I\$(CDF)/include \$*.F90>\$*.i
clean:
	/bin/rm -f runlimited *.o *.i *.mod
EOF

make clean
make

### LOOP OVER FORECAST LEADS
# Forecast lead 

      for (( lead=$leadstart; lead<=$leadend; lead+=$leadstep )); do

         datefcstA=`date '+%C%y%m%d' -d "$dateicA+$lead days"`
         yyyyfcstA=${datefcstA:0:4}
         mmfcstA=${datefcstA:4:2}
         ddfcstA=${datefcstA:6:2}

         datefcstB=`date '+%C%y%m%d' -d "$dateicB+$lead days"`
         yyyyfcstB=${datefcstB:0:4}
         mmfcstB=${datefcstB:4:2}
         ddfcstB=${datefcstB:6:2}
  
#
         extn1="${datefcstA}${hh}.01.${dateicA}${hh}.nc"
         extn2="${datefcstB}${hh}.01.${dateicB}${hh}.nc"

         extn3="${datefcstA}${hh}.01.${dateicA}${hh}.nc"

         if [  -f $rootpath1/$domain${extn1}.gz ] ; then gunzip -q $rootpath1/$domain$extn1  ; fi
         if [  -f $rootpath2/$domain${extn2}.gz ] ; then gunzip -q $rootpath2/$domain$extn2  ; fi
         if [  -f $rootpath3/$domain${extn3}.gz ] ; then gunzip -q $rootpath3/$domain$extn3  ; fi


         tag=$yyyyfcstA$mmfcstA$ddfcstA

#
         patharg=""
         exparg=""
         declare -a path=($rootpath1 $rootpath2 $rootpath3)
         declare -a expname=($expname1 $expname2 $expname3)
         declare -a extn=($extn1 $extn2 $extn3)
         for (( i=0 ; i<$nexp; i+=1 )) ; do
            patharg="${patharg} ${path[$i]}$domain${extn[$i]}"
            exparg="${exparg} ${expname[$i]}"
         done
         ./runlimited  $patharg $exparg $tag
         echo $tag
     done    # end loop for lead
done # end loop for variable


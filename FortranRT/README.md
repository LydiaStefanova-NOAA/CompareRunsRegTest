# CompareRunsRT: 

Compare simple statistics of two or three runs obtained from the regression test system. 

Everything that needs to be edited for a new run is in "runcompare.sh" (or, alternatively, in "limited.sh", which allows for selection of variables by name - see varlist, and saves output to separate files for each variable in the list)

To run comparisons, edit these lines in script "runcompare.sh" (or "limited.sh") before executing

NB: Currently set up to run on Hera. To run on a different system, make sure that the correct intel and netcdf modules are loaded 
(If loading different intel and netcdf modules, change CDF=/apps/netcdf/4.7.0/intel/18.0.5.274 accordingly
For example on Orion, module load intel; module load netcdf; CDF=/apps/intel-2020/netcdf-4.7.2)

nexp=3    # number of experiments (if nexp=2, expname3 and rootpath3 can be left blank)  

expname1="IPD"   # Best if <5 characters (used for labeling)
expname2="CCPP"  # Best if <5 characters (used for labeling)
expname3="CCP2"  # Best if <5 characters (used for labeling)

rootpath1="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/forRegTest/IPD/"   # path to output of exp1
rootpath2="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/forRegTest/CCPP/"  # path to output of exp2
rootpath3="/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/fromHPSS/forRegTest/CCPP/"  # path to output of exp3

domain="atm"; file="phyf"; extn="840.tile"    # use this for atmospheric phyf840.tile$NTILE.nc  files  
\#domain="ocn"; file="ocn"; extn="_2013_04_01_03.nc"  # use this for oceanic ocn_2013_04_01_03.nc files  
\#domain="ice"; file="ice"; extn="h_06h.2013-04-11-00000.nc"  # use this for ice iceh_06h.2013-04-11-00000.nc files  
  
varmin and varmax specify the number of the first and last variable of interest in the netcdf (for runcompare.sh)
varlist specifies the names of variables to be compared (for limited.sh)

Executing the script will:   
    1) update the parameters in param.F90  
    2) create a Makefile  
    3) compile (using that Makefile) and create an executable "runcompare"  
    4) run the executable with the experiment names/paths specified above for the chosen component (ocn/ice/atm)  
    
An excerpt from the comparison run for the atmospheric phyf output is below.   
For each variable, the variable id (in this case 4) and name (in this case acond) are shown at the top.     
STYP: For variables from phyf, surface type (0=ocean, 1=land, 2=ice); for variables for other files - always 0, no meaning attached    
VALD: number of valid points (i.e., points with the given STYP and non-missing data)     
MIN/MAX/MEAN: self-explanatory   
RMS : RMS difference between two experiments  
SRMS: RMS difference divided by the mean   
%UP : % of points within the given STYP that have increased in value between the two runs   
%DN : % of points within the given STYP that have decreased in value between the two runs   
*note that  %UP and %DN don't add up to 0 because the points with no change are not assigned to either   

```
 =========================
  4    acond                         
 -------------------------
  
              STYP        VALD          MIN           MAX          MEAN           RMS          SRMS           %UP           %DN
  
         IPD     0      587537     0.486E-04     0.687E-01     0.942E-02
        CCPP     0      587146     0.486E-04     0.594E-01     0.973E-02
 IPD vs CCPP     0      586232    -0.520E-01     0.681E-01    -0.313E-03     0.729E-02         0.749        47.733        52.267
  
         IPD     1      259125     0.694E-04     0.241E+00     0.241E-01
        CCPP     1      259125     0.694E-04     0.331E+00     0.249E-01
 IPD vs CCPP     1      259125    -0.297E+00     0.206E+00    -0.830E-03     0.187E-01         0.751        47.193        52.807
  
         IPD     2       38074     0.697E-04     0.765E-01     0.200E-01
        CCPP     2       38465     0.697E-04     0.887E-01     0.157E-01
 IPD vs CCPP     2       37160    -0.876E-01     0.718E-01     0.427E-02     0.164E-01         1.045        58.778        41.222
 ```

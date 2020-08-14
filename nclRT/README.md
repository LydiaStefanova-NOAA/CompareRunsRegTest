# CompareRunsRT-NCL

two_compare.sh plots the differences between fields on atmospheric tiles (joined over the globe) for a range of variables. specified by their ordering number in the netcdf file. The number corresponding to a variable can be read from  
"numvarlist.txt". 

E.g., specifying 
varnum1=110 
varnum2=112
Will do tmpsfc, tprcp, trans_ave

To save the plot, set "hardcopy=yes". 

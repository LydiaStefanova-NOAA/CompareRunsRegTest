#!/bin/bash -l
#SBATCH -A marine-cpu        # -A specifies the account
#SBATCH -n 1                 # -n specifies the number of tasks (cores) (-N would be for number of nodes) 
#SBATCH --exclusive          # exclusive use of node - hoggy but OK
#SBATCH -q debug             # -q specifies the queue; debug has a 30 min limit, but the default walltime is only 5min, to change, see below:
#SBATCH -t 30                # -t specifies walltime in minutes; if in debug, cannot be more than 30
#

   #module load intel/19.0.5.281
   module load intel
   module load ncl


hours="003-072"
ystart=2013; yend=2013; ystep=1
mstart=1; mend=1; mstep=3
makeplot="yes"
hardcopy="no"

for (( yyyy=$ystart; yyyy<=$yend; yyyy+=ystep )) ; do
for (( mm1=$mstart; mm1<=$mend; mm1+=mstep )) ; do
    mm=$(printf "%02d" $mm1)
    tag=$yyyy${mm}0100
    echo $tag

    dirA=/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/RegressionTests/IPDvsCCPP/Data/IPD/$tag/
    dirB=/scratch1/NCEPDEV/stmp2/Lydia.B.Stefanova/RegressionTests/IPDvsCCPP/Data/CCPP/$tag/

    descriptorA="IPD"
    descriptorB="CCPP"
    

cat << EOF > rms_baseline_compare.${hours}.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  path0_A="$dirA"
  path0_B="$dirB"
 
  print(" ")
  print(" "+"$descriptorA"+" directory: "+path0_A)
  print(" "+"$descriptorB"+" directory: "+path0_B)
  print(" ")

  tiledata = "phyf.${hours}.tile1.nc"
  fin = addfile(path0_A+tiledata,"r")


  x=fin->land(0,:,:)             ; land mask
  dims=dimsizes(x)               ; dimensions 
  imax=dims(0)*dims(1)*6         ; total number of gridpoints in all 6 tiles

  var_A=new((/imax/),typeof(x))
  var_B=new((/imax/),typeof(x))

  land_A=new((/imax/),typeof(x))
  land_B=new((/imax/),typeof(x))

  lonn=new((/imax/),typeof(x))
  latn=new((/imax/),typeof(x))
  coslat=new((/imax/),typeof(x))

  vNames = getfilevarnames(fin)
  nNames = dimsizes(vNames)

  in=0
  do tile=1,6
     fv3 = "phyf.${hours}.tile"+tile+".nc"
     fin_A=addfile(path0_A+fv3,"r")
     fin_B=addfile(path0_B+fv3,"r")
     x_A=fin_A->land(0,:,:)
     x_B=fin_B->land(0,:,:)
     lon=fin_A->grid_xt
     lat=fin_A->grid_yt
     do ii=0,dims(0)-1
     do jj=0,dims(1)-1
        land_A(in)=x_A(ii,jj)
        land_B(in)=x_B(ii,jj)
        lonn(in)=tofloat(lon(ii,jj))
        latn(in)=tofloat(lat(ii,jj))
        in=in+1
     end do
     end do
  end do    ; end do on do tile=1,6
 
  ;do n = 103,105     ; tmp2m, tmax2m, tmin2m
  do n = 110,110          ; tmpsfc
  ;do n = 123, nNames-1

   ;do n = 3, 46
   ;do n = 47, 90
   ;do n = 91, nNames -1
   ;do n = 110,112 


  in=0


  do tile=1,6
     fv3 = "phyf.${hours}.tile"+tile+".nc"
     fin_A=addfile(path0_A+fv3,"r")
     fin_B=addfile(path0_B+fv3,"r")
     x_A=fin_A->\$vNames(n)\$(0,:,:)
     x_B=fin_B->\$vNames(n)\$(0,:,:)
     do ii=0,dims(0)-1
     do jj=0,dims(1)-1
        var_A(in)=x_A(ii,jj)
        var_B(in)=x_B(ii,jj)
        in=in+1
     end do
     end do

  end do    ; end do on do tile=1,6

  varname=vNames(n)
  var_diffAB=var_A
  var_diffAB=var_A-var_B


if isStrSubset("$makeplot", "yes")
   if isStrSubset("$hardcopy", "yes" )
      wks = gsn_open_wks("png", varname + ".$tag.$hours")
   else
      wks = gsn_open_wks("x11", "contour_map")
   end if


;-- set resources

  res                   = True
  res@gsnMaximize       = False     ; maximize plot in frame
  res@cnFillOn          = True     ; turn on contour fill
  res@cnFillPalette     = "ncl_default"   ; define color map for contours
  res@cnFillMode          = "RasterFill"
  res@cnLinesOn         = False    ; turn off contour lines
  res@cnLineLabelsOn    = False    ; turn off line labels
  res@sfXArray          = lonn     ; Only necessary if x doesn't 
  res@sfYArray          = latn     ; contain 1D coordinate arrays

;-- draw the contour map
  plot=new(3,graphic)

  res@gsnDraw             = False                          ; don't draw
  res@gsnFrame            = False                          ; don't advance frame
  res2=res
   lev = max(var_diffAB)
   if (abs(min(var_diffAB)) .gt.  max(var_diffAB)) then
      lev=abs(min(var_diffAB))*0.6
   end if
   lev = lev
   lev = stringtofloat(sprintf("%6.1g",lev))
   res2@cnLevelSelectionMode = "ManualLevels"
 
   res2@cnMinLevelValF      = -lev
   res2@cnMaxLevelValF      = lev
   res2@cnLevelSpacingF = lev/11.
 
   res2@cnFillPalette       = "nrl_sirkes"

  plot(2) = gsn_csm_contour_map(wks,var_A,res)
  plot(1) = gsn_csm_contour_map(wks,var_B,res)
  plot(0) = gsn_csm_contour_map(wks,var_diffAB,res2)

  panelopts                   = True
  panelopts@gsnPanelMainString = varname
  panelopts@amJust   = "TopLeft"
  panelopts@gsnOrientation    = "landscape"
  panelopts@gsnPanelLabelBar  = False
  panelopts@gsnPanelRowSpec   = True
  panelopts@gsnMaximize       =  False                         ; maximize plot in frame
  panelopts@gsnBoxMargin      = 10
  panelopts@gsnPanelYWhiteSpacePercent = 10
  panelopts@gsnPanelXWhiteSpacePercent = 5
  panelopts@amJust   = "TopLeft"
  gsn_panel(wks,plot,(/1,1,1/),panelopts)
end if 
  
  end do    ; end do on nName

  end
  
EOF

ncl -n rms_baseline_compare.${hours}.ncl 


done
done



program compare_models
  use param
  use netcdf

  implicit none
  integer                            :: i,ikind,iexp,itile,varid, flag
  character (len = 300)              :: filename(nexp,ntile),expname(nexp),varname,path(nexp),diffname
  character (len=15)                :: fileout
  character (len=10)                   :: tag
  character (len = 1)                :: tilenum
  real,dimension(nexp,ntile,nx,ny)   :: dataA, maskA, maskIN
  integer,dimension(nexp,0:nkind-1)  :: countA, countAB
  real,dimension(nexp,0:nkind-1)     :: minA, maxA, meanA
  real,dimension(nexp,0:nkind-1)     :: minAB, maxAB, meanAB,rmsAB,pnuAB,pndAB

  
  write(fileout,'(2a)') trim(varwant),'.txt'
  print *,fileout
  open (unit=2, file = fileout,access='append')

  do iexp=1,nexp
     call getarg(iexp,path(iexp))
     call getarg(nexp+iexp,expname(iexp))
  !   print *,iexp,domask
  end do
     call getarg(2*nexp+1,tag)
     do itile = 1, ntile
        write(tilenum,"(I1)") itile
        do iexp = 1, nexp
           if (domask.eq.1) then
              filename(iexp,itile)=trim(path(iexp))//tilenum//".nc"
              call readbyname  (filename(iexp,itile), maskIN(iexp,itile,:,:)  , "land",varid,flag)
           else
              filename(iexp,itile)=trim(path(iexp))
              if (domask.eq.2) then
              call readbyname  (filename(iexp,itile), maskIN(iexp,itile,:,:)  , "aice_h",varid,flag)
               end if
          end if
  !      print *,iexp,itile,filename(iexp,itile)
        end do
     end do

  do varid = 1,1
     do itile = 1, ntile
        do iexp = 1, nexp
           varname=varwant
           call readbyname  (filename(iexp,itile), dataA(iexp,itile,:,:)  ,varname,varid,flag)
          ! print *,"reading", varname, varid
        end do
     end do

     maskA=0
     if (domask.eq.1) then
        maskA=maskIN
     end if
     if  (domask.eq.2) then
        where(abs(maskIN).le.0) 
             maskA=3
        end where
     end if

     where (abs(dataA).gt.1e15)
        maskA=3              !mask out cases of NAN in data
     end where
   
     if (flag.eq.0 ) then 
     do ikind = 0, nkind-1
        do iexp=1,nexp
           call statsalone(dataA(iexp,:,:,:), maskA(iexp,:,:,:),ikind, &
                           countA(iexp, ikind), minA(iexp,ikind), maxA(iexp,ikind), meanA(iexp,ikind))
           call statscross(dataA(iexp,:,:,:), maskA(iexp,:,:,:),&
                           dataA(nexp,:,:,:), maskA(nexp,:,:,:), ikind, & 
                           countAB(iexp, ikind), minAB(iexp,ikind), maxAB(iexp,ikind), meanAB(iexp,ikind), &
                           pnuAB(iexp, ikind), pndAB(iexp,ikind), rmsAB (iexp,ikind))
        end do
     end do

!===OUTPUT TO SCREEN
!23456789123456789123456789123456789123456789 
     print*, 'about to write'
     write(2,fmt='(a)')"========================="
     write(2,fmt=10) varid,varname,tag
     write(2,fmt='(a)')"-------------------------"
     write(2,fmt='(a)')" "
     write(2,fmt=100) "STYP","VALD"," MIN"," MAX","MEAN"," RMS","SRMS"," %UP"," %DN"
     write(2,fmt='(a)')" "
     do ikind = 0, nkind-1 
        do iexp=1,nexp
           write(2,1000) trim(expname(iexp)),&
                      ikind,countA(iexp,ikind),minA(iexp,ikind),maxA(iexp,ikind), meanA(iexp,ikind)
        end do
        do iexp=1,nexp-1
           !diffname=trim(expname(iexp))//" vs "//trim(expname(nexp))
           write(diffname,'(a5, a4, a5)')trim(expname(iexp))," vs ",trim(expname(nexp))
           write(2,fmt=1000) diffname,&
                      ikind,countAB(iexp,ikind),minAB(iexp,ikind),maxAB(iexp,ikind),meanAB(iexp,ikind),&
                      rmsAB(iexp,ikind),rmsAB(iexp,ikind)/abs(meanA(nexp,ikind)),&
                      pnuAB(iexp,ikind)*100,pndAB(iexp,ikind)*100
        end do
        !print *,"RMSratio", rmsAB(1,ikind)/rmsAB(2,ikind)
        write(2,fmt='(a)')" "
     end do
     end if
  end do
  close(unit=2)
 10   format (i3,4x,a20,4x,a10)
 100  format (14x,a5,8x,a4,8(9x,a4,x))
 1000 format (a14,4x,i2,4x,i8,4(4x,e10.3),3(4x,f10.3))
end program compare_models 


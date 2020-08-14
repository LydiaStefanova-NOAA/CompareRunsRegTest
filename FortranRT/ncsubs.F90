  subroutine check(status, flag)
    use netcdf
    use param
    integer, intent ( in) :: status
    integer, intent (out) :: flag
    flag=0
    if(status /= nf90_noerr) then
  !    print *, trim(nf90_strerror(status))
  !    stop "Stopped"
       flag=1
    end if
  end subroutine check

  subroutine readlatlon(filename,lat,lon,varlat,varlon,flag)
    use netcdf
    use param
    character(len=*),intent(in)       :: filename,varlat,varlon
    real,intent(out)                  :: lon(nx),lat(ny)
    integer, intent(out)              :: flag
    integer                           :: ncid, varid
    call check( nf90_open(filename, nf90_nowrite, ncid) ,flag)
    call check( nf90_inq_varid(ncid, varlon, varid) ,flag)
    call check( nf90_get_var(ncid, varid, lon),flag)
    call check( nf90_inq_varid(ncid, varlat, varid) ,flag)
    call check( nf90_get_var(ncid, varid, lat),flag)
    call check( nf90_close(ncid) ,flag)
  end subroutine readlatlon

  subroutine readbynumber(filename,array,varname,varid,flag)
    use netcdf
    use param
    integer,intent(in)                :: varid
    character(len=*),intent(in)       :: filename
    integer, intent(out)              :: flag
    integer                           ::  dummy
    real,intent(out) :: array(nx,ny,nt)
    character(len=30)                 :: varname
    integer                           :: ncid
    call check( nf90_open(filename, nf90_nowrite, ncid) ,dummy)
    call check (nf90_inquire_variable(ncid, varid, varname),flag)
    if (flag.ne.1) then
       call check( nf90_get_var(ncid, varid, array),flag)
    end if
    call check( nf90_close(ncid) ,dummy)
  end subroutine readbynumber

  subroutine readbyname(filename,array,varname,varid,flag)
    use netcdf
    use param
    character(len=*),intent(in)       :: filename,varname
    integer, intent(out)              :: flag
    real,intent(out) :: array(nx,ny,nt)
    integer                           :: ncid, varid
    call check ( nf90_open(filename, nf90_nowrite, ncid),flag)
    call check ( nf90_inq_varid(ncid, varname, varid),flag)
    call check ( nf90_get_var(ncid, varid, array),flag)
    call check ( nf90_close(ncid) ,flag)

  end subroutine readbyname

  subroutine weights (wgt,lat)
    use param
    real,intent(in)      :: lat(ny)
    real,intent(out)     :: wgt(ny)
    real                 :: pi
    pi  = acos (-1.)
    wgt = cos(lat*pi/180.)
  end subroutine weights

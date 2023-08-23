program main
  implicit none
  character(500) :: wkdir
  integer :: NOS, NODmax, NODmin
  real(8) :: SPIN, SPIN2, HX, HY, HZ, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  namelist/input_parameters/wkdir,NOS,NODmax,NODmin,SPIN,HX,HY,HZ,JX,JY,JZ,DX,DY,DZ,GX,GY,GZ
  integer :: i, j, k, l
  !
  read(30,input_parameters)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_hvec.dat",status='replace')
  do i = 1, NOS
    write(20,'(i8,3es23.15)') i, HX, HY, HZ
  end do
  !
  open(20,file=trim(adjustl(wkdir))//"/list_xyz_dm_gamma.dat",status='replace')
  do i = 1, NOS-1
    write(20,'(2i8,9es23.15)') i, i+1, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  end do
  j = 1
  write(20,'(2i8,9es23.15)') i, j, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_p1.dat",status='replace')
  do l = 3, NOS
    write(20,'(i8)') l
  end do
  do l = 1, 2
    write(20,'(i8)') l
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_NODmax.dat",status='replace')
  do l = 1, NOS
    if(mod(l,2)==1)then
      write(20,'(i8)') min(nint(SPIN*2.0d0),NODmax)
    else
      write(20,'(i8)') 1
    end if
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_spin.dat",status='replace')
  do l = 1, NOS
    if(mod(l,2)==1)then
      write(20,'(es23.15)') SPIN
    else
      write(20,'(es23.15)') 0.5d0
    end if
  end do
  close(20)
  !
end program main

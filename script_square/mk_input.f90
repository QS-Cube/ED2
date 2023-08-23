program main
  implicit none
  character(500) :: wkdir
  integer :: NOS, LX, LY, NODmax, NODmin
  integer :: iu = 1
  real(8) :: SPIN, HX, HY, HZ, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  namelist/input_parameters/wkdir,LX,LY,NOS,NODmax,NODmin,SPIN,HX,HY,HZ,JX,JY,JZ,DX,DY,DZ,GX,GY,GZ
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
  ! x direction
  do i = 1, NOS
    if(mod(i-1,LX) /= LX-1)then
      write(20,'(2i8,9es23.15)') i, i+1, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    else
      write(20,'(2i8,9es23.15)') i, i+1-LX, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    end if
  end do
  ! y direction
  do i = 1, NOS-LX
    write(20,'(2i8,9es23.15)') i, i+LX, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  end do
  j = 1
  do i = NOS-LX+1, NOS
    write(20,'(2i8,9es23.15)') i, j, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    j = j + 1
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_p1.dat",status='replace')
  do i = 1, NOS
    if(mod(i-1,LX) /= LX-1)then
      write(20,'(i8)') i + 1
    else
      write(20,'(i8)') i + 1 - LX
    end if
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_p2.dat",status='replace')
  do i = 1, NOS-LX
    write(20,'(i8)') i+LX
  end do
  j = 1
  do i = NOS-LX+1, NOS
    write(20,'(i8)') j
    j = j + 1
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_NODmax.dat",status='replace')
  do l = 1, NOS
    write(20,'(i8)') min(nint(SPIN*2.0d0),NODmax)
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_spin.dat",status='replace')
  do l = 1, NOS
    write(20,'(es23.15)') SPIN
  end do
  close(20)
  !
end program main

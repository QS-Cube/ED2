program main
  implicit none
  character(500) :: wkdir
  integer :: NOS, NODmax, NODmin
  integer :: iu = 1
  real(8) :: SPIN, HX, HY, HZ, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  real(8) :: JX2, JY2, JZ2, DX2, DY2, DZ2, GX2, GY2, GZ2
  namelist/input_parameters/wkdir,NOS,NODmax,NODmin,SPIN,HX,HY,HZ,JX,JY,JZ,DX,DY,DZ,GX,GY,GZ,JX2,JY2,JZ2,DX2,DY2,DZ2,GX2,GY2,GZ2
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
  ! NN
  do i = 1, NOS-1
    write(20,'(2i8,9es23.15)') i, i+1, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  end do
  j = 1
  write(20,'(2i8,9es23.15)') i, j, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  ! NNN
  do i = 1, NOS-2
    write(20,'(2i8,9es23.15)') i, i+2, JX2, JY2, JZ2, DX2, DY2, DZ2, GX2, GY2, GZ2
  end do
  j = 1
  write(20,'(2i8,9es23.15)') i, j, JX2, JY2, JZ2, DX2, DY2, DZ2, GX2, GY2, GZ2
  write(20,'(2i8,9es23.15)') i+1, j+1, JX2, JY2, JZ2, DX2, DY2, DZ2, GX2, GY2, GZ2
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_p1.dat",status='replace')
  do l = 2, NOS
    write(20,'(i8)') l
  end do
  l = 1
  write(20,'(i8)') l
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

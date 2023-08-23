program main
  implicit none
  character(500) :: wkdir
  integer :: NOS, NODmax, NODmin
  integer :: iu = 1
  real(8) :: SPIN, HX, HY, HZ, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
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
  do l = 2, NOS
    write(20,'(i8)') l
  end do
  l = 1
  write(20,'(i8)') l
  close(20)
  !
  ! open(20,file=trim(adjustl(wkdir))//"/list_p2.dat",status='replace')
  ! open(30,file=trim(adjustl(wkdir))//"/list_p3.dat",status='replace')
  ! open(40,file=trim(adjustl(wkdir))//"/list_p4.dat",status='replace')
  ! do l = 1, NOS
  !   write(20,'(i8)') l
  !   write(30,'(i8)') l
  !   write(40,'(i8)') l
  ! end do
  ! close(40)
  ! close(30)
  ! close(20)
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

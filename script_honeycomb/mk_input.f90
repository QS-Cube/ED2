program main
  implicit none
  character(500) :: wkdir
  integer :: NOS, L1, L2, NODmax, NODmin
  integer :: iu = 1
  real(8) :: SPIN, HX, HY, HZ, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  namelist/input_parameters/wkdir,L1,L2,NOS,NODmax,NODmin,SPIN,HX,HY,HZ,JX,JY,JZ,DX,DY,DZ,GX,GY,GZ
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
  do i = 1, NOS, 2
    write(20,'(2i8,9es23.15)')   i, i+1, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    if( mod(i,2*L1) == 2*L1-1 )then
      write(20,'(2i8,9es23.15)') i+1, i+2-2*L1, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    else
      write(20,'(2i8,9es23.15)') i+1, i+2, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    end if
    if( i+2*L1 > NOS )then
      write(20,'(2i8,9es23.15)') i+1, i+2*L1-NOS, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    else
      write(20,'(2i8,9es23.15)') i+1, i+2*L1, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
    end if
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_p1.dat",status='replace')
  do i = 1, NOS
    if(mod(i-1,2*L1) >= 2*L1-2)then
      write(20,'(i8)') i + 2 - 2*L1
    else
      write(20,'(i8)') i + 2
    end if
  end do
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_p2.dat",status='replace')
  do i = 1, NOS-2*L1
    write(20,'(i8)') i + 2*L1
  end do
  j = 1
  do i = NOS-2*L1+1, NOS
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

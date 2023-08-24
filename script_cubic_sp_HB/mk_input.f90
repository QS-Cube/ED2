module functions
contains
  integer function f_p(i,j,k,LX,LY,LZ)
    integer :: i, j, k, LX, LY, LZ
    f_p = i + LX*(j-1) + LX*LY*(k-1)
  end function f_p
end module functions

program main
  use functions
  implicit none
  character(500) :: wkdir
  integer :: NOS, LX, LY, LZ, NODmax, NODmin
  real(8) :: SPIN, HX, HY, HZ, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
  namelist/input_parameters/wkdir,LX,LY,LZ,NOS,NODmax,NODmin,SPIN,HX,HY,HZ,JX,JY,JZ,DX,DY,DZ,GX,GY,GZ
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
  open(30,file=trim(adjustl(wkdir))//"/list_p1.dat",status='replace')
  open(40,file=trim(adjustl(wkdir))//"/list_p2.dat",status='replace')
  open(50,file=trim(adjustl(wkdir))//"/list_p3.dat",status='replace')
  do i = 1, NOS
    ! x direction
    if(mod(i-1,LX) /= LX-1)then
      write(20,'(2i8,9es23.15)') i, i+1, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
      write(30,'(i8)') i + 1
    else
      write(20,'(2i8,9es23.15)') i, i+1-LX, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
      write(30,'(i8)') i + 1 - LX
    end if
    ! y direction
    if(mod(i-1,LX*LY) < LX*(LY-1))then
      write(20,'(2i8,9es23.15)') i, i+LX, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
      write(40,'(i8)') i + LX
    else
      write(20,'(2i8,9es23.15)') i, i+LX-LX*LY, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
      write(40,'(i8)') i + LX - LX*LY
    end if
    ! z direction
    if(i+LX*LY <= NOS)then
      write(20,'(2i8,9es23.15)') i, i+LX*LY, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
      write(50,'(i8)') i + LX*LY
    else
      write(20,'(2i8,9es23.15)') i, i+LX*LY-NOS, JX, JY, JZ, DX, DY, DZ, GX, GY, GZ
      write(50,'(i8)') i + LX*LY -NOS
    end if
  end do
  close(50)
  close(40)
  close(30)
  close(20)
  !
  open(20,file=trim(adjustl(wkdir))//"/list_p4.dat",status='replace')
  open(30,file=trim(adjustl(wkdir))//"/list_p5.dat",status='replace')
  open(40,file=trim(adjustl(wkdir))//"/list_p6.dat",status='replace')
  do k = 1, LZ
    do j = 1, LY
      do i = 1, LX
        write(20,'(i8)') f_p(LX-i+1,j,k,LX,LY,LZ)
        write(30,'(i8)') f_p(i,LY-j+1,k,LX,LY,LZ)
        write(40,'(i8)') f_p(i,j,LZ-k+1,LX,LY,LZ)
      end do
    end do
  end do
  close(40)
  close(30)
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

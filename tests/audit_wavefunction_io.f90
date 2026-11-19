! Round-trip every coefficient of 3 or 12 four-component wavefunctions.
! Compile with -fcheck=all to also exercise reading spaces smaller than 10.
program audit_wavefunction_io
  use input_param, only: psi,ene,FILE_wf,wr_wf,re_wf,write_wf,read_wf
  implicit none
  integer, parameter :: dim=4
  integer :: nvec,i,j
  character(16) :: arg
  character(64) :: name
  complex(8), allocatable :: expected(:,:)
  real(8), allocatable :: energies(:)
  logical :: exists
  call get_command_argument(1,arg)
  read(arg,*)nvec
  allocate(psi(dim,nvec),ene(nvec),expected(dim,nvec),energies(nvec))
  do j=1,nvec
    do i=1,dim
      expected(i,j)=cmplx(dble(10*j+i),dble(j-i),8)/32.0d0
    end do
    energies(j)=dble(j)/16.0d0
  end do
  psi=expected
  ene=energies
  FILE_wf='./'
  wr_wf=1
  re_wf=1
  call write_wf(dim,1,nvec,nvec,ene)
  do j=1,nvec
    write(name,'(A,I0,A)')'wf',j,'.bin'
    inquire(file=trim(name),exist=exists)
    if(.not.exists)error stop 'A distinct wavefunction filename is missing'
  end do
  deallocate(psi,ene)
  call read_wf(dim,1,nvec,nvec)
  if(any(psi/=expected))error stop 'Wavefunction round-trip changed coefficients'
  if(any(ene/=energies))error stop 'Wavefunction round-trip changed energies'
  print *, 'AUDIT_WAVEFUNCTION_IO_PASS'
end program audit_wavefunction_io

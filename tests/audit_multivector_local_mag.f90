! Independent two-vector observable regression:
! Both columns contain the same fully polarized state, so every reported
! local magnetization must agree. A visited-orbit bitmap shared between
! eigenvectors incorrectly leaves the second set uncomputed.
program audit_multivector_local_mag
  use input_param, only: NOS,NODmax,NODmin,L1,L2,L3,L4,L5,L6, &
    local_spin,local_NODmax,list_s,list_r,explist,OUTDIR, &
    shift_1,shift_2,shift_3,shift_4,shift_5,shift_6
  use state_lists, only: get_cum_ltd_rep_combination
  use get_expectation_values, only: get_lm
  implicit none
  complex(8) :: vectors(3,2)
  real(8) :: observed(3,2)
  integer :: i, site, unit, io_status

  NOS=2
  NODmin=0
  NODmax=1
  L1=1; L2=1; L3=1; L4=1; L5=1; L6=1
  allocate(local_spin(2),local_NODmax(2),list_s(3),list_r(3), &
    explist(1,1,1,1,1,1),shift_1(0:2),shift_2(0:2), &
    shift_3(0:2),shift_4(0:2),shift_5(0:2),shift_6(0:2))
  local_spin=0.5d0
  local_NODmax=1
  list_s=[1,2,3]
  list_r=1.0d0
  explist=(1.0d0,0.0d0)
  shift_1=[0,1,2]
  shift_2=shift_1; shift_3=shift_1
  shift_4=shift_1; shift_5=shift_1; shift_6=shift_1
  call get_cum_ltd_rep_combination(NOS,NODmax,NODmin,local_NODmax)

  vectors=(0.0d0,0.0d0)
  vectors(1,:)=(1.0d0,0.0d0)
  OUTDIR='./'
  call get_lm(vectors,NODmax,NODmin,3,2,NOS)

  open(newunit=unit,file='local_mag.dat',status='old',action='read',iostat=io_status)
  if(io_status/=0)error stop 'Missing two-vector local_mag.dat'
  do i=1,NOS
    read(unit,*,iostat=io_status) site,observed(:,1),observed(:,2)
    if(io_status/=0)error stop 'Malformed two-vector magnetization row'
    if(site/=i)error stop 'Wrong site ordering in two-vector magnetization'
    if(any(abs(observed(1:2,:))>1.0d-12)) &
      error stop 'Unexpected transverse local magnetization'
    if(any(abs(observed(3,:)-0.5d0)>1.0d-12)) &
      error stop 'Incorrect or uninitialized two-vector local magnetization'
  end do
  read(unit,*,iostat=io_status) site
  if(io_status>=0)error stop 'Unexpected extra magnetization row'
  close(unit)
  print *, 'AUDIT_MULTIVECTOR_LOCAL_MAG_PASS'
end program audit_multivector_local_mag

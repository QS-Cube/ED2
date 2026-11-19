! Enumerate a symmetry basis without allocating a Hamiltonian or invoking a solver.
program audit_basis_driver
  use input_param
  use state_lists
  implicit none
  integer :: i
  call read_ip
  call get_cum_ltd_rep_combination(NOS,NODmax,NODmin,local_NODmax)
  if(NODmax>0)then
    THS=cum_ltd_rep_combination(NOS,NODmax)
  else
    THS=1
  end if
  call allocate_lists_omp_SQ
  open(20,file='representatives.dat',status='replace')
  do i=1,THS
    write(20,'(i12,es26.16)')list_s(i),list_r(i)
  end do
  close(20)
  write(*,'(a,i0)')'AUDIT_BASIS_DIMENSION=',THS
end program audit_basis_driver

module get_expectation_values
  implicit none
contains
  !
  subroutine get_lm(psi,NODmax,NODmin,dim,nvec,NOS)
    use input_param, only: OUTDIR
    use ham2vec, only: calcu_lm
    integer, intent(in) :: NODmax, NODmin, nvec, NOS
    integer, intent(in) :: dim
    complex(8), intent(in) :: psi(1:dim,1:nvec)
    integer :: j, k
    integer :: non, no_tot
    real(8), allocatable :: expe_lm(:,:,:)
    integer, allocatable :: list_n(:), list_check(:)
    !
    allocate(expe_lm(3,NOS,nvec),list_n(NOS),list_check(NOS))
    expe_lm=-9.999d0
    list_check=0
    do k = 1, nvec
      no_tot = 0
      do j = 1, NOS
        if(no_tot == NOS)then
          exit
        end if
        call mk_list_n(list_n,list_check,non,NOS,j)
        if(non==0)then
          cycle
        else
          no_tot = no_tot + non
          call calcu_lm(psi(1,k),dim,NODmax,NODmin,expe_lm(1,1,k),NOS,list_n,non)
        end if
      end do
    end do
    !
    write(*,'(" ### write ouput/local_mag.dat. ")')
    open(10,file=trim(adjustl(OUTDIR))//'local_mag.dat',position='append')
    do j = 1, NOS
      write(10,'(i8,10000es23.15)') j, ( expe_lm(1:3,j,k), k=1, nvec )
    end do
    close(10)
    !
    return
    !
  end subroutine get_lm
  !
  subroutine get_cf(psi,NODmax,NODmin,dim,nvec)
    use input_param, only: NO_two_cf, p_two_cf, OUTDIR
    use ham2vec, only: calcu_cf
    implicit none
    integer, intent(in) :: NODmax, NODmin, nvec
    integer, intent(in) :: dim
    complex(8), intent(in) :: psi(1:dim,1:nvec)
    complex(8), allocatable :: expe_cf(:,:,:)
    integer :: j, k, non
    !
    allocate(expe_cf(9,NO_two_cf,nvec))
    do k = 1, nvec
      do j = 1, NO_two_cf
        call calcu_cf(psi(1,k),dim,NODmax,NODmin,expe_cf(1,j,k),p_two_cf(1,j))
      end do
    end do
    !
    write(*,'(" ### write ouput/two_body_cf_z+-.dat. ")')
    open(10,file=trim(adjustl(OUTDIR))//'two_body_cf_z+-.dat',position='append')
    do j = 1, NO_two_cf
      write(10,'(2i8,10000es23.15)') p_two_cf(1:2,j), ( expe_cf(1:9,j,k), k=1, nvec )
    end do
    close(10)
    !
    write(*,'(" ### write ouput/two_body_cf_xyz.dat. ")')
    open(10,file=trim(adjustl(OUTDIR))//'two_body_cf_xyz.dat',position='append')
    do j = 1, NO_two_cf
      write(10,'(2i8,10000es23.15)') p_two_cf(1:2,j), ( &
        dble( ( expe_cf(9,j,k)+expe_cf(8,j,k)+expe_cf(6,j,k)+expe_cf(5,j,k) )*0.25d0 ), &
        dble( ( expe_cf(9,j,k)-expe_cf(8,j,k)+expe_cf(6,j,k)-expe_cf(5,j,k) )*(0.0d0,-0.25d0) ), &
        dble( ( expe_cf(7,j,k)+expe_cf(4,j,k) )*0.5d0 ), &
        dble( ( expe_cf(9,j,k)+expe_cf(8,j,k)-expe_cf(6,j,k)-expe_cf(5,j,k) )*(0.0d0,-0.25d0) ), &
        dble( ( expe_cf(9,j,k)-expe_cf(8,j,k)-expe_cf(6,j,k)+expe_cf(5,j,k) )*(-0.25d0) ), &
        dble( ( expe_cf(7,j,k)-expe_cf(4,j,k) )*(0.0d0,-0.5d0) ), &
        dble( ( expe_cf(3,j,k)+expe_cf(2,j,k) )*0.5d0 ), &
        dble( ( expe_cf(3,j,k)-expe_cf(2,j,k) )*(0.0d0,-0.5d0) ), &
        dble( ( expe_cf(1,j,k) ) ), &
        k = 1, nvec )
    end do
    close(10)
    !
    return
  end subroutine get_cf
  !
  subroutine mk_list_n(list_n,list_check,non,NOS,n) 
    use input_param, only: L1,L2,L3,shift_1,shift_2,shift_3
    integer,intent(in)  :: n, NOS 
    integer,intent(out) :: list_n(NOS), list_check(NOS), non
    integer :: i,j,k
    integer :: nd
    if(list_check(n)==1)then
      non = 0
      return
    else
      nd = n
      do k = 1, L3
        nd = shift_3(nd)
        do j = 1, L2
          nd = shift_2(nd)
          do i = 1, L1
            nd = shift_1(nd)
            if(nd<n)then
              non = 0
              return
            end if
          end do
        end do
      end do
    end if
    !
    non = 1
    list_n(non) = n
    list_check(n) = 1
    !
    nd = n
    do k = 1, L3
      nd = shift_3(nd)
      do j = 1, L2
        nd = shift_2(nd)
        do i = 1, L1
          nd = shift_1(nd)
          if(list_check(nd)==0)then
            non = non + 1
            list_n(non) = nd
            list_check(nd) = 1
          end if
        end do
      end do
    end do
    !
  end subroutine mk_list_n
  !
end module get_expectation_values

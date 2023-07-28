module input_param
  implicit none
  integer :: NOS       ! number of sites
  integer :: NODmax    ! Upper limit value for number of down spins
  integer :: NODmin    ! Lower limit value for number of down spins
  integer :: NOV       ! Number of lowest eigenvectors used for computing static physical quantities.
  integer :: THS       ! Total Hilbelt space of the target space 
  integer :: NO_one    ! number of one-body interactions
  integer :: NO_two    ! number of two-body interactions
  integer :: ALG       ! 1:Conventional Lanczos,  2:Thick-Restarted Lanczos, 3:Full diagonalization
  integer, allocatable :: p_one(:)    ! locations of one-body interactions: p_one(1:NO_one)
  integer, allocatable :: p_two(:,:)  ! locations of two-body interactions: p_two(2,1:NO_two)
  real(8), allocatable :: Jint(:,:)   ! Jint(1:9 [Jx,Jy,Jz,Dx,Dy,Dz],1:NO_two)
  real(8), allocatable :: hvec(:,:)   ! magnetic_field(1:3[hx,hy,hz],1:NO_one)
  integer, allocatable :: local_NODmax(:)  ! local_NODmax(i) : NODmax for ith site 
  real(8), allocatable :: local_spin(:)    ! local_spin(i)   : spin for ith site 
  !
  integer :: cal_lm ! flag for expectation values of local magnetizations
  !
  integer :: re_wf, wr_wf
  !
  character(100) :: FILE_xyz_dm_gamma, FILE_hvec, FILE_p1, FILE_p12, FILE_NODmax, FILE_spin, FILE_wf
  character(100) :: FILE_S1, FILE_S2, FILE_S3
  character(100) :: OUTDIR
  !
  integer :: L1, L2, L3
  integer :: M1, M2, M3
  real(8) :: PI, rk1, rk2, rk3
  integer, allocatable :: list_s(:)
  real(8), allocatable :: list_r(:)
  integer, allocatable :: shift_1(:), shift_2(:), shift_3(:)
  complex(8), allocatable :: explist(:,:,:)
  !
  integer :: cal_cf     ! flag for expectation values of two-body correlation functions
  integer :: NO_two_cf  ! number of two-body correlation functions we want to calculate
  integer, allocatable :: p_two_cf(:,:)  ! (i,j) pairs of two-body correlation functions: p_two_cf(2,1:NO_two_cf)
  character(100) :: FILE_two_cf
  !
  namelist /input_parameters/ NOS,NODmax,NODmin,L1,L2,L3,M1,M2,M3,NO_one,NO_two, &
    ALG, FILE_xyz_dm_gamma, FILE_hvec, &
    OUTDIR, FILE_S1, FILE_S2, FILE_S3, FILE_NODmax, FILE_spin, FILE_wf, re_wf, wr_wf, &
    cal_lm, cal_cf, NO_two_cf, FILE_two_cf
  !
  real(8), allocatable :: ene(:)
  complex(8),allocatable :: psi(:,:) 
  !
contains
  !
  subroutine read_ip 
    integer :: i,j,k
    integer :: tmp
    !
    write(*,'(" ### Read input_parameters. ")')
    read(*,input_parameters)
    write(*,input_parameters)
    !
    write(*,'(" ### Set wavevectors. ")')
    PI = acos(-1.0d0)
    rk1 = 2.0d0 * PI * dble(M1)/dble(L1) 
    rk2 = 2.0d0 * PI * dble(M2)/dble(L2) 
    rk3 = 2.0d0 * PI * dble(M3)/dble(L3) 
    !
    write(*,'(" ### Set random_seed. ")')
    call random_seed
    !
    write(*,'(" ### Allocation arrays. ")')
    allocate(p_one(NO_one),p_two(2,NO_two),Jint(9,NO_two),hvec(3,NO_one),shift_1(0:NOS),&
      shift_2(0:NOS),shift_3(0:NOS),explist(0:L1,0:L2,0:L3),local_NODmax(NOS),local_spin(NOS))
    !
    write(*,'(" ### Set phase factors. ")')
    forall(i=0:L1,j=0:L2,k=0:L3) explist(i,j,k) = &
      exp((0.0d0,1.0d0)*(rk1*dble(i)+rk2*dble(j)+rk3*dble(k)))
    !
    write(*,'(" ### Read FILE_xyz_dm_gamma. ")')
    open(10, file=trim(adjustl(FILE_xyz_dm_gamma)),status='old')
    do i = 1, NO_two
      read(10,*) p_two(1,i), p_two(2,i), Jint(1:9,i)
      if( p_two(1,i) > p_two(2,i) )then
        Jint(4:6,i) = -1.0d0 * Jint(4:6,i)
        tmp = p_two(1,i)
        p_two(1,i) = p_two(2,i)
        p_two(2,i) = tmp
      end if
    end do
    close(10)
    !
    write(*,'(" ### Read FILE_hvec. ")')
    open(10, file=trim(adjustl(FILE_hvec)),status='old')
    do i = 1, NO_one
      read(10,*) p_one(i), hvec(1:3,i)
    end do
    close(10)
    !
    write(*,'(" ### Set translational operations. ")')
    open(10, file=trim(adjustl(FILE_S1)),status='old')
    shift_1(0) = 0
    do i = 1, NOS
      read(10,*) shift_1(i)
    end do
    close(10)
    !
    open(10, file=trim(adjustl(FILE_S2)),status='old')
    shift_2(0) = 0
    do i = 1, NOS
      read(10,*) shift_2(i)
    end do
    close(10)
    !
    open(10, file=trim(adjustl(FILE_S3)),status='old')
    shift_3(0) = 0
    do i = 1, NOS
      read(10,*) shift_3(i)
    end do
    close(10)
    !
    write(*,'(" ### Read FILE_NODmax. ")')
    open(10, file=trim(adjustl(FILE_NODmax)),status='old')
    do i = 1, NOS
      read(10,*) local_NODmax(i)
    end do
    close(10)
    !
    write(*,'(" ### Read FILE_spin. ")')
    open(10, file=trim(adjustl(FILE_spin)),status='old')
    do i = 1, NOS
      read(10,*) local_spin(i)
    end do
    close(10)
    !
    if(cal_cf==1)then
      write(*,'(" ### Read FILE_two_cf. ")')
      allocate(p_two_cf(2,NO_two_cf))
      open(10, file=trim(adjustl(FILE_two_cf)),status='old')
      do i = 1, NO_two_cf
        read(10,*) p_two_cf(1,i), p_two_cf(2,i)
        if( p_two_cf(1,i) > p_two_cf(2,i) )then
          tmp = p_two_cf(1,i)
          p_two_cf(1,i) = p_two_cf(2,i)
          p_two_cf(2,i) = tmp
        end if
      end do
      close(10)
    end if
    !
    return
  end subroutine read_ip

  subroutine write_wf(dim,i_vec_min,i_vec_max, NOE, ene) 
    integer,intent(in)::dim
    integer,intent(in)::i_vec_min,i_vec_max
    integer,intent(in)::NOE
    real(8),intent(in)::ene(1:NOE)
    character(200)::file_name
    character(500)::file_name1
    integer::i_vec,i
    if(wr_wf /= 1) return

    do i_vec=i_vec_min, i_vec_max
      write(file_name,'(A100,A2,I1,A4)')trim(adjustl(FILE_wf)),'wf',i_vec,'.bin'
      write(*,*) " Write wave functions (",i_vec,"-th state) "
      print *, file_name
      open(10, file=trim(adjustl(file_name)), status='unknown', action='write', form='unformatted')
      write(10) psi(1:dim,i_vec)
      close(10)
    end do

    write(file_name1,'(A300,A10)')trim(adjustl(FILE_wf)),'energy.dat'
    open(10, file=trim(adjustl(file_name1)), form='formatted')
    do i=1, NOE
      write(10,'(2ES24.15)') dble(i), ene(i) 
    end do
    close(10)

    write(*,'("************************************************************************************")')
    return
  end subroutine write_wf

  subroutine read_wf(dim,i_vec_min, i_vec_max,NOE) 
    integer,intent(in)::dim
    integer,intent(in)::i_vec_min, i_vec_max
    integer,intent(in)::NOE
    character(200)::file_name
    character(500)::file_name1
    integer::i_vec, i
    real(8)::dummy
    if(re_wf /= 1) return

    allocate(psi(1:dim,i_vec_min:i_vec_max))
    do i_vec=i_vec_min, i_vec_max
      write(file_name,'(A100,A2,I1,A4)')trim(adjustl(FILE_wf)),'wf',i_vec,'.bin'
      write(*,*) " read wave functions (",i_vec,"-th state) "
      open(10, file=trim(adjustl(file_name)), form='unformatted')
      read(10) psi(1:dim,i_vec)
      close(10)
      write(*,*) "write psi(1:10,i_vec)"
      write(*,*) psi(1:10,i_vec)
      write(*,*) " finish reading wave function!"
    end do

    write(file_name1,'(A300,A10)')trim(adjustl(FILE_wf)),'energy.dat'
    allocate(ene(1:NOE))
    ene(1:NOE)=0.0d0
    open(10, file=trim(adjustl(file_name1)),status='old')
    do i=1, NOE
      read(10,*) dummy, ene(i) 
      write(*,*) dummy, ene(i), "reading!"
    end do
    close(10)
    write(*,*) "finish reading energy!"

    write(*,'("************************************************************************************")')
    return
  end subroutine read_wf

  subroutine write_index_ene(ene,NOE) 
    integer, intent(in) :: NOE
    real(8), intent(in) :: ene(NOE)
    integer :: i
    open(111,file=trim(adjustl(OUTDIR))//'eigenvalues.dat',position='append')
    do i=1, NOE
      write(111,'(i10, es23.15)') i, ene(i)
    end do
    close(111)
  end subroutine write_index_ene

end module input_param

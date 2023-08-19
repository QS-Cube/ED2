program main
  !$ use omp_lib
  use state_lists, only: get_cum_ltd_rep_combination,cum_ltd_rep_combination,allocate_lists_omp_SQ
  use input_param, only: read_ip, NOS, NODmax, NODmin, local_NODmax, THS, ALG, re_wf, ene, psi, write_wf, &
    write_index_ene, read_wf, re_wf, wr_wf, cal_lm, cal_cf
  use eigen_solver, only: my_trlanczos_routines_complex, i_vec_min, i_vec_max, NOE, &
    read_input_TRLan, Full_diag_routines
  use ham2vec, only: make_wk_loc_and_ele
  use lanczos, only: read_lanczos_para, lanczos_routines
  use get_expectation_values, only: get_lm, get_cf
  implicit none
  !$ real(8) :: st, en
  !$ st = omp_get_wtime()
  write(*,'("********************************* Start QS^3 ***************************************")')
  call read_ip
  !
  write(*,'(" ### Store cum_ltd_rep_combination numbers. ")')
  call get_cum_ltd_rep_combination(NOS,NODmax,NODmin,local_NODmax)
  !
  write(*,'(" ### Set THS. ")')
  if(NODmax>0)then
    THS = cum_ltd_rep_combination(NOS,NODmax)
  else
    THS = 1
  end if
  write(*,*) "  THS   = ", THS
  !
  if(THS < 0) stop "THS is bigger than the upper limit of 8-bite integer!"
  !
  write(*,'(" ### Allocate and Set arrays for state_list. ")')
  call allocate_lists_omp_SQ 
  write(*,*) "  THS(k)   = ", THS
  !
  write(*,'(" ### Make wk_loc and wk_ele array. ")')
  call make_wk_loc_and_ele(THS)
  !
  If(ALG.eq.1)then !Conventional Lanczos
    if(re_wf.ne.1)then
      write(*,'(" ### Start the Lanczos method. ")')
      call lanczos_routines(ene,THS,psi)
      !
      if(wr_wf.eq.1)then
        write(*,'(" ### Write wavevectors. ")')
        call write_wf(THS,1,1,1,ene)
      end if
      !
      call write_index_ene(ene,1)
      !
    else
      write(*,'(" ### Read lanczos_para. ")')
      call read_lanczos_para
      !
      write(*,'(" ### Read wavefunctions. ")')
      call read_wf(THS,1,1,1)
    end if
    !
  else if(ALG.eq.2 )then 
    if(re_wf.ne.1)then
      write(*,'(" ### Start the thick-restarted Lanczos method. ")')
      call my_trlanczos_routines_complex(ene,psi,THS) 
      !
      if(wr_wf.eq.1)then
        write(*,'(" ### Write wavevectors. ")')
        call write_wf(THS,i_vec_min, i_vec_max,NOE,ene)
      end if
      !
      call write_index_ene(ene,NOE)
      !
    else
      write(*,'(" ### Read input_TRLan. ")')
      call read_input_TRLan
      !
      write(*,'(" ### Read wavefunctions. ")')
      call read_wf(THS,i_vec_min,i_vec_max,NOE)
    end if
    !
  else if(ALG.eq.3)then
    write(*,'(" ### Start the full diagonalization. ")')
    call Full_diag_routines(ene,psi,THS)
  end if
  !
  if(cal_lm==1)then
    write(*,'(" ### Get local magnetizations. ")')
    call get_lm(psi,NODmax,NODmin,THS,1,NOS)
  end if
  !
  if(cal_cf==1)then
    write(*,'(" ### Get two-point correlation functions. ")')
    call get_cf(psi,NODmax,NODmin,THS,1)
  end if
  !
  !$ en = omp_get_wtime()
  !$ write(*,'("Time:",f10.3," [sec]")') en-st
  write(*,'("****************************************************************************************")')
  stop
end program main

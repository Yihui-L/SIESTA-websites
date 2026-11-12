!*******************************************************************************
!>  @file siesta_run.f90
!>  @brief Contains module @ref siesta_run.
!
!  Note separating the Doxygen comment block here so detailed decription is
!  found in the Module not the file.
!
!>  Defines the base class of the type @ref siesta_run_class. This module
!>  contains all the code necessary to interface setup and run SIESTA.
!*******************************************************************************

      MODULE siesta_run
      USE stel_kinds
      USE shared_data, ONLY: unit_out
      USE timer_mod

      IMPLICIT NONE

!*******************************************************************************
!  siesta run module parameters
!*******************************************************************************
!>  Clear all control bits.
      INTEGER, PARAMETER :: siesta_run_control_clear = 0

!>  Bit position to initalize mpi.
      INTEGER, PARAMETER :: siesta_run_control_mpi = 1
!>  Bit position to close the wout file.
      INTEGER, PARAMETER :: siesta_run_control_wout = 2
!>  Bit position to sync the namelist inputs.
      INTEGER, PARAMETER :: siesta_run_sync_namelist = 3
!>  Bit position to write diagnostics outputs.
      INTEGER, PARAMETER :: siesta_run_write_profiles = 4

!*******************************************************************************
!  DERIVED-TYPE DECLARATIONSf
!  1) siesta_run base class
!
!*******************************************************************************
      TYPE :: siesta_run_class
!>  Timer On
         REAL (dp) :: time_on
!>  Control state.
         INTEGER   :: control_state
!>  Convergence result for the last call to converge.
         LOGICAL   :: converged = .FALSE.
         INTEGER   :: iterations_completed = 0
         CHARACTER (LEN=16) :: termination_reason = 'not_run'
#if defined(SIESTA_OPENMP)
!  Keep the caller's OpenMP settings across sequential contexts.
         INTEGER, PRIVATE :: caller_omp_threads = 0
         LOGICAL, PRIVATE :: caller_omp_dynamic = .FALSE.
#endif
      CONTAINS
!  FIXME: Remove _temp after merge of V3FIT fixes.
         PROCEDURE :: set_vmec_ => siesta_run_set_vmec
         PROCEDURE :: set_vmec_temp => siesta_run_set_vmec_temp
         GENERIC   :: set_vmec => set_vmec_, set_vmec_temp
         PROCEDURE :: set_restart => siesta_run_set_restart
         PROCEDURE :: set_1d => siesta_run_set_1d
         GENERIC   :: set => set_1d
         PROCEDURE :: set_control_state => siesta_run_set_control_state
         PROCEDURE :: is_state_set => siesta_run_is_state_set
         PROCEDURE :: clear_state => siesta_run_clear_state
         PROCEDURE :: get_1d => siesta_run_get_1d
         GENERIC   :: get => get_1d
         PROCEDURE :: converge => siesta_run_converge
         PROCEDURE :: sync => siesta_run_sync
         FINAL     :: siesta_run_destruct
      END TYPE

!*******************************************************************************
!  INTERFACE BLOCKS
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  Interface for the siesta_run constructor.
!-------------------------------------------------------------------------------
      INTERFACE siesta_run_class
         MODULE PROCEDURE siesta_run_construct
      END INTERFACE

      CONTAINS

!*******************************************************************************
!  CONSTRUCTION SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Construct new @ref siesta_run_class object.
!>
!>  Allocates memory and initializes a @ref siesta_run_class object. Performs
!>  all the initialization needed to operate SIESTA.
!>
!>  @param[in] run_comm      MPI Communicator to use.
!>  @param[in] verbose       Control the code screen output.
!>  @param[in] init_mpi      Instructs if MPI should be initialized.
!>  @param[in] close_wout    Instructs if wout file should be closed on
!>                           deallocate.
!>  @param[in] namelist_file Path to the siesta namelist input file.
!>  @returns A pointer to a constructed @ref siesta_run_class object.
!-------------------------------------------------------------------------------
      FUNCTION siesta_run_construct(run_comm, verbose, init_mpi, close_wout,   &
                                    namelist_file)
      USE nscalingtools, ONLY: MyEnvVariables, PARSOLVER, SIESTA_COMM
      USE descriptor_mod, ONLY: LSCALAPACK, INHESSIAN, DIAGONALDONE, iam, nprocs, &
                                nprow, npcol, icontxt, icontxt_1xp,            &
                                icontxt_px1, icontxt_global, isroot,           &
                                myrow, mycol
#if defined(MPI_OPT)
      USE prof_mod, ONLY: profinit
      USE mpi_inc, ONLY: MPI_SUCCESS
      USE v3_utilities, ONLY: assert
#endif
      USE shared_data, ONLY: nprecon, lverbose
      USE perturbation, ONLY: init_data
      USE hessian, ONLY: HESSPASS
      USE siesta_state, ONLY: lfirst
      USE siesta_error
      USE diagnostics_mod, ONLY: toroidal_flux0
      USE blocktridiagonalsolver_s, ONLY: Initialize, GetRanks
      USE siesta_namelist, ONLY: mpolin, ntorin, nfpin, ntor_modes
      USE metrics, ONLY: set_grid_sizes
#if defined(SIESTA_OPENMP)
      USE omp_lib, ONLY: omp_get_max_threads, omp_get_dynamic
#endif

      IMPLICIT NONE

!  Declare Arguments
      CLASS (siesta_run_class), POINTER :: siesta_run_construct
      INTEGER, INTENT(in)               :: run_comm
      LOGICAL, INTENT(in)               :: verbose
      LOGICAL, INTENT(in)               :: init_mpi
      LOGICAL, INTENT(in)               :: close_wout
      CHARACTER (len=*), INTENT(in)     :: namelist_file

!  local variables.
      REAL (dp)                         :: ton
      REAL (dp)                         :: toff
#if defined(MPI_OPT)
      INTEGER                           :: ierr, blacs_system_context
      INTEGER, EXTERNAL                 :: sys2blacs_handle
#endif

!  Start of executable code
      ALLOCATE(siesta_run_construct)

#if defined(SIESTA_OPENMP)
      siesta_run_construct%caller_omp_threads = omp_get_max_threads()
      siesta_run_construct%caller_omp_dynamic = omp_get_dynamic()
#endif
      siesta_run_construct%control_state = siesta_run_control_clear

      CALL siesta_run_construct%set_control_state(siesta_run_write_profiles)
      IF (init_mpi) THEN
         CALL siesta_run_construct%set_control_state(siesta_run_control_mpi)
      END IF

      IF (close_wout) THEN
         CALL siesta_run_construct%set_control_state(siesta_run_control_wout)
      END IF

      CALL siesta_error_clear_all

      lverbose = verbose
      lfirst = .TRUE.
      toroidal_flux0=0

      SIESTA_COMM = run_comm
      HESSPASS = 0

      INHESSIAN = .FALSE.
      DIAGONALDONE = .FALSE.
  	  PARSOLVER=.FALSE.
      CALL init_timers
      CALL sks_timers

#if defined(MPI_OPT)
      LSCALAPACK = .TRUE.

      CALL MyEnvVariables
      IF (PARSOLVER) THEN
         LSCALAPACK=.FALSE.
         CALL Initialize(0, 0)        !Must call this to initialize mpi timer
         CALL GetRanks(iam, nprocs)
      END IF

      IF (LSCALAPACK) THEN
         CALL profinit()

!  Build each BLACS grid from the caller's MPI communicator.
         CALL MPI_Comm_rank(SIESTA_COMM, iam, ierr)
         CALL assert(ierr.EQ.MPI_SUCCESS, 'Cannot determine ScaLAPACK rank')
         CALL MPI_Comm_size(SIESTA_COMM, nprocs, ierr)
         CALL assert(ierr.EQ.MPI_SUCCESS, 'Cannot determine ScaLAPACK rank count')
         blacs_system_context = sys2blacs_handle(SIESTA_COMM)
         DO nprow = INT(SQRT(DBLE(nprocs))) + 1, 1, -1
            npcol = INT( nprocs/nprow )
            IF (nprow*npcol .eq. nprocs) EXIT
         END DO

         icontxt = blacs_system_context
         CALL blacs_gridinit(icontxt, 'C', nprow, npcol)

         icontxt_1xp = blacs_system_context
         CALL blacs_gridinit(icontxt_1xp, 'R', 1, nprow*npcol)

         icontxt_px1 = blacs_system_context
         CALL blacs_gridinit(icontxt_px1, 'C', nprow*npcol, 1)

         icontxt_global = icontxt_1xp

         CALL blacs_gridinfo(icontxt, nprow, npcol, myrow, mycol)
         isroot = (myrow .eq. 0) .and. (mycol .eq. 0)
         IF (isroot .and. lverbose) THEN
            WRITE (*,1000) nprow, npcol
            WRITE (*,1001) icontxt_global, icontxt, icontxt_1xp, icontxt_px1
         END IF
      END IF
#else
      LSCALAPACK = .FALSE.
      iam = 0
      nprocs = 1
#endif

      CALL second0(ton)
      siesta_run_construct%time_on = ton

      nprecon = init_data(namelist_file)
      CALL configure_cpu_threads
      CALL set_grid_sizes(mpolin, ntorin, nfpin, ntor_modes(-ntorin:ntorin))

      CALL second0(toff)

      init_data_time = toff - ton

1000  FORMAT('nprow,npcol ',2(x,i5))
1001  FORMAT('icontxt_global,icontxt,icontxt_1xp,icontxt_px1 ',4(x,i5))

      END FUNCTION

!  Configure a team within each node-local MPI rank's available CPU budget.
!  MPI remains on the initializing thread; only local Fourier work is threaded.
      SUBROUTINE configure_cpu_threads
      USE siesta_namelist, ONLY: omp_threads
      USE v3_utilities, ONLY: assert
#if defined(SIESTA_OPENMP)
      USE omp_lib
      USE descriptor_mod, ONLY: iam, SIESTA_COMM
#if defined(MPI_OPT)
      USE mpi_inc
#endif
#endif
      IMPLICIT NONE
#if defined(SIESTA_OPENMP)
      INTEGER :: local_ranks, capacity, budget, nthreads, ios, unit, env_length
      INTEGER :: quota, period
      CHARACTER(LEN=80) :: quota_text
#if defined(MPI_OPT)
      INTEGER :: local_comm, ierr, thread_support
#endif
#endif
      CALL assert(omp_threads.ge.0, 'OMP_THREADS must be zero or positive')
#if defined(SIESTA_OPENMP)
      local_ranks = 1
#if defined(MPI_OPT)
      CALL MPI_Comm_split_type(SIESTA_COMM, MPI_COMM_TYPE_SHARED, 0,         &
                               MPI_INFO_NULL, local_comm, ierr)
      CALL assert(ierr.eq.MPI_SUCCESS, 'Cannot determine node-local ranks')
      CALL MPI_Comm_size(local_comm, local_ranks, ierr)
      CALL MPI_Comm_free(local_comm, ierr)
#endif
!  omp_get_num_procs respects the process affinity mask on supported runtimes.
      capacity = MAX(1, omp_get_num_procs())
      budget = HUGE(budget)
      OPEN(NEWUNIT=unit, FILE='/sys/fs/cgroup/cpu.max', STATUS='old',        &
           ACTION='read', IOSTAT=ios)
      IF (ios.eq.0) THEN
         READ(unit, *, IOSTAT=ios) quota_text, period
         CLOSE(unit)
         IF (ios.eq.0 .and. TRIM(quota_text).ne.'max') THEN
            READ(quota_text, *, IOSTAT=ios) quota
            IF (ios.eq.0 .and. period.gt.0 .and. quota.gt.0)               &
               budget = MAX(1, quota/period/local_ranks)
         END IF
      END IF
!  This optional check covers the visible cgroup v2 file only. Scheduler
!  binding and explicit thread limits are needed for other quota layouts.
      nthreads = MIN(budget, MAX(1, capacity/local_ranks))
!  A bound rank may see only its own cores, so a launcher-provided team size
!  must not be divided by the node rank count a second time.
      CALL GET_ENVIRONMENT_VARIABLE('SIESTA_CPU_THREADS', LENGTH=env_length)
      IF (env_length.gt.0) THEN
         CALL GET_ENVIRONMENT_VARIABLE('SIESTA_CPU_THREADS', quota_text,   &
                                       STATUS=ios)
         IF (ios.eq.0) THEN
            READ(quota_text, *, IOSTAT=ios) quota
            IF (ios.eq.0 .and. quota.gt.0)                                &
               nthreads = MIN(capacity, budget, quota)
         END IF
      END IF
      IF (omp_threads.gt.0) THEN
         nthreads = MIN(capacity, budget, omp_threads)
      ELSE
         CALL GET_ENVIRONMENT_VARIABLE('OMP_NUM_THREADS', LENGTH=env_length)
         IF (env_length.gt.0) THEN
            nthreads = MIN(capacity, budget, omp_get_max_threads())
         ELSE
            nthreads = MIN(nthreads, 4)
         END IF
      END IF
      nthreads = MAX(1, MIN(nthreads, omp_get_thread_limit()))
#if defined(MPI_OPT)
!  Preserve library callers that initialized MPI with MPI_Init. They cannot
!  use worker threads, even when a namelist/environment requests a team.
      CALL MPI_Query_thread(thread_support, ierr)
      CALL assert(ierr.eq.MPI_SUCCESS, 'Cannot query MPI thread support')
      IF (thread_support.lt.MPI_THREAD_FUNNELED) THEN
         nthreads = 1
         IF (iam.eq.0) WRITE(*,'(a)')                                &
            'MPI_THREAD_SINGLE: SIESTA OpenMP falls back to one thread'
      END IF
#endif
      CALL omp_set_dynamic(.false.)
      CALL omp_set_num_threads(nthreads)
      IF (iam.eq.0) WRITE(*,'(a,i0,a,i0)') 'CPU team: threads/rank=',       &
          nthreads, ', node-local ranks=', local_ranks
#endif
      END SUBROUTINE configure_cpu_threads

!*******************************************************************************
!  DESTRUCTION SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Deconstruct a @ref siesta_run_class object.
!>
!>  Deallocates memory and uninitializes a @ref siesta_run_class object. This 
!>  also performs the shut down procedures for SIESTA.
!>
!>  @param[inout] this         A @ref siesta_run_class instance.
!-------------------------------------------------------------------------------
      SUBROUTINE siesta_run_destruct(this)
      USE nscalingtools, ONLY: OUTPUT_TIMINGS, GetTimes, PARSOLVER,     &
                               PARFUNCTISL, PARGMRES, SKSDBG, TOFU,     &
                               finalizeremap
      USE blocktridiagonalsolver_s, ONLY: finalize
#if defined(SIESTA_OPENMP)
      USE omp_lib, ONLY: omp_set_num_threads, omp_set_dynamic
#endif
      USE descriptor_mod, ONLY: iam, icontxt, icontxt_1xp, icontxt_px1, LSCALAPACK, nprocs
      USE shared_data, ONLY: nprecon, xc, gc, fsq_total1, mblk_size,    &
                             niter, col_scale, lverbose, ngmres_type,   &
                             lColScale, gc_sup
      USE hessian, ONLY: levmarq_param, mupar, asym_index, dealloc_hessian
      USE quantities, ONLY: fbdy, dealloc_quantities
      USE dumping_mod, ONLY: write_output
      USE diagnostics_mod, ONLY: write_profiles, dealloc_diagnostics
      USE siesta_namelist, ONLY: wout_file, l_output_alliter, lrestart
      USE read_wout_mod, ONLY: lwout_opened, read_wout_deallocate
      USE island_params, ONLY: ns_i
      USE metrics, ONLY: cleanup_metric_elements, dealloc_full_lower_metrics
#if defined(MPI_OPT)
      USE prof_mod, ONLY: profstat
#endif
      IMPLICIT NONE

!  Declare Arguments
      TYPE (siesta_run_class), INTENT(inout) :: this

!  local variables.
      REAL (dp)                              :: ton
      REAL (dp)                              :: toff
      INTEGER                                :: i

!  Start of executable code
      CALL second0(toff)
      time_total = toff - this%time_on

      IF (OUTPUT_TIMINGS) THEN
         CALL GetTimes
      END IF

      IF (iam .EQ. 0) THEN
         DO i = 6, unit_out, unit_out-6
            IF (.NOT.lverbose .AND. i.EQ.6) CYCLE
            WRITE (i, 1000) nprecon, levmarq_param, mupar, asym_index
            WRITE (i,'(a,i5)') ' Number processors: ', nprocs
            WRITE (i, 1001)
            WRITE (i, 1002) time_total,               fbdy(1),          &
                            time_init,                fbdy(2),          &
                            time_diag_prec,           fbdy(3),          &
                            time_block_prec,          fbdy(4),          &
                            time_factor_blocks,       fbdy(5),          &
                            time_toijsp,              fbdy(6),          &
                            time_tomnsp,                                &
                            gmres_time,                                 &
                            conj_grad_time,                             &
                            time_update_pres,         fbdy(7),          &
                            time_update_bfield,       fbdy(8),          &
                            time_current,             fbdy(9),          &
                            get_force_harmonics_time, fbdy(10),         &
                            time_update_force,        fbdy(11),         &
                            time_update_upperv,       fbdy(12),         &
                            time_update_state,        fbdy(13),         &
                            time_funci,                                 &
                            time_apply_precon,                          &
                            (diag_add_pert_time + block_add_pert_time), &
                            time_init_state
            WRITE (i,*)
            IF (PARSOLVER) THEN
               WRITE (i,*)        'PARSOLVER=T    : NSCALED'
            ELSE IF (LSCALAPACK) THEN
               WRITE (i,*)        'PARSOLVER=F    : SCALAPACK'
            ELSE 
               WRITE (i,*)        'PARSOLVER=F    : SERIAL'
            END IF
            WRITE (i,*)           'PARFUNCTISL    :', PARFUNCTISL
            WRITE (i,*)           'COLUMN SCALING :', lColScale
            WRITE (i,'(1x,a,L2,a,i2)') 'PARGMRES       :', PARGMRES,    &
                                  ' GMRES_TYPE: ', ngmres_type

            WRITE (i,*)           'OUTPUT_TIMINGS :', OUTPUT_TIMINGS

            WRITE (i,*)
            WRITE (i,101)' TIME DIVB      : ', time_divb
            WRITE (i,101)' TIME DIVJ      : ', time_divj
            WRITE (i,101)' TIME BGRADP    : ', time_bgradp
            WRITE (i,101)' TIME BDOTJ     : ', time_bdotj
            WRITE (i,*)
            WRITE (i,102)' M (block size) :', mblk_size
            WRITE (i,102)' N (block rows) :', ns_i
            WRITE (i,102)' P (processors) :', nprocs
         END DO
      ENDIF
 101  FORMAT(a,1p,e10.3)
 102  FORMAT(a,i5)
 
      IF (this%is_state_set(siesta_run_write_profiles) .and. .not.lrestart) THEN
         IF (.not.l_output_alliter .or. this%iterations_completed .eq. 0) THEN
            CALL write_output(wout_file, this%iterations_completed, .FALSE.)
         END IF
         CALL write_profiles(fsq_total1)
         IF (iam .eq. 0 .and. lverbose) THEN
            PRINT *, ' Writing output to "siesta_profiles.txt" is finished!'
         END IF
      END IF
      IF (lwout_opened .and. this%is_state_set(siesta_run_control_wout)) THEN
         CALL read_wout_deallocate
      END IF
      IF (iam .EQ. 0) CLOSE (UNIT=unit_out)

!CLEAN UP ARRAYS
      CALL cleanup_metric_elements

      CALL dealloc_quantities
      CALL dealloc_hessian
      CALL dealloc_diagnostics
      CALL dealloc_full_lower_metrics
      IF (ALLOCATED(xc)) DEALLOCATE(xc, gc, gc_sup)
      IF (ALLOCATED(col_scale)) DEALLOCATE(col_scale)

#if defined(MPI_OPT)
      IF (LSCALAPACK) THEN
         CALL blacs_barrier(icontxt, 'All')
         CALL blacs_gridexit(icontxt)
         CALL blacs_gridexit(icontxt_1xp)
         CALL blacs_gridexit(icontxt_px1)
         CALL profstat

!  Global BLACS shutdown also destroys the caller's other grids.
         IF (this%is_state_set(siesta_run_control_mpi)) THEN
            CALL blacs_exit(0)
         END IF

      ELSE
         IF (SKSDBG) THEN
            WRITE(TOFU,*) 'Called finalizeRemap and Finalize'
            FLUSH(TOFU)
         END IF
         CALL finalizeRemap
         CALL Finalize(this%is_state_set(siesta_run_control_mpi))

      END IF
#endif

#if defined(SIESTA_OPENMP)
      IF (this%caller_omp_threads.gt.0) THEN
         CALL omp_set_num_threads(this%caller_omp_threads)
         CALL omp_set_dynamic(this%caller_omp_dynamic)
      END IF
#endif

1000  FORMAT(/,' nprecon: ',i3,' LM parameter: ',1pe9.2,' mu||: ',1pe9.2,      &
             ' Symmetry Index: ',1pe9.2)
1001  FORMAT(/,'==============================',14x,'=======================', &
             /,                                                                &
             /,' TIMING INFORMATION           ',14x,' RMS BOUNDARY FORCES',    &
             /,                                                                &
             /,'==============================',14x,'=======================')
1002  FORMAT(' Total runtime  : ',  f12.3,15x,'fs(1,m=1)  :',1pe10.2/,         &
             ' Initialization : ',0pf12.3,15x,'fs(2,m=1)  :',1pe10.2/,         &
             ' Diagonal prec  : ',0pf12.3,15x,'fs(2,m!=1) :',1pe10.2/,         &
             ' Compute blocks : ',0pf12.3,15x,'fu(1,m=1)  :',1pe10.2/,         &
             ' Factor blocks  : ',0pf12.3,15x,'fu(2,m=1)  :',1pe10.2/,         &
             ' Toijsp         : ',0pf12.3,15x,'fu(2,m!=1) :',1pe10.2/,         &
             ' Tomnsp         : ',0pf12.3,/,                                   &
             ' GMRES          : ',0pf12.3,/,                                   &
             ' Conj Gradient  : ',0pf12.3,//,                                  &
             ' SUBROUTINES     ',/,                                            &
             ' Update Pressure: ',0pf12.3,15x,'fv(1,m=0)  :',1pe10.2/,         &
             ' Update Bfield  : ',0pf12.3,15x,'fv(2,m=0)  :',1pe10.2/,         &
             ' CV Currents    : ',0pf12.3,15x,'fv(2,m!=0) :',1pe10.2/,         &
             ' Force Harmonics: ',0pf12.3,15x,'fu(ns)     :',1pe10.2/,         &
             ' Update Force   : ',0pf12.3,15x,'fu(ns-1)   :',1pe10.2/,         &
             ' Update UpperV  : ',0pf12.3,15x,'fv(ns)     :',1pe10.2/,         &
             ' Update State   : ',0pf12.3,15x,'fv(ns-1)   :',1pe10.2/,         &
             ' Funct Island   : ',0pf12.3/,                                    &
             ' Apply Precon   : ',0pf12.3/,                                    &
             ' Add Perturb    : ',0pf12.3/,                                    &
             ' Init State     : ',0pf12.3,                                     &
             /,'==============================',14x,'=======================')

      END SUBROUTINE

!*******************************************************************************
!  SETTER SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Sets quanties based on VMEC values.
!>
!>  This method loads and sets variables based on the VMEC equilibrium. VMEC 
!>  controls the metric elements and coordinate system jacobian.
!>
!>  @param[inout] this      A @ref siesta_run_class instance.
!>  @param[in]    load_wout Flag to load the wout file.
!-------------------------------------------------------------------------------
!  FIXME: Temp routine to make sure CI tests still. Remove once V3FIT changes
!         finished.
      SUBROUTINE siesta_run_set_vmec(this)
      IMPLICIT NONE
      CLASS (siesta_run_class), INTENT(inout) :: this
      CALL siesta_run_set_vmec_temp(this, .true.)
      END SUBROUTINE

      SUBROUTINE siesta_run_set_vmec_temp(this, load_wout)
      USE siesta_namelist, ONLY: nsin, mpolin, ntorin, nfpin, wout_file,       &
                                 l_vessel, ntor_modes, siesta_mgrid_file => mgrid_file
      USE metrics, ONLY: init_metric_elements, LoadGrid, sqrtg
      USE quantities, ONLY: init_quantities, init_fields
      USE island_params, ns=>ns_i, mpol=>mpol_i, ntor=>ntor_i
      USE shared_data, ONLY: nsp
      USE vmec_info
      USE grid_extension, ONLY: grid_extender, read_vessel_file
      USE pchelms
      USE evolution, ONLY: init_evolution
      USE nscalingtools, ONLY: initRemap

      IMPLICIT NONE

!  Declare Arguments
      CLASS (siesta_run_class), INTENT(inout) :: this
      LOGICAL, INTENT(in)                     :: load_wout

!  local variables
      INTEGER                                 :: istat
      LOGICAL                                 :: mgrid_exists

!  Start of executable code
      CALL this%sync

      IF (l_vessel) THEN
         INQUIRE(FILE=TRIM(siesta_mgrid_file), EXIST=mgrid_exists)
         CALL assert(mgrid_exists, 'Missing MGRID_FILE for free boundary: ' // TRIM(siesta_mgrid_file))
      END IF

      CALL vmec_info_set_wout(wout_file, nsin, mpolin, ntorin, nfpin,          &
     &                        ntor_modes(-ntorin:ntorin), load_wout)

!  CONSTRUCT R, Z, L REAL-SPACE ARRAYS ON SQRT(FLUX) - "POLAR" - MESH AND
!  COMPUTE METRIC ELEMENTS AND JACOBIAN
      CALL LoadGrid(istat)
      CALL assert_eq(0, istat, 'LoadRZL error in siesta_run_set_vmec')
      nsp = ns

!  PCHELMS requires a valid extended grid when the vessel is enabled.
      IF (l_vessel) THEN
         istat = read_vessel_file()
         CALL assert_eq(0, istat, 'Cannot initialize the free-boundary vessel')
         CALL grid_extender(wout_file, 'quad', istat)
         CALL assert_eq(0, istat, 'Cannot construct the free-boundary grid')
      END IF

      CALL init_metric_elements()
      CALL init_quantities(.false.) !Initializes BCYCLIC
      CALL init_evolution !neqs is set here
      CALL initRemap(mpol, ntor, ns, nprocs, iam)
      CALL InitHess

      IF (l_vessel) THEN
         CALL run_pchelms
      END IF
      CALL Init_Fields

      DEALLOCATE (sqrtg)

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Sets quantities for restarting.
!>
!>  This loads and sets variables from a restarted SIESTA equilibrium. The
!>  restart file constains the metric elements, coordinate system jacobian and
!>  the
!>
!>  @param[inout] this A @ref siesta_run_class instance.
!-------------------------------------------------------------------------------
      SUBROUTINE siesta_run_set_restart(this)
      USE restart_mod, ONLY: restart_read, restart_free_grid_size, restart_restore_free_fluxes
      USE siesta_namelist, ONLY: lrestart, mpolin, ntorin, nsin, restart_ext,  &
     &                           wout_file, nfpin, l_vessel,                   &
     &                           ntor_modes, restart_input_ext
      USE shared_data, ONLY: nprecon, nsp
      USE metrics, ONLY: init_metric_elements, sqrtg
      USE quantities, ONLY: init_quantities
      USE descriptor_mod, ONLY: iam, nprocs
      USE evolution, ONLY: init_evolution
      USE nscalingtools, ONLY: initRemap
      USE island_params, ONLY: ns=>ns_i, hs=>hs_i, ohs=>ohs_i, nsh
      USE hessian, ONLY: InitHess

      IMPLICIT NONE

!  Declare Arguments
      CLASS (siesta_run_class), INTENT(inout) :: this

      CHARACTER (LEN=:), ALLOCATABLE :: input_ext

!  Start of executable code
      CALL this%sync
      input_ext = TRIM(restart_input_ext)
      IF (LEN(input_ext) .eq. 0) input_ext = TRIM(restart_ext)

      IF (l_vessel) THEN
         ns = restart_free_grid_size(input_ext, nsin)
      ELSE
         ns = nsin
      END IF
      nsp = nsin
      nsh = ns - 1
      ohs = nsin - 1
      hs = 1.0_dp/ohs

      nprecon = restart_read(input_ext, wout_file, mpolin, ntorin, nfpin,       &
                             ns, ntor_modes(-ntorin:ntorin), restart_ext)

      CALL init_metric_elements()
      CALL init_quantities(.true.) !Initializes BCYCLIC
      IF (l_vessel) CALL restart_restore_free_fluxes
      CALL init_evolution !neqs is set here
      CALL initRemap(mpolin, ntorin, ns, nprocs, iam)
      CALL InitHess
      DEALLOCATE (sqrtg)

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Set 1D parameter value.
!>
!>  @param[inout] this       @ref siesta_run_class instance.
!>  @param[in]    param_name Name of the parameter to set.
!>  @param[in]    value      Value to set the parameter to.
!>  @param[in]    index      Array index of to set the value to.
!-------------------------------------------------------------------------------
      SUBROUTINE siesta_run_set_1d(this, param_name, value, index)
      USE siesta_namelist, ONLY: helpert, helphase
      USE siesta_error

      IMPLICIT NONE

!  Declare Arguments
      CLASS (siesta_run_class), INTENT(inout) :: this
      CHARACTER (len=*), INTENT(in)           :: param_name
      REAL (dp)                               :: value
      INTEGER, INTENT(in)                     :: index

!  Start of executable code.
      SELECT CASE (TRIM(param_name))

         CASE ('helpert')
            helpert(index) = value
            CALL this%set_control_state(siesta_run_sync_namelist)

         CASE ('helphase')
            helphase(index) = value
            CALL this%set_control_state(siesta_run_sync_namelist)

         CASE DEFAULT
            CALL siesta_error_set_error(siesta_error_param,                    &
                                        'Warning unknown parameter name ' //   &
                                        TRIM(param_name))

      END SELECT

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Set a control state.
!>
!>  @param[inout] this  @ref siesta_run_class instance.
!>  @param[in]    state State bit to set.
!-------------------------------------------------------------------------------
      SUBROUTINE siesta_run_set_control_state(this, state)

      IMPLICIT NONE

!  Declare Arguments
      CLASS (siesta_run_class), INTENT(inout) :: this
      INTEGER, INTENT(in)                     :: state

!  Start of executable code.
      this%control_state = IBSET(this%control_state, state)

      END SUBROUTINE

!*******************************************************************************
!  GETTER SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Get 1D parameter value.
!>
!>  @param[inout] this       @ref siesta_run_class instance.
!>  @param[in]    param_name Name of the parameter to set.
!>  @param[in]    index      Array index of to set the value to.
!>  @returns Value of the parameter at the index.
!-------------------------------------------------------------------------------
      FUNCTION siesta_run_get_1d(this, param_name, index)
      USE siesta_namelist, ONLY: helpert, helphase

      IMPLICIT NONE

!  Declare Arguments
      REAL (dp)                            :: siesta_run_get_1d
      CLASS (siesta_run_class), INTENT(in) :: this
      CHARACTER (len=*), INTENT(in)        :: param_name
      INTEGER, INTENT(in)                  :: index

!  Start of executable code.
      SELECT CASE (TRIM(param_name))

         CASE ('helpert')
            siesta_run_get_1d = helpert(index)

         CASE ('helphase')
            siesta_run_get_1d = helphase(index)

         CASE DEFAULT
            siesta_run_get_1d = 0.0

      END SELECT

      END FUNCTION

!*******************************************************************************
!  QUERY SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Query if state is set.
!>
!>  @param[in] this  @ref siesta_run_class instance.
!>  @param[in] state State bit to query.
!>  @returns True if the state is set.
!-------------------------------------------------------------------------------
      FUNCTION siesta_run_is_state_set(this, state)

      IMPLICIT NONE

!  Declare Arguments
      LOGICAL                              :: siesta_run_is_state_set
      CLASS (siesta_run_class), INTENT(in) :: this
      INTEGER, INTENT(in)                  :: state

!  Start of executable code.
      siesta_run_is_state_set = BTEST(this%control_state, state)

      END FUNCTION

!*******************************************************************************
!  UTILITY SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Clear state bit.
!>
!>  @param[in] this  @ref siesta_run_class instance.
!>  @param[in] state State bit to query.
!-------------------------------------------------------------------------------
      SUBROUTINE siesta_run_clear_state(this, state)

      IMPLICIT NONE

!  Declare Arguments
      CLASS (siesta_run_class), INTENT(inout) :: this
      INTEGER, INTENT(in)                     :: state

!  Start of executable code.
      this%control_state = IBCLR(this%control_state, state)

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Solves the SIESTA equilibrium.
!>
!>  This method converges the siesta_run_class equilibrium. Initializes the 
!>  evolution module variables and converges the force residual using a diagonal 
!>  preconditioner. Applies the external island perturbation if possible. Loads 
!>  restart file before convergence.
!>
!>  @param[inout] this A @ref siesta_run_class instance.
!-------------------------------------------------------------------------------
      SUBROUTINE siesta_run_converge(this)
      USE evolution, ONLY: converge_diagonal, converge_blocks, pert_added, refresh_committed_state
      USE descriptor_mod, ONLY: DIAGONALDONE, iam
      USE hessian, ONLY: gather_array
      USE perturbation, ONLY: niter_max
      USE restart_mod, ONLY: restart_write
      USE siesta_namelist, ONLY: ftol, wout_file, restart_ext, ladd_pert
      USE utilities, ONLY: test_utilities
      USE shared_data, ONLY: xc, gc, gc_sup, niter, fsq_total1, lverbose

      IMPLICIT NONE

!  Declare Arguments
      CLASS (siesta_run_class), INTENT(inout) :: this

!  Local variables
      INTEGER                                 :: i
      REAL (dp), ALLOCATABLE                  :: last_displacement(:)

!  Start of executable code
      pert_added = .not.ladd_pert

      IF (test_utilities()) THEN
         WRITE (*,*) 'Failed Diverence Test.'
!         STOP
      END IF

!  Converge initial residues with diagonal preconditioner
      xc = 0
      DIAGONALDONE = .false.
      CALL converge_diagonal(wout_file, ftol)
      DIAGONALDONE = .true.

!  Converge using block preconditioner
      CALL converge_blocks(wout_file, ftol)

!  Measure the committed state after all ideal, resistive and seed updates.
!  Keep the last displacement for the legacy profile diagnostics.
      last_displacement = xc
      CALL refresh_committed_state
      xc = last_displacement
      CALL gather_array(gc)
      CALL gather_array(gc_sup)

      this%iterations_completed = niter - 1
      this%converged = fsq_total1 .ge. 0 .and. fsq_total1 .le. ftol
      IF (this%converged) THEN
         this%termination_reason = 'converged'
      ELSE IF (fsq_total1 .lt. 0) THEN
         this%termination_reason = 'invalid_residual'
      ELSE IF (this%iterations_completed .ge. niter_max) THEN
         this%termination_reason = 'iteration_limit'
      ELSE
         this%termination_reason = 'solver_stalled'
      END IF

      IF (iam .eq. 0) THEN
         CALL restart_write(TRIM(restart_ext)//'_final', wout_file, this%iterations_completed, &
                            'final', TRIM(this%termination_reason), ftol)
         DO i = 6, unit_out, unit_out - 6
            IF (.NOT.lverbose .AND. i.EQ.6) CYCLE
            WRITE (i, '(A,A,A,I0,A,ES16.8,A,ES16.8)') ' SIESTA termination: ', &
               TRIM(this%termination_reason), '  iteration=', this%iterations_completed, &
               '  F2=', fsq_total1, '  FTOL=', ftol
         END DO
      END IF

      END SUBROUTINE

!*******************************************************************************
!  MPI SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Sync child equilibria.
!>
!>  @param[inout] this A @ref siesta_run_class instance.
!-------------------------------------------------------------------------------
      SUBROUTINE siesta_run_sync(this)
      USE siesta_namelist, ONLY: helpert, helphase
      USE nscalingtools, ONLY: SIESTA_COMM, MPI_ERR
#if defined(MPI_OPT)
      USE mpi_inc
#endif

      IMPLICIT NONE

!  Declate Arguments
      CLASS (siesta_run_class), INTENT(inout) :: this

!  Start of executable code
#if defined(MPI_OPT)
      CALL MPI_BCAST(this%control_state, 1, MPI_INTEGER, 0, SIESTA_COMM,       &
                     MPI_ERR)
      IF (this%is_state_set(siesta_run_sync_namelist)) THEN
         CALL MPI_BCAST(helpert, SIZE(helpert), MPI_REAL8, 0, SIESTA_COMM,     &
                        MPI_ERR)
         CALL MPI_BCAST(helphase, SIZE(helphase), MPI_REAL8, 0, SIESTA_COMM,   &
                        MPI_ERR)
         CALL this%clear_state(siesta_run_sync_namelist)
      END IF
#endif

      END SUBROUTINE

      END MODULE

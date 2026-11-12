target_sources(siesta
               PRIVATE
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/add_resistivity.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/assert_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/bhtobf.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/blocktridiagonalsolver_s.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/bmw_run.f>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/check3d.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/descriptor_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/diagnostics_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/dumping_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/evolution.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/f1dim_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/fourier.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/gmres.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/grid_extension.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/hessian.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/island_params.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/metrics.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/nscalingtools.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/pchelms.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/perturbation.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/prof_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/ptrd_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/quantities.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/restart_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/shared_data.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/shared_functions.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_bfield.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_currents.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_displacement.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_error.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_force.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_init.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_namelist.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_pressure.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_run.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta_state.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/silo.inc>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/timer_mod.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/utilities.f90>
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/vmec_info.f90>
)

target_sources(xsiesta
               PRIVATE
               $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/siesta.f90>
)

# Patch copies of the linked LIBSTELL sources in the build tree. Each hunk
# checks its original or already-corrected form so that incompatible upstream
# changes fail at configuration instead of silently linking an unfixed routine.
function (siesta_replace_libstell_code old new)
    string (FIND "${code}" "${new}" patched_position)
    if (patched_position EQUAL -1)
        string (FIND "${code}" "${old}" position)
        if (position EQUAL -1)
            message (FATAL_ERROR "Incompatible LIBSTELL source ${original}. See SIESTA-lyh build documentation.")
        endif ()
        string (REPLACE "${old}" "${new}" code "${code}")
        set (code "${code}" PARENT_SCOPE)
    endif ()
endfunction ()

function (siesta_patch_libstell)
    if (NOT TARGET stell)
        message (FATAL_ERROR "SIESTA-lyh requires the Stellarator-Tools LIBSTELL source target (stell).")
    endif ()
    # Standard fixtures use 100 radial points. Keep their decomposition
    # small regardless of the host-wide MPI process limit.
    get_target_property (fixture_ranks stell MPIEXEC_MAX_NUMPROCS)
    if (NOT fixture_ranks OR fixture_ranks LESS 1)
        set (fixture_ranks 1)
    elseif (fixture_ranks GREATER 8)
        set (fixture_ranks 8)
    endif ()
    set_property (TARGET siesta PROPERTY SIESTA_FIXTURE_RANKS "${fixture_ranks}")
    get_target_property (libstell_dir stell SOURCE_DIR)
    get_target_property (siesta_build siesta BINARY_DIR)
    file (MAKE_DIRECTORY "${siesta_build}/libstell-compat")
    foreach (relative IN ITEMS Sources/GMRes/gmres_lib.f Sources/Ezcdf/ezcdf_GenGet.f90)
        set (original "${libstell_dir}/${relative}")
        get_filename_component (name "${original}" NAME)
        set (patched "${siesta_build}/libstell-compat/${name}")
        set_property (DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${original}")
        file (READ "${original}" code)
        string (REGEX REPLACE "[ 	]+
" "
" code "${code}")
        if (name STREQUAL "gmres_lib.f")
            siesta_replace_libstell_code ([===[
      REAL(dp)  :: rinfo(2), fsq_nl=-1, fsq_lin, fsq_min,
     1             delfsq, fsq_last, bnorm, xmod, xmax,
]===] [===[
      REAL(dp)  :: rinfo(2), fsq_nl, fsq_lin, fsq_min,
     1             fsq_last, bnorm, xmod, xmax,
]===])
            siesta_replace_libstell_code ([===[
      fsq_min = 1; fsq_min_lin = 1
      delfsq = 1
]===] [===[
      fsq_nl = -1
      fsq_min = HUGE(fsq_min); fsq_min_lin = HUGE(fsq_min_lin)
]===])
            siesta_replace_libstell_code ([===[
        IF (gi%ngmres_type .EQ. 1) GOTO 10                               !OLDSTYLE:IGNORE LOGIC BELOW

        delfsq = (fsq_last-fsq_nl)/fsq_min
        IF (delfsq .LT. 0.05_dp) THEN
          jcount = jcount+1
        ELSE
          jcount = 0
]===] [===[
        IF (gi%ngmres_type .EQ. 1) GOTO 10                               !OLDSTYLE:IGNORE LOGIC BELOW

        IF (fsq_nl.GT.gi%ftol .AND. fsq_min.GT.zero) THEN
          IF (fsq_last-fsq_nl .LT. 0.05_dp*fsq_min) THEN
            jcount = jcount+1
          ELSE
            jcount = 0
          END IF
]===])
            siesta_replace_libstell_code ([===[
      REAL(dp) :: rinfo(2), fsq_nl, fsq_min, fsq_last, delfsq, fsq_lin,
]===] [===[
      REAL(dp) :: rinfo(2), fsq_nl, fsq_min, fsq_last, fsq_lin,
]===])
            siesta_replace_libstell_code ([===[
      fsq_min = 1
      fsq_min_lin = 1
      delfsq = 1
]===] [===[
      fsq_min = HUGE(fsq_min)
      fsq_min_lin = HUGE(fsq_min_lin)
]===])
            siesta_replace_libstell_code ([===[
      LACTIVE0: IF (lactive) THEN
      lsum = SUM(b(myrowstart:myrowend)**2)
      CALL MPI_ALLREDUCE(lsum, gsum, 1, MPI_REAL8, MPI_SUM, MY_COMM,
     &                   MPI_ERR)
      bnorm = SQRT(gsum)
      IF (bnorm .EQ. 0) THEN
         RETURN
      END IF

      IF (gi%icntl(6) .EQ. 1) THEN
         work(1:nloc) = x0(myrowstart:myrowend)/bnorm
      END IF

      work(nloc + 1:2*nloc) = b(myrowstart:myrowend)/bnorm

      IF (lprint) THEN
         PRINT 900
      END IF
900   FORMAT(/,1x,'GMRES (PARALLEL) CONVERGENCE SUMMARY',/,1x,15('-'))

      END IF LACTIVE0

      CALL MPI_BCAST(bnorm, 1, MPI_REAL8, 0, MY_COMM_WORLD,
     &               MPI_ERR)

]===] [===[
      IF (lactive) THEN
         lsum = SUM(b(myrowstart:myrowend)**2)
         CALL MPI_ALLREDUCE(lsum, gsum, 1, MPI_REAL8, MPI_SUM,
     &                      MY_COMM, MPI_ERR)
         bnorm = SQRT(gsum)
      END IF
!  All ranks must observe a zero RHS before any rank can return.
      CALL MPI_BCAST(bnorm, 1, MPI_REAL8, 0, MY_COMM_WORLD,
     &               MPI_ERR)
      IF (bnorm .EQ. 0) RETURN

      IF (lactive) THEN
         IF (gi%icntl(6) .EQ. 1) THEN
            work(1:nloc) = x0(myrowstart:myrowend)/bnorm
         END IF
         work(nloc + 1:2*nloc) = b(myrowstart:myrowend)/bnorm
         IF (lprint) PRINT 900
      END IF
900   FORMAT(/,1x,'GMRES (PARALLEL) CONVERGENCE SUMMARY',/,1x,15('-'))

]===])
            siesta_replace_libstell_code ([===[
         IF (lactive) THEN
            fsq_last = fsq_nl                                              !need for delfsq criteria
]===] [===[
         fsq_last = fsq_nl
         IF (lactive) THEN
]===])
            siesta_replace_libstell_code ([===[
!       LACTIVE1: IF (lactive) THEN
        delfsq = (fsq_last - fsq_nl)/fsq_min
        IF (delfsq .LT. 0.05_dp) THEN                                     !PROGRESS COUNTER
          jcount = jcount + 1
        ELSE
          jcount = 0
]===] [===[
!       LACTIVE1: IF (lactive) THEN
        IF (fsq_nl.GT.gi%ftol .AND. fsq_min.GT.zero) THEN
          IF (fsq_last-fsq_nl .LT. 0.05_dp*fsq_min) THEN
            jcount = jcount+1
          ELSE
            jcount = 0
          END IF
]===])
        else ()
            siesta_replace_libstell_code ([===[
  integer                 :: varid,  status
  integer, dimension(1)   :: dimlens,ldim
  if (PRESENT (ier)) ier = 1
  ldim(1) = len(varval)
  call cdfgv(ncid,varnam,varid,dimlens,ldim,'c',status)
  if (status .ne. 0) return
  !
  status = nf_get_var_text(ncid,varid,varval)
  call handle_err(status,varnam,'cdfr_1c','nf_get_var_text')
]===] [===[
  integer                 :: varid, status, nread
  integer, dimension(1)   :: dimlens,ldim
  if (PRESENT (ier)) ier = 1
  ldim(1) = len(varval)
  call cdfgv(ncid,varnam,varid,dimlens,ldim,'c',status)
  if (status .ne. 0) return
  ! Use the stored character length, then blank-pad the destination.
  nread = min(dimlens(1), ldim(1))
  varval = ' '
  if (nread .gt. 0) then
    status = nf_get_vara_text(ncid,varid,[1],[nread],varval(1:nread))
  end if
  call handle_err(status,varnam,'cdfr_1c','nf_get_vara_text')
]===])
        endif ()
        file (CONFIGURE OUTPUT "${patched}" CONTENT "${code}" @ONLY)
        set_source_files_properties ("${original}" TARGET_DIRECTORY stell PROPERTIES HEADER_FILE_ONLY TRUE)
        target_sources (stell PRIVATE "${patched}")
    endforeach ()
endfunction ()

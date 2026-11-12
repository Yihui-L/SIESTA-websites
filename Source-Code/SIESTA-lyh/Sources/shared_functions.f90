!*******************************************************************************
!>  @file shared_functions.f90
!>  @brief Contains module @ref shared_functions
!
!  Note separating the Doxygen comment block here so detailed decription is
!  found in the Module not the file.
!
!>  Subroutines and functions updating MHD forces and Wmhd.
!*******************************************************************************

      MODULE shared_functions
      USE v3_utilities, ONLY: assert
      USE shared_data
      USE utilities
      USE descriptor_mod, ONLY: INHESSIAN, nprocs, iam, SIESTA_COMM
      USE island_params, ns=>ns_i, hs=>hs_i, mpol=>mpol_i, ntor=>ntor_i
      USE hessian, ONLY: apply_precond, l_Compute_Hessian, apply_colscale
      USE timer_mod, ONLY: time_init_state, time_funci
      USE nscalingtools, ONLY: startglobrow, endglobrow, MPI_ERR,       &
                               PARSOLVER
      USE mpi_inc
      USE GMRES_LIB, ONLY: Truncate
      
      IMPLICIT NONE
      
      CONTAINS

!*******************************************************************************
!  UTILITY SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Compute forces for the perturbed state.
!-------------------------------------------------------------------------------
      SUBROUTINE funct_island
      CALL evaluate_forces
      END SUBROUTINE

!  Keep the no-argument Hessian/Krylov callback separate from the
!  optional pressure check for nonlinear acceptance.
      SUBROUTINE evaluate_forces(pressure_ok)
      USE siesta_bfield, ONLY: update_bfield
      USE siesta_pressure, ONLY: update_pres
      USE siesta_force, ONLY: update_force
      USE siesta_displacement, ONLY: update_upperv
      USE siesta_init, ONLY: init_state
      USE quantities, ONLY: wb, wp
      USE siesta_state, ONLY: Clear_Field_Perts

      IMPLICIT NONE

      LOGICAL, OPTIONAL, INTENT(out) :: pressure_ok

!  Local Variables
      REAL (dp) :: ton
      REAL (dp) :: toff
      REAL (dp) :: skston
      REAL (dp) :: skstoff
      LOGICAL   :: ltype
      INTEGER   :: nsmin
      INTEGER   :: nsmax

!  Start if executable code.
      CALL second0(ton)
      nsmin = MAX(1, startglobrow)
      nsmax = MIN(endglobrow, ns)

      IF (INHESSIAN) THEN
         in_hess_nfunct = in_hess_nfunct + 1
      ELSE
         out_hess_nfunct = out_hess_nfunct + 1
      END IF

      l_update_state = .false.
      IF (l_init_state) THEN
         CALL second0(skston)
         CALL init_state(.false.)
         CALL second0(skstoff)
         time_init_state = time_init_state + (skstoff - skston)
         l_init_state = .FALSE.
      END IF

!  There no need to compute the pertubations if the displacement vector did not
!  change.
      IF (ANY(xc .ne. 0) .or. ALLOCATED(buv_res)) THEN
         CALL update_upperv
         CALL update_bfield(.false.)
         CALL update_pres
      ELSE
         CALL Clear_Field_Perts
      END IF
      CALL update_force(pressure_ok)
      IF (PRESENT(pressure_ok)) THEN
         IF (.NOT.pressure_ok) THEN
            CALL second0(toff)
            time_funci = time_funci + (toff - ton)
            RETURN
         END IF
      END IF

      CALL ASSERT(gamma .ne. one, 'SIESTA REQUIRES gamma != 1')
      wtotal = wb + wp/(gamma - 1)
      IF (wtotal0 .eq. -1) THEN
         wtotal0 = wtotal
      END IF

      gc = gnorm_i*gc

!  Called from gmres. Add back the inital force gc0 or store unpreconditioned
!  forces.
      IF (ALLOCATED(gc0)             .and.                                     &
          (l_getfsq .or. l_conjgrad) .and.                                     &
          l_linearize                .and.                                     &
         .not.l_Compute_Hessian) THEN
         gc = gc + gc0
      END IF

      CALL ASSERT(.not.(l_getfsq .and. inhessian),                             &
                  'l_getfsq must be set to FALSE in Hessian')

      IF (l_getfsq) THEN
!  Compute preconditioned volume-averaged force.
         fsq_total = GetFSQ(nsmin, nsmax)

!  Compute un preconfitioned volume-averaged force.
         IF (ANY(col_scale .ne. one)) THEN
            CALL Apply_ColScale(gc, one/col_scale, nsmin, nsmax)

            fsq_total1 = GetFSQ(nsmin, nsmax)

            CALL Apply_ColScale(gc, col_scale, nsmin, nsmax)
         ELSE
            fsq_total1 = fsq_total
         END IF
      END IF

!  gmres handles preconditioning itself. Do not apply when called from inside
!  gmres or when the hessian is being computed.
      IF (l_ApplyPrecon) THEN
         CALL apply_precond(gc)
      END IF

      CALL second0(toff)
      time_funci = time_funci + (toff - ton)

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Computes the force residul.
!>
!>  The force residul is found by
!>
!>    |F^2| = Fsub.Fsup = f_s*f^s + f_u*f^u + f_v*f^v                        (3)
!>
!>  @param[in] nsmin Minimum radial index.
!>  @param[in] nsmax Maximum radial index.
!>  @returns |F^2|
!-------------------------------------------------------------------------------
      FUNCTION GetFSQ(nsmin, nsmax)
      USE quantities, ONLY: fsubsmncf, fsubumnsf, fsubvmnsf,            &
                            fsupsmncf, fsupumnsf, fsupvmnsf,            &
                            fsubsmnsf, fsubumncf, fsubvmncf,            &
                            fsupsmnsf, fsupumncf, fsupvmncf,            &
                            toupper_forces

      IMPLICIT NONE

!  Declare Arguments
      REAL (dp)               :: GetFSQ
      INTEGER, INTENT(in)     :: nsmin
      INTEGER, INTENT(in)     :: nsmax

!  Local Variables
      REAL (dp), DIMENSION(4) :: temp
      INTEGER                 :: js

!  Start of executable code.
      CALL toupper_forces

      temp(1) = SUM(fsubsmncf(:,:,nsmin:nsmax)**2)
      temp(2) = SUM(fsubumnsf(:,:,nsmin:nsmax)**2)
      temp(3) = SUM(fsubvmnsf(:,:,nsmin:nsmax)**2)
      IF (lasym) THEN
         temp(1) = temp(1) + SUM(fsubsmnsf(:,:,nsmin:nsmax)**2)
         temp(2) = temp(2) + SUM(fsubumncf(:,:,nsmin:nsmax)**2)
         temp(3) = temp(3) + SUM(fsubvmncf(:,:,nsmin:nsmax)**2)
      END IF

!  Volume avereages |F|^2.
      temp(4) = 0
      DO js = nsmin, nsmax
         temp(4) = temp(4)                                                     &
                 + vp_f(js)*SUM(fsupsmncf(:,:,js)*fsubsmncf(:,:,js) +          &
                                fsupumnsf(:,:,js)*fsubumnsf(:,:,js) +          &
                                fsupvmnsf(:,:,js)*fsubvmnsf(:,:,js))
         IF (lasym) THEN
            temp(4) = temp(4)                                                  &
                    + vp_f(js)*SUM(fsupsmnsf(:,:,js)*fsubsmnsf(:,:,js) +       &
                                   fsupumncf(:,:,js)*fsubumncf(:,:,js) +       &
                                   fsupvmncf(:,:,js)*fsubvmncf(:,:,js))
         END IF
      END DO
#if defined(MPI_OPT)         
      IF (PARSOLVER) THEN
!  FIXME: All reduce is not deterministic. This causes a divergent run sequence.
         CALL MPI_ALLREDUCE(MPI_IN_PLACE, temp, 4, MPI_REAL8, MPI_SUM,         &
                            SIESTA_COMM, MPI_ERR)
      END IF
#endif

      fsqvs = hs*temp(1)
      fsqvu = hs*temp(2)
      fsqvv = hs*temp(3)

      GetFSQ = temp(4)/SUM(vp_f)

      END FUNCTION

!-------------------------------------------------------------------------------
!>  @brief Get the perturbed MHD and Kinetic energy.
!>
!>  @param[in] p Displacement vector.
!>  @return The total stored energy.
!-------------------------------------------------------------------------------
      FUNCTION getwmhd(p)

      IMPLICIT NONE

!  Declare Arguments
      REAL (dp)                           :: getwmhd
      REAL (dp), DIMENSION(:), INTENT(in) :: p

!  Start of executable code.
      xc = p
      l_init_state = .true.
      l_linearize  = .false.
      l_getwmhd    = .true.
      l_getfsq     = .false.

      CALL funct_island

      l_getwmhd    = .false.

      getwmhd = wtotal

      END FUNCTION

!-------------------------------------------------------------------------------
!>  @brief Minimize the nonlinear force residual along a trial displacement.
!>
!>  @param[inout] xcmin Trial direction on entry, accepted displacement on exit.
!>  @param[out]   fsq_min Residual of the accepted state.
!-------------------------------------------------------------------------------
      SUBROUTINE LineSearch(xcmin, fsq_min)
      USE, INTRINSIC :: ieee_arithmetic, ONLY: ieee_is_finite
      USE siesta_namelist, ONLY: ftol, l_vessel
      USE stel_constants, ONLY: pi, twopi
      USE island_params, ONLY: fourier_context, nfp_i, nu_i, nv_i
      USE fourier, ONLY: fourier_class, f_none, f_cos, f_sin, f_sum
      USE quantities, ONLY: jmnc, jmns, jpmnch, jpmnsh, djpmnch, djpmnsh, signjac
      USE siesta_displacement, ONLY: update_upperv
      USE siesta_pressure, ONLY: update_pres
      USE siesta_force, ONLY: pressure_rtol
      USE shared_data, ONLY: nsp
      USE hessian, ONLY: gather_array

      REAL(dp), DIMENSION(neqs), INTENT(inout) :: xcmin
      REAL(dp), INTENT(out)                    :: fsq_min

      INTEGER, PARAMETER :: max_trials = 40, max_shells = 3
      INTEGER, PARAMETER :: angular_refinement = 4
      REAL(dp), PARAMETER :: short_step = 0.125_dp, boundary_fraction = 0.9_dp
      TYPE(fourier_class), POINTER :: check_fourier
      REAL(dp), ALLOCATABLE :: selected(:), alternative(:)
      REAL(dp), ALLOCATABLE :: check_jac(:,:,:), base_p(:,:,:), sample_p(:,:,:)
      REAL(dp), ALLOCATABLE :: curvature_weight(:,:)
      REAL(dp) :: best_fac, accepted_fac, check_tol
      INTEGER :: direction_flags(2), pressure_rejections
      INTEGER :: j1, j2, limiting_shell, masked_shell, pass
      LOGICAL :: pressure_ok, use_alternative, base_is_feasible

!  Compare to the committed state, even if a Krylov callback left trial forces.
      xc = zero
      l_init_state = .TRUE.
      l_linearize = .FALSE.
      l_getfsq = .TRUE.
      l_getwmhd = .TRUE.
      l_ApplyPrecon = .FALSE.
      CALL evaluate_forces(pressure_ok)
      CALL assert(pressure_ok, 'Invalid pressure in the committed state before line search')
      CALL assert(ieee_is_finite(fsq_total1).AND.fsq_total1.GE.zero,          &
                  'Invalid force residual in the committed state before line search')
      fsq_min = fsq_total1
      best_fac = zero
      pressure_rejections = 0
      use_alternative = .FALSE.
      base_is_feasible = .TRUE.
      NULLIFY(check_fourier)

      direction_flags(1) = MERGE(0, 1, ALL(ieee_is_finite(xcmin)))
      direction_flags(2) = MERGE(0, 1, ALL(xcmin .EQ. zero))
#if defined(MPI_OPT)
      IF (PARSOLVER) THEN
         CALL MPI_ALLREDUCE(MPI_IN_PLACE, direction_flags, 2, MPI_INTEGER,   &
                            MPI_MAX, SIESTA_COMM, MPI_ERR)
      END IF
#endif

      IF (fsq_min .GT. ftol .AND. direction_flags(1) .EQ. 0 .AND.            &
                                 direction_flags(2) .NE. 0) THEN
         ALLOCATE(selected(neqs))
         selected = zero
         IF (l_vessel) CALL setup_pressure_grid

         IF (iam .EQ. 0 .AND. lverbose) WRITE (*,1000)
         CALL search_direction(xcmin, accepted_fac, limiting_shell)

!  A small pressure bound can prevent useful motion in the whole domain.
!  Use an independent trial direction supported away from the active shell.
!  Its two adjoining full-grid displacement rows are zero only for this
!  trial. The physical wall constraints and both ideal update operators
!  are unchanged. Compare every alternative against the best full-domain
!  nonlinear residual found so far.
         IF (l_vessel .AND. fsq_min .GT. ftol .AND. limiting_shell .GT. 0 .AND. &
             accepted_fac .LT. short_step) THEN
            ALLOCATE(alternative(neqs))
            alternative = xcmin
            DO pass = 1, max_shells
               masked_shell = limiting_shell
               CALL mask_shell(alternative, masked_shell)
               CALL search_direction(alternative, accepted_fac, limiting_shell)
               IF (accepted_fac .GT. zero) use_alternative = .TRUE.
               IF (fsq_min .LE. ftol .OR. accepted_fac .GE. short_step .OR.    &
                   limiting_shell .EQ. 0 .OR. limiting_shell .EQ. masked_shell) EXIT
            END DO
            IF (fsq_min .GT. ftol .AND. accepted_fac .LT. short_step) THEN
               CALL search_interior_force(alternative)
            END IF
         END IF
         xcmin = selected
      ELSE
         xcmin = zero
      END IF

      IF (iam .EQ. 0 .AND. pressure_rejections .GT. 0) THEN
         IF (lverbose) WRITE (*,1002) pressure_rejections, best_fac
         WRITE (unit_out,1002) pressure_rejections, best_fac
      END IF
      IF (iam .EQ. 0 .AND. use_alternative) THEN
         IF (lverbose) WRITE (*,1003) best_fac
         WRITE (unit_out,1003) best_fac
      END IF
      IF (iam .EQ. 0 .AND. .NOT.base_is_feasible .AND. best_fac .EQ. zero) THEN
         IF (lverbose) WRITE (*,1004)
         WRITE (unit_out,1004)
      END IF

!  Leave increments corresponding to the selected state for update_state.
      xc = xcmin
      l_PrintOriginForces = .TRUE.
      CALL evaluate_forces(pressure_ok)
      l_PrintOriginForces = .FALSE.
      CALL assert(pressure_ok, 'Invalid pressure in the selected state after line search')
      IF (ASSOCIATED(check_fourier)) THEN
         IF (best_fac .GT. zero) CALL assert(sampled_pressure_ok(),           &
                                 'Invalid sampled pressure in the selected ideal state')
         DEALLOCATE(check_fourier)
      END IF
      fsq_min = fsq_total1

1000  FORMAT(/,1x,'LINE SEARCH - SCAN ||X|| FOR MIN FSQ_NL',/,1x,15('-'),      &
             /,1x,'ITER',7x,'FSQ_NL',10x,'||X||',10x,'MAX|X|',10x,'FAC')
1002  FORMAT(1x,'LINE SEARCH: ',i3,' PRESSURE REJECTIONS, ACCEPTED SCALE=',1pe12.4)
1003  FORMAT(1x,'LINE SEARCH: PRESSURE-LIMITED DIRECTION REPLACED, ACCEPTED SCALE=',1pe12.4)
1004  FORMAT(1x,'LINE SEARCH: NO DECREASING STEP TO RESTORE SAMPLED PRESSURE')

      CONTAINS

      SUBROUTINE setup_pressure_grid
      INTEGER :: nu, nv, stride, m, n
      REAL(dp) :: du, dzeta
      LOGICAL :: bad_jacobian

!  A nested mesh includes every solver angle and checks intermediate angles.
!  Keep the solve's normalization, including its special Nyquist mode.
      nu = angular_refinement*(nu_i - 1) + 1
      IF (lasym) nu = angular_refinement*nu_i
      nv = angular_refinement*nv_i
      check_fourier => fourier_class(mpol, ntor, nu, nv, nfp_i, lasym,      &
                                    fourier_context%tor_modes)
      check_fourier%orthonorm = fourier_context%orthonorm
      du = pi/(nu - 1)
      IF (lasym) du = twopi/nu
      dzeta = twopi/nv
      ALLOCATE(curvature_weight(0:mpol,-ntor:ntor))
      DO n = -ntor, ntor
         DO m = 0, mpol
            curvature_weight(m,n) = check_fourier%orthonorm(m,n) *      &
                 ((du*m)**2 + (dzeta*fourier_context%tor_modes(n))**2)/8
         END DO
      END DO
      j1 = MAX(2, startglobrow)
      j2 = endglobrow
      ALLOCATE(check_jac(nu,nv,j1:j2), base_p(nu,nv,j1:j2), sample_p(nu,nv,j1:j2))
      CALL check_fourier%toijsp(jmnc(:,:,j1:j2), check_jac, f_none, f_cos)
      IF (lasym) CALL check_fourier%toijsp(jmns(:,:,j1:j2), check_jac, f_sum, f_sin)
      bad_jacobian = ANY(.NOT.ieee_is_finite(check_jac)) .OR. ANY(signjac*check_jac .LE. zero)
#if defined(MPI_OPT)
      IF (PARSOLVER) CALL MPI_ALLREDUCE(MPI_IN_PLACE, bad_jacobian, 1, MPI_LOGICAL, &
                                      MPI_LOR, SIESTA_COMM, MPI_ERR)
#endif
      CALL assert(.NOT.bad_jacobian, 'Invalid Jacobian on the pressure check grid')
      CALL check_fourier%toijsp(jpmnch(:,:,j1:j2), base_p, f_none, f_cos)
      IF (lasym) CALL check_fourier%toijsp(jpmnsh(:,:,j1:j2), base_p, f_sum, f_sin)
      base_p = base_p/check_jac
!  Keep the tolerance tied to the same physical samples as the original guard.
      stride = angular_refinement
      check_tol = pressure_rtol*MAXVAL(ABS(base_p(1::stride,1::stride,:)))
#if defined(MPI_OPT)
      IF (PARSOLVER) CALL MPI_ALLREDUCE(MPI_IN_PLACE, check_tol, 1, MPI_REAL8, &
                                      MPI_MAX, SIESTA_COMM, MPI_ERR)
#endif
      IF (lasym) THEN
         CALL subtract_pressure_error(base_p, jpmnch(:,:,j1:j2), jpmnsh(:,:,j1:j2))
      ELSE
         CALL subtract_pressure_error(base_p, jpmnch(:,:,j1:j2))
      END IF
      base_is_feasible = pressure_samples_ok(base_p)
      END SUBROUTINE setup_pressure_grid

      SUBROUTINE subtract_pressure_error(values, cosine_coeff, sine_coeff)
!  Bound pressure between samples, assuming the coordinate Jacobian keeps
!  its orientation. For signed J*p, bilinear interpolation error on each
!  angular rectangle is bounded by du**2*max|q_uu|/8 + dz**2*max|q_zz|/8.
!  The absolute Fourier coefficient sum bounds each second derivative.
      REAL(dp), INTENT(INOUT) :: values(:,:,j1:)
      REAL(dp), INTENT(IN) :: cosine_coeff(:,:,j1:)
      REAL(dp), INTENT(IN), OPTIONAL :: sine_coeff(:,:,j1:)
      REAL(dp) :: error
      INTEGER :: j

      DO j = j1, j2
         error = SUM(curvature_weight*ABS(cosine_coeff(:,:,j)))
         IF (PRESENT(sine_coeff)) error = error + SUM(curvature_weight*ABS(sine_coeff(:,:,j)))
         values(:,:,j) = values(:,:,j) - error/ABS(check_jac(:,:,j))
      END DO
      END SUBROUTINE subtract_pressure_error

      LOGICAL FUNCTION pressure_samples_ok(values)
      REAL(dp), INTENT(IN) :: values(:,:,:)
      pressure_samples_ok = ALL(ieee_is_finite(values)) .AND. ALL(values .GE. -check_tol)
#if defined(MPI_OPT)
      IF (PARSOLVER) CALL MPI_ALLREDUCE(MPI_IN_PLACE, pressure_samples_ok, 1, MPI_LOGICAL, &
                                      MPI_LAND, SIESTA_COMM, MPI_ERR)
#endif
      END FUNCTION pressure_samples_ok

      LOGICAL FUNCTION sampled_pressure_ok()
!  Validate the total coefficients to be committed, including transform roundoff.
      CALL check_fourier%toijsp(jpmnch(:,:,j1:j2) + djpmnch(:,:,j1:j2), sample_p, f_none, f_cos)
      IF (lasym) CALL check_fourier%toijsp(jpmnsh(:,:,j1:j2) + djpmnsh(:,:,j1:j2), sample_p, f_sum, f_sin)
      sample_p = sample_p/check_jac
      IF (lasym) THEN
         CALL subtract_pressure_error(sample_p, jpmnch(:,:,j1:j2) + djpmnch(:,:,j1:j2), &
                                                jpmnsh(:,:,j1:j2) + djpmnsh(:,:,j1:j2))
      ELSE
         CALL subtract_pressure_error(sample_p, jpmnch(:,:,j1:j2) + djpmnch(:,:,j1:j2))
      END IF
      sampled_pressure_ok = pressure_samples_ok(sample_p)
      END FUNCTION sampled_pressure_ok

      SUBROUTINE pressure_interval(direction, lower, upper, shell)
      REAL(dp), INTENT(IN)  :: direction(neqs)
      REAL(dp), INTENT(OUT) :: lower, upper
      INTEGER, INTENT(OUT) :: shell
      REAL(dp) :: p, dp_step, max_decrease, bounds(2)
      INTEGER :: j, u, v, local_shell

!  With fixed base fields the existing pressure increment is linear in xc.
!  Use its actual Fourier projection to estimate the feasible interval.
      xc = direction
      CALL update_upperv
      CALL update_pres
      CALL check_fourier%toijsp(djpmnch(:,:,j1:j2), sample_p, f_none, f_cos)
      IF (lasym) CALL check_fourier%toijsp(djpmnsh(:,:,j1:j2), sample_p, f_sum, f_sin)
      sample_p = sample_p/check_jac
!  Triangle inequality gives a sufficient affine pressure bound for all
!  positive steps along this direction. Certify the selected total field
!  again using its combined coefficients.
      IF (lasym) THEN
         CALL subtract_pressure_error(sample_p, djpmnch(:,:,j1:j2), djpmnsh(:,:,j1:j2))
      ELSE
         CALL subtract_pressure_error(sample_p, djpmnch(:,:,j1:j2))
      END IF
      lower = zero
      upper = one
      local_shell = HUGE(1)
      DO j = j1, j2
         DO v = 1, SIZE(sample_p,2)
            DO u = 1, SIZE(sample_p,1)
               p = base_p(u,v,j)
               dp_step = sample_p(u,v,j)
!  Treat roundoff-level negative p as active, without changing any coefficient.
               IF (p .GE. -check_tol) p = MAX(zero,p)
               IF (.NOT.ieee_is_finite(dp_step) .OR.                            &
                   (p .LT. zero .AND. dp_step .LE. -p)) THEN
                  lower = 2*one
               ELSE IF (p .LT. zero) THEN
                  lower = MAX(lower, -p/dp_step)
               ELSE IF (dp_step .LT. -p) THEN
                  max_decrease = p/(-dp_step)
                  IF (max_decrease .LT. upper) THEN
                     upper = max_decrease
                     local_shell = j
                  END IF
               END IF
            END DO
         END DO
      END DO
      bounds = [lower, -upper]
#if defined(MPI_OPT)
      IF (PARSOLVER) CALL MPI_ALLREDUCE(MPI_IN_PLACE, bounds, 2, MPI_REAL8,  &
                                      MPI_MAX, SIESTA_COMM, MPI_ERR)
#endif
      shell = HUGE(1)
      IF (upper .EQ. -bounds(2)) shell = local_shell
#if defined(MPI_OPT)
      IF (PARSOLVER) CALL MPI_ALLREDUCE(MPI_IN_PLACE, shell, 1, MPI_INTEGER, &
                                      MPI_MIN, SIESTA_COMM, MPI_ERR)
#endif
      IF (shell .EQ. HUGE(1)) shell = 0
      lower = bounds(1)
      upper = -bounds(2)
      END SUBROUTINE pressure_interval

      SUBROUTINE mask_shell(direction, shell)
      REAL(dp), INTENT(INOUT) :: direction(neqs)
      INTEGER, INTENT(IN) :: shell
      INTEGER, PARAMETER :: taper_rows = 3
      REAL(dp) :: weight
      INTEGER :: j, distance
      DO j = MAX(1,shell-taper_rows), MIN(ns,shell+taper_rows-1)
         distance = MIN(ABS(j-shell), ABS(j-(shell-1)))
         weight = REAL(distance,dp)/taper_rows
         direction((j-1)*mblk_size+1:j*mblk_size) = weight**2*(3-2*weight) * &
                                      direction((j-1)*mblk_size+1:j*mblk_size)
      END DO
      END SUBROUTINE mask_shell

      SUBROUTINE search_interior_force(direction)
      REAL(dp), INTENT(OUT) :: direction(neqs)
      REAL(dp) :: step_norm_sq, force_norm, taper, accepted
      INTEGER :: j, shell, first, last

!  Masking a Newton step can lose its force descent. Try a different
!  wall-compatible direction from the current force, restricted to the
!  interior and smoothly tapered to zero at the original LCFS. The force
!  is not the gradient of the force norm, so check both signs against F**2.
      xc = zero
      CALL evaluate_forces(pressure_ok)
      direction = -gc
      CALL gather_array(direction)
      DO j = 1, ns
         taper = MIN(one, MAX(zero, REAL(nsp-j,dp)/MAX(1,ns-nsp)))
         direction((j-1)*mblk_size+1:j*mblk_size) = taper**2*(3-2*taper) * &
                                      direction((j-1)*mblk_size+1:j*mblk_size)
      END DO

!  Match the Newton displacement's scale using owned radial rows only.
      first = (startglobrow-1)*mblk_size + 1
      last = endglobrow*mblk_size
      step_norm_sq = SUM(xcmin(first:last)**2)
#if defined(MPI_OPT)
      IF (PARSOLVER) CALL MPI_ALLREDUCE(MPI_IN_PLACE, step_norm_sq, 1, MPI_REAL8, &
                                      MPI_SUM, SIESTA_COMM, MPI_ERR)
#endif
      force_norm = NORM2(direction)
      IF (force_norm .LE. zero .OR. .NOT.ieee_is_finite(force_norm) .OR. &
          step_norm_sq .LE. zero .OR. .NOT.ieee_is_finite(step_norm_sq)) RETURN
      direction = direction*(SQRT(step_norm_sq)/force_norm)
      CALL search_direction(direction, accepted, shell)
      IF (accepted .GT. zero) use_alternative = .TRUE.
      IF (fsq_min .LE. ftol) RETURN
      direction = -direction
      CALL search_direction(direction, accepted, shell)
      IF (accepted .GT. zero) use_alternative = .TRUE.
      END SUBROUTINE search_interior_force

      SUBROUTINE search_direction(direction, accepted, shell)
      REAL(dp), INTENT(IN)  :: direction(neqs)
      REAL(dp), INTENT(OUT) :: accepted
      INTEGER, INTENT(OUT) :: shell
      REAL(dp) :: fac, lower, upper
      INTEGER :: iter
      LOGICAL :: improved

      accepted = zero
      shell = 0
      lower = zero
      fac = one
      IF (ASSOCIATED(check_fourier)) THEN
         CALL pressure_interval(direction, lower, upper, shell)
         IF (upper .LE. lower .OR. upper .LE. EPSILON(one)) RETURN
         IF (upper .LT. one) fac = lower + boundary_fraction*(upper - lower)
      END IF
      DO iter = 1, max_trials
         xc = fac*direction
         CALL evaluate_forces(pressure_ok)
         IF (pressure_ok .AND. ASSOCIATED(check_fourier)) pressure_ok = sampled_pressure_ok()
         improved = .FALSE.
         IF (pressure_ok) THEN
            IF (iam .EQ. 0 .AND. lverbose) THEN
               WRITE (*,'(i5,4(3x,1pe12.3))') iter, fsq_total1,              &
                         SQRT(SUM(xc*xc)), MAXVAL(ABS(xc)), fac
            END IF
            IF (ieee_is_finite(fsq_total).AND.ieee_is_finite(fsq_total1)      &
                .AND.ieee_is_finite(wtotal)) THEN
               improved = fsq_total1 .GE. zero .AND. fsq_total1 .LT. fsq_min
            END IF
            IF (improved) THEN
               fsq_min = fsq_total1
               best_fac = fac
               accepted = fac
               selected = xc
            END IF
         ELSE
            pressure_rejections = pressure_rejections + 1
         END IF
         IF (fsq_min .LE. ftol .OR. (accepted .GT. zero .AND. .NOT.improved)) EXIT
         fac = fac/SQRT2
         IF (fac .LE. lower) EXIT
      END DO
      END SUBROUTINE search_direction

      END SUBROUTINE LineSearch

!-------------------------------------------------------------------------------
!>  @brief Initializes pointers for xc (displacement variable) and gc (force)
!>         residules.
!>
!>  @param[in]  xtarget   State array to point to.
!>  @param[out] s_ptr_sym Stellarator symmetric term for the s component.
!>  @param[out] u_ptr_sym Stellarator symmetric term for the u component.
!>  @param[out] v_ptr_sym Stellarator symmetric term for the v component.
!>  @param[out] s_ptr_asym Stellarator asymmetric term for the s component.
!>  @param[out] u_ptr_asym Stellarator asymmetric term for the u component.
!>  @param[out] v_ptr_asym Stellarator asymmetric term for the v component.
!-------------------------------------------------------------------------------
      SUBROUTINE init_ptrs(xtarget, s_ptr_sym, u_ptr_sym, v_ptr_sym,           &
                           s_ptr_asym, u_ptr_asym, v_ptr_asym)

      IMPLICIT NONE

!  Declare Arguments
      REAL (dp), DIMENSION(0:mpol,-ntor:ntor,ndims,ns), TARGET, INTENT(in) ::  &
         xtarget
      REAL (dp), DIMENSION(:,:,:), POINTER :: s_ptr_sym
      REAL (dp), DIMENSION(:,:,:), POINTER :: u_ptr_sym
      REAL (dp), DIMENSION(:,:,:), POINTER :: v_ptr_sym
      REAL (dp), DIMENSION(:,:,:), POINTER :: s_ptr_asym
      REAL (dp), DIMENSION(:,:,:), POINTER :: u_ptr_asym
      REAL (dp), DIMENSION(:,:,:), POINTER :: v_ptr_asym

!  Start of executable code.

!  Set stellarator symmetric pointers.
      s_ptr_sym => xtarget(:,:,1,:)
      u_ptr_sym => xtarget(:,:,2,:)
      v_ptr_sym => xtarget(:,:,3,:)

!  The number of dimensions if double when lasym is true. Set the stellarator
!  asymmetric pointers.
      IF (ndims .eq. 6) THEN
         s_ptr_asym => xtarget(:,:,4,:)
         u_ptr_asym => xtarget(:,:,5,:)
         v_ptr_asym => xtarget(:,:,6,:)
      END IF

      END SUBROUTINE

      END MODULE

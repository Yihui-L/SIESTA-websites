!> Advance the artificial resistive magnetic field at fixed pressure.
      SUBROUTINE add_resistive_E
      USE stel_kinds, ONLY: dp
      USE, INTRINSIC :: ieee_arithmetic, ONLY: ieee_is_finite
      USE shared_data, ONLY: l_getfsq, l_init_state, lverbose, l_update_state, &
                             unit_out, fsq_total, fsq_total1, xc, lasym
      USE shared_functions, ONLY: funct_island
      USE siesta_namelist, ONLY: ftol, eta_factor
      USE descriptor_mod, ONLY: iam
      USE quantities, ONLY: wb, jbsupsmnsh, jbsupumnch, jbsupvmnch,           &
                            jbsupsmnch, jbsupumnsh, jbsupvmnsh
      USE siesta_bfield, ONLY: update_bfield
      USE siesta_displacement, ONLY: update_upperv
      USE siesta_init, ONLY: init_state
      USE siesta_state, ONLY: update_state
      IMPLICIT NONE

      INTEGER, PARAMETER :: nits = 10, max_attempts = 8
      REAL(dp), PARAMETER :: zero = 0.0_dp
      REAL(dp) :: trial_eta, initial_fsq, initial_scaled_fsq, initial_wb, energy_slack
      REAL(dp), ALLOCATABLE :: initial_b(:,:,:,:)
      INTEGER :: attempt, itime, j
      LOGICAL :: lverb_save, accepted

      IF (fsq_total1 .LE. ftol .OR. eta_factor .EQ. zero) RETURN

      initial_fsq = fsq_total1
      initial_scaled_fsq = fsq_total
      initial_wb = wb
      energy_slack = 128*EPSILON(initial_wb)*ABS(initial_wb)
      trial_eta = eta_factor
      lverb_save = lverbose
      lverbose = .FALSE.
      l_update_state = .FALSE.
      xc = zero
      l_getfsq = .FALSE.
      CALL init_state(.FALSE.)
      CALL update_upperv

!  Keep a full replicated snapshot. update_state gathers the spectral field
!  after each substep, so restoring the snapshot also restores its MPI halos.
      ALLOCATE(initial_b(SIZE(jbsupsmnsh,1), SIZE(jbsupsmnsh,2),              &
                         SIZE(jbsupsmnsh,3), MERGE(6,3,lasym)))
      initial_b(:,:,:,1) = jbsupsmnsh
      initial_b(:,:,:,2) = jbsupumnch
      initial_b(:,:,:,3) = jbsupvmnch
      IF (lasym) THEN
         initial_b(:,:,:,4) = jbsupsmnch
         initial_b(:,:,:,5) = jbsupumnsh
         initial_b(:,:,:,6) = jbsupvmnsh
      END IF

      DO attempt = 1, max_attempts
         eta_factor = trial_eta/nits
         fsq_total = initial_scaled_fsq
         l_getfsq = .FALSE.
         DO itime = 1, nits
            CALL init_state(.TRUE.)
            CALL update_bfield(.TRUE.)
            CALL update_state(.FALSE., zero, zero)
         END DO

         l_getfsq = .TRUE.
         l_init_state = .TRUE.
         CALL funct_island

!  With no boundary work, ordinary diffusion should dissipate magnetic
!  energy. Limit the force jump of the accepted batch, allowing moderate
!  increases because this split step does not solve force balance.
         accepted = .FALSE.
         IF (ieee_is_finite(wb).AND.ieee_is_finite(fsq_total)                &
                               .AND.ieee_is_finite(fsq_total1)) THEN
            accepted = wb-initial_wb .LE. energy_slack                      &
                       .AND. fsq_total1 .GE. zero                          &
                       .AND. fsq_total1/4 .LE. initial_fsq
         END IF
         IF (accepted) EXIT

         IF (iam .EQ. 0) THEN
            DO j = 6, unit_out, unit_out-6
               IF (.NOT.lverb_save .AND. j.EQ.6) CYCLE
               WRITE (j,'(A,I2,A,1P,3E13.5)') ' RESISTIVE BATCH REJECTED, TRY ', attempt, &
                  ' ETA, TRIAL F2, DELTA WB: ', trial_eta, fsq_total1, wb-initial_wb
            END DO
         END IF
         jbsupsmnsh = initial_b(:,:,:,1)
         jbsupumnch = initial_b(:,:,:,2)
         jbsupvmnch = initial_b(:,:,:,3)
         IF (lasym) THEN
            jbsupsmnch = initial_b(:,:,:,4)
            jbsupumnsh = initial_b(:,:,:,5)
            jbsupvmnsh = initial_b(:,:,:,6)
         END IF
         trial_eta = 0.5_dp*trial_eta
      END DO

      eta_factor = trial_eta
      IF (.NOT.accepted) THEN
!  Refresh derived quantities for the restored state, including force spectra.
         l_init_state = .TRUE.
         CALL funct_island
      ELSE IF (attempt .EQ. 1 .AND. fsq_total1 .GT. ftol .AND.          &
               trial_eta .LE. HUGE(trial_eta)/1.1_dp) THEN
!  Never enlarge the next explicit batch by an unbounded residual ratio.
         IF (fsq_total1 .LE. initial_fsq) THEN
            eta_factor = 1.1_dp*trial_eta
         ELSE IF (fsq_total1/1.1_dp .LT. initial_fsq) THEN
            eta_factor = trial_eta*(initial_fsq/(fsq_total1/1.1_dp))
         END IF
      END IF

      lverbose = lverb_save
      IF (iam .EQ. 0) THEN
         DO j = 6, unit_out, unit_out-6
            IF (.NOT.lverbose .AND. j.EQ.6) CYCLE
            IF (accepted) THEN
               WRITE (j,'(/,A,I3)') ' UPDATING RESISTIVE E-FIELD: ITERATIONS=', nits
               WRITE (j,'(A,1P,2E12.3)') ' JUMP IN FSQ DUE TO RESISTIVE DIFFUSION: ', initial_fsq, fsq_total1
            ELSE
               WRITE (j,'(A)') ' RESISTIVE BATCH SKIPPED: NO ACCEPTABLE TRIAL'
            END IF
         END DO
      END IF

      END SUBROUTINE add_resistive_E

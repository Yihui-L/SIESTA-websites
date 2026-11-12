!*******************************************************************************
!>  @file siesta_unit_tests.f90
!>  @brief Contains main routines for SIESTA unit tests.
!
!  Note separating the Doxygen comment block here so detailed decription is
!  found in the Module not the file.
!
!>  These run the embeded units tests in SIESTA.
!*******************************************************************************
!*******************************************************************************
!  MAIN PROGRAM
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief SIESTA Unit tests main program.
!>
!>  Highest level SIESTA unit test routine.
!-------------------------------------------------------------------------------
      PROGRAM siesta_unit_tests
      USE fourier
      USE restart_mod, ONLY: interpit, interpit_1d
      USE perturbation, ONLY: test_find_resonance
      USE evolution, ONLY: test_evolution_controls
      USE shared_data, ONLY: ndims

      IMPLICIT NONE

!  Local variables
      LOGICAL :: test_passed
      REAL(dp) :: half_grid(9)
      REAL(dp) :: old_modes(0:0,-1:1,5), new_modes(0:0,-3:3,5)
      REAL(dp) :: dblk(3,3,2), lblk(3,3,2), ublk(3,3,2), asym
      INTEGER :: j

!  Start of executable code.
      test_passed = test_fourier()
      IF (.not.test_passed) THEN
         WRITE (*,*) 'test_fourier failed.'
      END IF

      IF (.not.test_passed) THEN
         CALL exit(1)
      END IF

!  A linear profile on the half mesh must interpolate exactly and retain
!  the unused origin slot. A three-period mode must move to n=3 in a
!  one-period basis when the toroidal mode count changes.
      CALL interpit_1d([0.0_dp, 0.125_dp, 0.375_dp, 0.625_dp, 0.875_dp],
     &                 half_grid, 5, 9, .true., -1)
      IF (half_grid(1) .ne. 0.0_dp .or.
     &    MAXVAL(ABS(half_grid(2:) - [( (j-1.5_dp)/8, j=2,9 )]))
     &        .gt. 1.0e-13_dp) STOP 1
      old_modes = 0.0_dp
      old_modes(0,1,:) = 7.0_dp
      CALL interpit(old_modes, new_modes, 5, 5, 0, 0, 1, 3, 3, 1,
     &              [-1,0,1], [-3,-2,-1,0,1,2,3], .false.)
      IF (ANY(new_modes(0,3,:) .ne. 7.0_dp) .or.
     &    ANY(new_modes(:,-3:2,:) .ne. 0.0_dp)) STOP 1
      IF (.not.test_find_resonance()) THEN
         WRITE (*,*) 'test_find_resonance failed'
         STOP 1
      END IF

      IF (.not.test_evolution_controls()) STOP 1

!  Each off-diagonal pair contributes twice to ||A - transpose(A)||_F^2.
!  Three independent copies of [1,3;1,2] have the same relative norm.
      ndims = 3
      dblk = 0; lblk = 0; ublk = 0
      DO j = 1, 3
         dblk(j,j,:) = [1.0_dp, 2.0_dp]
         ublk(j,j,1) = 3.0_dp
         lblk(j,j,2) = 1.0_dp
      END DO
      CALL check3d_symmetry_serial(dblk,lblk,ublk,0,0,3,2,asym)
      IF (ABS(asym-SQRT(8.0_dp/15.0_dp)).gt.1.0e-13_dp) STOP 1
      dblk = 0; lblk = 0; ublk = 0
      CALL check3d_symmetry_serial(dblk,lblk,ublk,0,0,3,2,asym)
      IF (asym.ne.-1.0_dp) STOP 1

      END PROGRAM

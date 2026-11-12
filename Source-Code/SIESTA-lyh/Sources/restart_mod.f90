!-------------------------------------------------------------------------------
!  The @header, @table_section, @table_subsection, @item and @end_table commands
!  are custom defined commands in Doxygen.in. They are defined under ALIASES.
!  For the page created here, the 80 column limit is exceeded. Arguments of
!  aliases are separated by ','. If you intended ',' to be a string you must use
!  an escaped comma '\,'.
!
!>  @page siesta_restart_sec Discription of the SIESTA restart file.
!>
!>  @tableofcontents
!>  @section siesta_restart_intro_sec Introduction
!>  This page documents the contents of a SIESTA restart file.
!>
!>  @section siesta_restart_var_sec Namelist Variables
!>  @header{Input variable, Description, Code Reference}
!>
!>  @table_section{siesta_restart_flag_sec, Control Flags}
!>     @item{state_flags, State flags of the model. Aditionally stores the
!>                        version number in the first 31 bits.
!>                        * restart_version
!>                        * restart_lasym,               }
!>     @item{wout_file,   Name of the inital wout_file., siesta_namelist::wout_file}
!>  @end_table
!>
!>  @table_section{siesta_restart_size_sec, Dimension sizes.}
!>     @item{mpol, Number of torodial modes.,  siesta_namelist::mpolin}
!>     @item{nfp,  Number of field periods.,   siesta_namelist::nfpin}
!>     @item{nrad, Number of radial surfaces., island_params::ns_i}
!>     @item{ntor, Maximum torodal mode.,      siesta_namelist::ntorin}
!>  @end_table
!>
!>  @table_section{siesta_restart_norm_fact_sec, Normalization factors.}
!>     @item{b_factor, Normalization factor for the magnetic field., quantities::b_factor}
!>     @item{p_factor, Normalization factor for the pressure.,       quantities::p_factor}
!>  @end_table
!>
!>  @table_section{siesta_restart_scalar_sec, Scalar quantities.}
!>     @item{curtor,  The toroidal current.,                       shared_data::siesta_curtor}
!>     @item{p_max,   Maximum pressure.,                           }
!>     @item{p_min,   Minimum pressure.,                           }
!>     @item{rmajor,  Major radius.,                               island_params::rmajor_i}
!>     @item{wb0,     Inital Energy stored in the magnetid field., island_params::wb_i}
!>     @item{wp0,     Inital Energy stored in the pressure.,       island_params::wp_i}
!>     @item{wb,      Energy stored in the magnetid field.,        quantities::wb}
!>     @item{wp,      Energy stored in the pressure.,              quantities::wp}
!>     @item{wtotal0, Inital total energy.,                        shared_data::wtotal0}
!>     @item{wtotal,  Total energy.,                               shared_data::wtotal}
!>     @item{fsq,     Volumne averaged force residule fsub.fsup.,  shared_data::fsq_total1}
!>  @end_table
!>
!>  @table_section{siesta_restart_1D_arrays_sec, 1D profiles.}
!>     @item{chipf_r_,  Radial derivative of the poloidal flux., island_params::chipf_i}
!>     @item{phipf_r_,  Radial derivative of the toroidal flux., island_params::phipf_i}
!>     @item{chif_r_,   Poloidal flux profile.,                  island_params::chif_i}
!>     @item{phif_r_,   Toroidal flux profile.,                  island_params::phif_i}
!>     @item{tor_modes, Toroidal mode array.,                    fourier::fourier_class::tor_modes}
!>  @end_table
!>
!>  @table_section{siesta_restart_2D_arrays_sec, 2D arrays.}
!>     @item{found_modes, List of found resonances., fourier::fourier_class::found_modes}
!>  @end_table
!>
!>  @table_section{siesta_restart_3D_arrays_sec, 3D arrays.}
!>     @table_subsection{siesta_restart_internal_arrays_sec, Internal arrays}
!>        @item{JBsupssh_m_n_r_, Normalized JB^s component sine parity.,   quantities::jbsupsmnsh}
!>        @item{JBsupuch_m_n_r_, Normalized JB^u component cosine parity., quantities::jbsupumnch}
!>        @item{JBsupvch_m_n_r_, Normalized JB^v component cosine parity., quantities::jbsupvmnch}
!>        @item{jpresch_m_n_r_,  Normalized JP   component cosine parity., quantities::jpmnch}
!>     @table_subsection{siesta_restart_internal_arrays_asym_sec, Internal arrays asym.}
!>        @item{JBsupsch_m_n_r_, Normalized JB^s component cosine parity., quantities::jbsupsmnch}
!>        @item{JBsupush_m_n_r_, Normalized JB^u component sine parity.,   quantities::jbsupumnsh}
!>        @item{JBsupvsh_m_n_r_, Normalized JB^v component sine parity.,   quantities::jbsupvmnsh}
!>        @item{jpressh_m_n_r_,  Normalized JP   component sine parity.,   quantities::jpmnsh}
!>     @table_subsection{siesta_restart_grid_arrays_sec, Grid arrays}
!>        @item{rmnc_m_n_r_, R cosine parity., vmec_info::rmnc_i}
!>        @item{zmns_m_n_r_, Z sine parity.,   vmec_info::zmns_i}
!>     @table_subsection{siesta_restart_grid_arrays_asym_sec, Gird arrays asym.}
!>        @item{rmns_m_n_r_, R sine parity.,   vmec_info::rmns_i}
!>        @item{zmnc_m_n_r_, Z cosine parity., vmec_info::zmnc_i}
!>     @table_subsection{siesta_restart_vmec_arrays_sec, VMEC arrays.}
!>        @item{lmns_m_n_r_, Lambda sine parity.,   vmec_info::lmns_i}
!>     @table_subsection{siesta_restart_vmec_arrays_asym_sec, VMEC arrays asym.}
!>        @item{lmnc_m_n_r_, Lambda cosine parity., vmec_info::lmnc_i}
!>     @table_subsection{siesta_restart_jac_arrays_sec, Jacobian arrays.}
!>        @item{jmnc_m_n_r_, Lambda cosine parity., quantities::lmns_i}
!>     @table_subsection{siesta_restart_jac_arrays_asym_sec, Jacobian arrays asym.}
!>        @item{jmns_m_n_r_, Lambda sine parity.,   quantities::lmnc_i}
!>     @table_subsection{siesta_restart_mag_arrays_sec, Magnetic fields.}
!>        @item{bsubsmnsh_m_n_r_, B_s component sine parity.,   }
!>        @item{bsubumnch_m_n_r_, B_u component cosine parity., }
!>        @item{bsubvmnch_m_n_r_, B_v component cosine parity., }
!>        @item{bsupsmnsh_m_n_r_, B^s component sine parity.,   }
!>        @item{bsupumnch_m_n_r_, B^u component cosine parity., }
!>        @item{bsupvmnch_m_n_r_, B^v component cosine parity., }
!>     @table_subsection{siesta_restart_mag_arrays_asym_sec, Magnetic fields asymmetric.}
!>        @item{bsubsmnch_m_n_r_, B_s component cosine parity., }
!>        @item{bsubumnsh_m_n_r_, B_u component sine parity.,   }
!>        @item{bsubvmnsh_m_n_r_, B_v component sine parity.,   }
!>        @item{bsupsmnch_m_n_r_, B^s component cosine parity., }
!>        @item{bsupumnsh_m_n_r_, B^u component sine parity.,   }
!>        @item{bsupvmnsh_m_n_r_, B^v component sine parity.,   }
!>     @table_subsection{siesta_restart_pres_arrays_sec, Pressure.}
!>        @item{pmnch_m_n_r_, Pressure cosine parity., }
!>     @table_subsection{siesta_restart_pres_arrays_asym_sec, Pressure fields asymmetric.}
!>        @item{pmnsh_m_n_r_, Pressure sine parity., }
!>     @table_subsection{siesta_restart_force_arrays_sec, Forces.}
!>        @item{fsubsmnsh_m_n_r_, F_s component sine parity.,   quantities::fsubsmnsf}
!>        @item{fsubumnch_m_n_r_, F_u component cosine parity., quantities::fsubumncf}
!>        @item{fsubvmnch_m_n_r_, F_v component cosine parity., quantities::fsubvmncf}
!>        @item{fsupsmnsh_m_n_r_, F^s component sine parity.,   quantities::fsupsmncf}
!>        @item{fsupumnch_m_n_r_, F^u component cosine parity., quantities::fsupumnsf}
!>        @item{fsupvmnch_m_n_r_, F^v component cosine parity., quantities::fsupvmnsf}
!>     @table_subsection{siesta_restart_force_arrays_asym_sec, Forces asymmetric.}
!>        @item{fsubsmnsh_m_n_r_, F_s component sine parity.,   quantities::fsubsmnsf}
!>        @item{fsubumnch_m_n_r_, F_u component cosine parity., quantities::fsubumncf}
!>        @item{fsubvmnch_m_n_r_, F_v component cosine parity., quantities::fsubvmncf}
!>        @item{fsupsmnch_m_n_r_, F^s component cosine parity., quantities::fsupsmncf}
!>        @item{bsupumnsh_m_n_r_, F^u component sine parity.,   quantities::fsupumnsf}
!>        @item{bsupvmnsh_m_n_r_, F^v component sine parity.,   quantities::fsupvmnsf}
!>     @table_subsection{siesta_restart_freeboundary_arrays_sec, Vector potential arrays}
!>        @item{asubsmnsf_m_n_r_, A_s component sine parity.,   shared_data::asubsmnsf}
!>        @item{asubumncf_m_n_r_, A_u component cosine parity., shared_data::asubumncf}
!>        @item{asubvmncf_m_n_r_, A_v component cosine parity., shared_data::asubvmncf}
!>     @table_subsection{siesta_restart_freeboundary_arrays_asym_sec, Vector potential asymmetric arrays}
!>        @item{asubsmncf_m_n_r_, A_s component cosine parity., shared_data::asubsmncf}
!>        @item{asubumnsf_m_n_r_, A_u component sine parity.,   shared_data::asubumnsf}
!>        @item{asubvmnsf_m_n_r_, A_v component sine parity.,   shared_data::asubvmnsf}
!>  @end_table
!>
!>  @section siesta_restart_prog_ref_sec Programmers Reference
!>  Reference material for the coding to implement this restart file is found in
!>  the @ref restart_mod module.
!-------------------------------------------------------------------------------
!*******************************************************************************
!>  @file restart_mod.f90
!>  @brief Contains module @ref restart_mod.
!
!  Note separating the Doxygen comment block here so detailed decription is
!  found in the Module not the file.
!
!>  Contains routines for writting the restart file.
!*******************************************************************************
      MODULE restart_mod
      USE ezcdf
      USE netcdf, ONLY: nf90_noerr, nf90_enotvar, nf90_fill_int,             &
                        nf90_fill_double, nf90_max_var_dims,                &
                        nf90_inq_varid, nf90_inquire_variable,              &
                        nf90_inquire_dimension, nf90_get_var, nf90_strerror
      USE stel_kinds
      USE metrics, ONLY: tolowerh
      USE descriptor_mod, ONLY: iam
      USE shared_data, ONLY: lasym, unit_out, wtotal0, wtotal, fsq_total1
      USE v3_utilities, ONLY: assert, assert_eq
      USE stel_constants, ONLY: mu0

      IMPLICIT NONE

      PRIVATE :: require_restart_shape, restart_shape_matches, check_restart_io
      PRIVATE :: read_restart_integer, read_restart_real, read_restart_string

!*******************************************************************************
!  restart module parameters
!*******************************************************************************
!>  Version number.
      INTEGER, PARAMETER           :: restart_version = 0

!  Flag will be placed in the last bits. This way the version number and flags 
!  can fit in the same memory.
!>  Bit position for the lasym flag.
      INTEGER, PARAMETER           :: restart_lasym = 31

!>  Radial Dimension names.
      CHARACTER (LEN=*), DIMENSION(1), PARAMETER ::                            &
     &   radial_dim = (/ 'radius' /)
!>  Toroidal mode dimension.
      CHARACTER (len=*), DIMENSION(1), PARAMETER ::                            &
     &   ntor_dim = (/ 'n-mode' /)
!>  Found mode dimension.
      CHARACTER (len=*), DIMENSION(2), PARAMETER ::                            &
     &   found_dim = (/ 'm-mode', ntor_dim(1) /)
!>  Fourier Dimension names.
      CHARACTER (LEN=*), DIMENSION(3), PARAMETER ::                            &
     &   restart_dims = (/ found_dim(1), found_dim(2), radial_dim(1) /)

!>  Name for the restart file number of radial points.
      CHARACTER (len=*), PARAMETER :: vn_nsin = 'nrad'
      CHARACTER (len=*), PARAMETER :: vn_plasma_nrad = 'plasma_nrad'
!>  Name for the restart file number of poloidal modes.
      CHARACTER (len=*), PARAMETER :: vn_mpolin = 'mpol'
!>  Name for the restart file number of toroidal modes.
      CHARACTER (len=*), PARAMETER :: vn_ntorin = 'ntor'
!>  Name for the restart file number of field periods.
      CHARACTER (len=*), PARAMETER :: vn_nfpin = 'nfp'
!>  Name for the restart file number of wout file modes.
      CHARACTER (len=*), PARAMETER :: vn_wout = 'wout_file'
!>  Name for the restart file number of state flags modes.
      CHARACTER (len=*), PARAMETER :: vn_flags = 'state_flags'
!>  Name for the restart file toroidal modes array.
      CHARACTER (len=*), PARAMETER :: vn_tor_modes = 'tor_modes'
!>  Name for the restart file found modes array.
      CHARACTER (len=*), PARAMETER :: vn_found_modes = 'found_modes'

!>  Name for the restart file jbsupss.
      CHARACTER (len=*), PARAMETER :: vn_jbsupss = 'JBsupssh_m_n_r_'
!>  Name for the restart file jbsupuc.
      CHARACTER (len=*), PARAMETER :: vn_jbsupuc = 'JBsupuch_m_n_r_'
!>  Name for the restart file jbsupvc.
      CHARACTER (len=*), PARAMETER :: vn_jbsupvc = 'JBsupvch_m_n_r_'
!>  Name for the restart file jbsupsc.
      CHARACTER (len=*), PARAMETER :: vn_jbsupsc = 'JBsupsch_m_n_r_'
!>  Name for the restart file jbsupus.
      CHARACTER (len=*), PARAMETER :: vn_jbsupus = 'JBsupush_m_n_r_'
!>  Name for the restart file jbsupus.
      CHARACTER (len=*), PARAMETER :: vn_jbsupvs = 'JBsupvsh_m_n_r_'
!>  Name for the restart file jpresc.
      CHARACTER (len=*), PARAMETER :: vn_jpresc = 'jpresch_m_n_r_'
!>  Name for the restart file jpress.
      CHARACTER (len=*), PARAMETER :: vn_jpress = 'jpressh_m_n_r_'

!>  Name for the restart file rmnc.
      CHARACTER (len=*), PARAMETER :: vn_rmnc = 'rmnc_m_n_r_'
!>  Name for the restart file rmns.
      CHARACTER (len=*), PARAMETER :: vn_rmns = 'rmns_m_n_r_'
!>  Name for the restart file zmnc.
      CHARACTER (len=*), PARAMETER :: vn_zmnc = 'zmnc_m_n_r_'
!>  Name for the restart file zmns.
      CHARACTER (len=*), PARAMETER :: vn_zmns = 'zmns_m_n_r_'

!>  Name for the restart file chipf.
      CHARACTER (len=*), PARAMETER :: vn_chipf = 'chipf_r_'
!>  Name for the restart file phipf.
      CHARACTER (len=*), PARAMETER :: vn_phipf = 'phipf_r_'
!>  Name for the restart file chif.
      CHARACTER (len=*), PARAMETER :: vn_chif = 'chif_r_'
!>  Name for the restart file phif.
      CHARACTER (len=*), PARAMETER :: vn_phif = 'phif_r_'

!>  Name for the restart file bsupsmns.
      CHARACTER (len=*), PARAMETER :: vn_bsupsmns = 'bsupsmnsh_m_n_r_'
!>  Name for the restart file bsupsmnc.
      CHARACTER (len=*), PARAMETER :: vn_bsupsmnc = 'bsupsmnch_m_n_r_'
!>  Name for the restart file bsupumns.
      CHARACTER (len=*), PARAMETER :: vn_bsupumns = 'bsupumnsh_m_n_r_'
!>  Name for the restart file bsupumnc.
      CHARACTER (len=*), PARAMETER :: vn_bsupumnc = 'bsupumnch_m_n_r_'
!>  Name for the restart file bsupvmns.
      CHARACTER (len=*), PARAMETER :: vn_bsupvmns = 'bsupvmnsh_m_n_r_'
!>  Name for the restart file bsupvmnc.
      CHARACTER (len=*), PARAMETER :: vn_bsupvmnc = 'bsupvmnch_m_n_r_'
!>  Name for the restart file bsubsmns.
      CHARACTER (len=*), PARAMETER :: vn_bsubsmns = 'bsubsmnsh_m_n_r_'
!>  Name for the restart file bsubsmnc.
      CHARACTER (len=*), PARAMETER :: vn_bsubsmnc = 'bsubsmnch_m_n_r_'
!>  Name for the restart file bsubumns.
      CHARACTER (len=*), PARAMETER :: vn_bsubumns = 'bsubumnsh_m_n_r_'
!>  Name for the restart file bsubumnc.
      CHARACTER (len=*), PARAMETER :: vn_bsubumnc = 'bsubumnch_m_n_r_'
!>  Name for the restart file bsubvmns.
      CHARACTER (len=*), PARAMETER :: vn_bsubvmns = 'bsubvmnsh_m_n_r_'
!>  Name for the restart file bsubvmnc.
      CHARACTER (len=*), PARAMETER :: vn_bsubvmnc = 'bsubvmnch_m_n_r_'
!>  Name for the restart file pmns.
      CHARACTER (len=*), PARAMETER :: vn_pmns = 'pmnsh_m_n_r_'
!>  Name for the restart file pmnc.
      CHARACTER (len=*), PARAMETER :: vn_pmnc = 'pmnch_m_n_r_'
!>  Name for the restart file jksupsmns.
      CHARACTER (len=*), PARAMETER :: vn_jksupsmns = 'jksupsmnsf_m_n_r_'
!>  Name for the restart file jksupsmnc.
      CHARACTER (len=*), PARAMETER :: vn_jksupsmnc = 'jksupsmncf_m_n_r_'
!>  Name for the restart file jksupumns.
      CHARACTER (len=*), PARAMETER :: vn_jksupumns = 'jksupumnsf_m_n_r_'
!>  Name for the restart file jksupumnc.
      CHARACTER (len=*), PARAMETER :: vn_jksupumnc = 'jksupumncf_m_n_r_'
!>  Name for the restart file jksupvmns.
      CHARACTER (len=*), PARAMETER :: vn_jksupvmns = 'jksupvmnsf_m_n_r_'
!>  Name for the restart file jksupvmnc.
      CHARACTER (len=*), PARAMETER :: vn_jksupvmnc = 'jksupvmncf_m_n_r_'
!>  Name for the restart file fsupsmns.
      CHARACTER (len=*), PARAMETER :: vn_fsupsmns = 'fsupsmnsf_m_n_r_'
!>  Name for the restart file fsupsmnc.
      CHARACTER (len=*), PARAMETER :: vn_fsupsmnc = 'fsupsmncf_m_n_r_'
!>  Name for the restart file fsupumns.
      CHARACTER (len=*), PARAMETER :: vn_fsupumns = 'fsupumnsf_m_n_r_'
!>  Name for the restart file fsupumnc.
      CHARACTER (len=*), PARAMETER :: vn_fsupumnc = 'fsupumncf_m_n_r_'
!>  Name for the restart file fsupvmns.
      CHARACTER (len=*), PARAMETER :: vn_fsupvmns = 'fsupvmnsf_m_n_r_'
!>  Name for the restart file fsupvmnc.
      CHARACTER (len=*), PARAMETER :: vn_fsupvmnc = 'fsupvmncf_m_n_r_'
!>  Name for the restart file fsubsmns.
      CHARACTER (len=*), PARAMETER :: vn_fsubsmns = 'fsubsmnsf_m_n_r_'
!>  Name for the restart file fsubsmnc.
      CHARACTER (len=*), PARAMETER :: vn_fsubsmnc = 'fsubsmncf_m_n_r_'
!>  Name for the restart file fsubumns.
      CHARACTER (len=*), PARAMETER :: vn_fsubumns = 'fsubumnsf_m_n_r_'
!>  Name for the restart file fsubumnc.
      CHARACTER (len=*), PARAMETER :: vn_fsubumnc = 'fsubumncf_m_n_r_'
!>  Name for the restart file fsubvmns.
      CHARACTER (len=*), PARAMETER :: vn_fsubvmns = 'fsubvmnsf_m_n_r_'
!>  Name for the restart file fsubvmnc.
      CHARACTER (len=*), PARAMETER :: vn_fsubvmnc = 'fsubvmncf_m_n_r_'
!>  Name for the restart file asubsmns.
      CHARACTER (len=*), PARAMETER :: vn_asubsmns = 'asubsmnsf_m_n_r_'
!>  Name for the restart file asubumnc.
      CHARACTER (len=*), PARAMETER :: vn_asubumnc = 'asubumncf_m_n_r_'
!>  Name for the restart file asubumnc.
      CHARACTER (len=*), PARAMETER :: vn_asubvmnc = 'asubvmncf_m_n_r_'
!>  Name for the restart file fsubumns.
      CHARACTER (len=*), PARAMETER :: vn_asubsmnc = 'asubsmncf_m_n_r_'
!>  Name for the restart file fsubumnc.
      CHARACTER (len=*), PARAMETER :: vn_asubumns = 'asubumnsf_m_n_r_'
!>  Name for the restart file fsubvmns.
      CHARACTER (len=*), PARAMETER :: vn_asubvmns = 'asubvmnsf_m_n_r_'

!>  Name for the restart file lmns.
      CHARACTER (len=*), PARAMETER :: vn_lmns = 'lmns_m_n_r_'
!>  Name for the restart file lmnc.
      CHARACTER (len=*), PARAMETER :: vn_lmnc = 'lmnc_m_n_r_'

!>  Name for the restart file jmnc.
      CHARACTER (len=*), PARAMETER :: vn_jmnc = 'jmnc_m_n_r_'
!>  Name for the restart file jmns.
      CHARACTER (len=*), PARAMETER :: vn_jmns = 'jmns_m_n_r_'

!>  Name for the restart file p_factor.
      CHARACTER (len=*), PARAMETER :: vn_p_factor = 'p_factor'
!>  Name for the restart file b_factor.
      CHARACTER (len=*), PARAMETER :: vn_b_factor = 'b_factor'
!>  Name for the restart file inital wb.
      CHARACTER (len=*), PARAMETER :: vn_wb0 = 'wb0'
!>  Name for the restart file inital wp.
      CHARACTER (len=*), PARAMETER :: vn_wp0 = 'wp0'
!>  Name for the restart file stored wb.
      CHARACTER (len=*), PARAMETER :: vn_wb = 'wb'
!>  Name for the restart file stored wp.
      CHARACTER (len=*), PARAMETER :: vn_wp = 'wp'
!>  Name for the restart file rmajor.
      CHARACTER (len=*), PARAMETER :: vn_rmajor = 'rmajor'
!>  Name for the restart file total toroidal current.
      CHARACTER (len=*), PARAMETER :: vn_curtor = 'curtor'
!>  Name for the restart file volume averaged force residule fsub.fsup.
      CHARACTER (len=*), PARAMETER :: vn_fsq = 'fsq'

!>  Name for the restart file p_max.
      CHARACTER (len=*), PARAMETER :: vn_p_max = 'p_max'
!>  Name for the restart file p_min.
      CHARACTER (len=*), PARAMETER :: vn_p_min = 'p_min'

!>  Inital stored energy.
      CHARACTER (len=*), PARAMETER :: vn_wtotal0 = 'wtotal0'
!>  Stored energy.
      CHARACTER (len=*), PARAMETER :: vn_wtotal = 'wtotal'

      CONTAINS

      SUBROUTINE check_restart_io(status, name)
      INTEGER, INTENT(in) :: status
      CHARACTER (LEN=*), INTENT(in) :: name

      IF (status .ne. nf90_noerr) THEN
         CALL assert(.false., 'Cannot read restart field ' // name //      &
                              ': ' // TRIM(nf90_strerror(status)))
      END IF
      END SUBROUTINE check_restart_io

      LOGICAL FUNCTION restart_shape_matches(ncid, varid, dims) RESULT(matches)
      INTEGER, INTENT(in) :: ncid, varid, dims(:)
      INTEGER :: rank, dimids(nf90_max_var_dims), i, dim_len

      matches = .false.
      IF (nf90_inquire_variable(ncid, varid, ndims=rank, dimids=dimids)       &
          .ne. nf90_noerr) RETURN
      IF (rank .ne. SIZE(dims)) RETURN
      DO i = 1, rank
         IF (nf90_inquire_dimension(ncid, dimids(i), len=dim_len)            &
             .ne. nf90_noerr) RETURN
         IF (dim_len .ne. dims(i)) RETURN
      END DO
      matches = .true.
      END FUNCTION restart_shape_matches

      INTEGER FUNCTION require_restart_shape(ncid, name, dims) RESULT(varid)
      INTEGER, INTENT(in) :: ncid, dims(:)
      CHARACTER (LEN=*), INTENT(in) :: name
      LOGICAL :: matches

      CALL check_restart_io(nf90_inq_varid(ncid, name, varid), name)
      matches = restart_shape_matches(ncid, varid, dims)
      IF (SIZE(dims) .eq. 0 .and. .not.matches) THEN
!  Accept a one-element vector as a legacy representation of a scalar.
         matches = restart_shape_matches(ncid, varid, [1])
      END IF
      CALL assert(matches, 'Invalid shape for restart field ' // name)
      END FUNCTION require_restart_shape

      INTEGER FUNCTION read_restart_integer(ncid, name) RESULT(value)
      INTEGER, INTENT(in) :: ncid
      CHARACTER (LEN=*), INTENT(in) :: name
      INTEGER :: varid

      varid = require_restart_shape(ncid, name, [INTEGER ::])
      CALL check_restart_io(nf90_get_var(ncid, varid, value), name)
      CALL assert(value .ne. nf90_fill_int, 'Unwritten restart field ' // name)
      END FUNCTION read_restart_integer

      REAL(dp) FUNCTION read_restart_real(ncid, name) RESULT(value)
      USE, INTRINSIC :: ieee_arithmetic, ONLY: ieee_is_finite
      INTEGER, INTENT(in) :: ncid
      CHARACTER (LEN=*), INTENT(in) :: name
      INTEGER :: varid

      varid = require_restart_shape(ncid, name, [INTEGER ::])
      CALL check_restart_io(nf90_get_var(ncid, varid, value), name)
      CALL assert(ieee_is_finite(value) .and. value .ne. nf90_fill_double,    &
                  'Invalid value in restart field ' // name)
      END FUNCTION read_restart_real

      SUBROUTINE read_restart_string(ncid, name, value)
      INTEGER, INTENT(in) :: ncid
      CHARACTER (LEN=*), INTENT(in) :: name
      CHARACTER (LEN=*), INTENT(out) :: value
      CHARACTER (LEN=:), ALLOCATABLE :: stored
      INTEGER :: varid, rank, dimids(nf90_max_var_dims), dim_len

      CALL check_restart_io(nf90_inq_varid(ncid, name, varid), name)
      CALL check_restart_io(nf90_inquire_variable(ncid, varid, ndims=rank,    &
                            dimids=dimids), name)
      CALL assert(rank .eq. 1, 'Invalid shape for restart field ' // name)
      CALL check_restart_io(nf90_inquire_dimension(ncid, dimids(1), len=dim_len), name)
      ALLOCATE(CHARACTER (LEN=dim_len) :: stored)
      CALL check_restart_io(nf90_get_var(ncid, varid, stored), name)
      CALL assert(LEN_TRIM(stored) .le. LEN(value),                 &
                  'Restart field too long: ' // name)
      value = stored
      END SUBROUTINE read_restart_string

!*******************************************************************************
!  UTILITY SUBROUTINES
!*******************************************************************************
!-------------------------------------------------------------------------------
!>  @brief Reads the restart file.
!>
!>  Reads the restart information and initalizes SIESTA quantities.
!>
!>  @param[in]    restart_ext Restart extention.
!>  @param[inout] wout_file   Name of the wout file.
!>  @param[in]    mpolin      Namelist number of polodal modes.
!>  @param[in]    ntorin      Namelist number of toroidal modes.
!>  @param[in]    nfpin       Namelist number of field periods.
!>  @param[in]    nsin        Namelist number of radial grid points.
!>  @param[in]    tor_modesin Namelist torodial modes.
!>  @returns Preconditioner control flag.
!-------------------------------------------------------------------------------
      INTEGER FUNCTION restart_free_grid_size(restart_ext, plasma_ns) RESULT(total_ns)
      CHARACTER (LEN=*), INTENT(in) :: restart_ext
      INTEGER, INTENT(in) :: plasma_ns
      INTEGER :: ncid, status, stored_plasma_ns, varid

      CALL cdf_open(ncid, 'siesta_' // TRIM(restart_ext) // '.nc', 'r', status)
      CALL assert_eq(0, status, 'Failed to open free-boundary restart file')
      total_ns = read_restart_integer(ncid, vn_nsin)
      CALL assert(total_ns .gt. plasma_ns, 'Free-boundary restart must include exterior surfaces')

!  Legacy files store only nrad. For those files NSIN supplies the plasma size.
      status = nf90_inq_varid(ncid, vn_plasma_nrad, varid)
      IF (status .ne. nf90_enotvar) THEN
         CALL check_restart_io(status, vn_plasma_nrad)
         stored_plasma_ns = read_restart_integer(ncid, vn_plasma_nrad)
         CALL assert_eq(stored_plasma_ns, plasma_ns, 'Free-boundary restart requires the saved NSIN')
      END IF
      CALL cdf_close(ncid)
      END FUNCTION restart_free_grid_size

!  Older free-boundary checkpoints can contain NetCDF fill values where
!  the flux profiles were shorter than the extended field arrays.
      SUBROUTINE restart_restore_free_fluxes
      USE, INTRINSIC :: ieee_arithmetic, ONLY: ieee_is_finite
      USE netcdf, ONLY: nf90_fill_double
      USE quantities, ONLY: jbsupumnch, jbsupvmnch, b_factor, signjac
      USE island_params, ONLY: phif_i, chif_i, hs_i, ns_i, fourier_context
      USE stel_constants, ONLY: twopi
      INTEGER :: js
      REAL(dp) :: scale

      IF (ANY(phif_i .eq. nf90_fill_double) .or. ANY(chif_i .eq. nf90_fill_double)) THEN
         CALL assert(ieee_is_finite(b_factor) .and. b_factor .gt. 0,         &
                     'Invalid magnetic normalization in free-boundary restart')
         scale = twopi*hs_i*fourier_context%orthonorm(0,0)/b_factor
         phif_i(1) = 0
         chif_i(1) = 0
         DO js = 2, ns_i
            phif_i(js) = phif_i(js-1) + signjac*scale*jbsupvmnch(0,0,js)
            chif_i(js) = chif_i(js-1) + scale*jbsupumnch(0,0,js)
         END DO
         IF (iam .eq. 0) WRITE(*,*) 'Recovered legacy free-boundary flux profiles from J B'
      END IF
      CALL assert(ALL(ieee_is_finite(phif_i)) .and. ALL(ieee_is_finite(chif_i)), &
                  'Nonfinite flux profiles in free-boundary restart')
      END SUBROUTINE restart_restore_free_fluxes

      FUNCTION restart_read(restart_ext, wout_file, mpolin, ntorin, nfpin,     &
                            nsin, tor_modesin, output_ext)
      USE, INTRINSIC :: ieee_arithmetic, ONLY: ieee_is_finite
      USE quantities, ONLY: jbsupsmnsh, jbsupsmnch,                            &
                            jbsupumnsh, jbsupumnch,                            &
                            jbsupvmnsh, jbsupvmnch,                            &
                            jpmnsh,     jpmnch,                                &
                            b_factor, p_factor, alloc_quantities,              &
                            dealloc_quantities
      USE island_params, ONLY: chipf => chipf_i, phipf => phipf_i,             &
     &                         chif => chif_i, phif => phif_i,                 &
     &                         wb0 => wb_i, wp0 => wp_i, nfp_i, gamma,         &
     &                         gnorm => gnorm_i, rmajor => rmajor_i,           &
     &                         fourier_context, nu_i, nv_i
      USE vmec_info, ONLY: rmnc => rmnc_i, zmns => zmns_i,                     &
     &                     rmns => rmns_i, zmnc => zmnc_i,                     &
     &                     lmns => lmns_i, lmnc => lmnc_i,                     &
     &                     vmec_info_construct_island,                         &
     &                     vmec_info_destruct_island
      USE metrics, ONLY: LoadGrid
      USE fourier, ONLY: m0, m1, fourier_class
      USE stel_constants, ONLY: one
      USE siesta_namelist, ONLY: l_vessel, validate_tor_modes

      IMPLICIT NONE

!  Declare Arguments
      INTEGER                                        :: restart_read
      CHARACTER (len=*), INTENT(in)                  :: restart_ext
      CHARACTER (len=*), INTENT(inout)               :: wout_file
      INTEGER, INTENT(in)                            :: mpolin
      INTEGER, INTENT(in)                            :: ntorin
      INTEGER, INTENT(in)                            :: nsin
      INTEGER, INTENT(in)                            :: nfpin
      INTEGER, DIMENSION(-ntorin:ntorin), INTENT(in) :: tor_modesin
      CHARACTER (len=*), OPTIONAL, INTENT(in)        :: output_ext

!  local variables
      INTEGER                                        :: flags
      INTEGER                                        :: ncid
      INTEGER                                        :: ns
      INTEGER                                        :: mpol
      INTEGER                                        :: ntor
      INTEGER                                        :: nfp
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE       :: tempmn_r
      REAL (dp), DIMENSION(:), ALLOCATABLE           :: temp_r
      INTEGER, DIMENSION(:), ALLOCATABLE             :: temp_modes
      INTEGER                                        :: varid
      INTEGER                                        :: status
      INTEGER                                        :: stored_plasma_ns
      LOGICAL                                        :: legacy_flux_fill
      CHARACTER (LEN=:), ALLOCATABLE                 :: filename
      CHARACTER (LEN=16)                             :: checkpoint_role

!  Start of executable code
      restart_read = 1

      filename = 'siesta_' // TRIM(restart_ext) // '.nc'
      CALL cdf_open(ncid, TRIM(filename), 'r', status)
      CALL assert_eq(0, status, 'Failed to read restart file: ' //             &
     &                          TRIM(filename))

!  Retain in-place updates for legacy best checkpoints. A final checkpoint
!  is a distinct product and must not be overwritten by either new output.
      IF (PRESENT(output_ext)) THEN
         CALL assert(TRIM(restart_ext) .ne. TRIM(output_ext)//'_final',       &
                     'RESTART_INPUT_EXT collides with the new final output. Set a distinct RESTART_EXT.')
         IF (restart_ext .eq. output_ext) THEN
            status = nf90_inq_varid(ncid, 'checkpoint_role', varid)
            IF (status .ne. nf90_enotvar) THEN
               CALL check_restart_io(status, 'checkpoint_role')
               CALL read_restart_string(ncid, 'checkpoint_role', checkpoint_role)
               CALL assert(checkpoint_role .ne. 'final',                     &
                           'Restarting from final output requires RESTART_INPUT_EXT and a distinct RESTART_EXT.')
            END IF
         END IF
      END IF

      flags = read_restart_integer(ncid, vn_flags)

!  The namelist inut file can change the size of the radial grid and the 
!  poloidal and toroidal modes.
      ns = read_restart_integer(ncid, vn_nsin)
      mpol = read_restart_integer(ncid, vn_mpolin)
      ntor = read_restart_integer(ncid, vn_ntorin)
      nfp = read_restart_integer(ncid, vn_nfpin)

      CALL assert(ns .ge. 3, 'Restart nrad must be at least 3.')
      CALL assert(mpol .ge. 1 .and. mpol .lt. HUGE(mpol), 'Invalid restart mpol.')
      CALL assert(ntor .ge. 0 .and. ntor .le. 50, 'Restart ntor must be between 0 and 50.')
      CALL assert(nfp .gt. 0, 'Restart nfp must be positive.')

!  The radial coordinate is normalized to the plasma grid, not the wall.
!  A modern free-boundary checkpoint must not silently be interpreted as a
!  fixed-boundary mesh (or vice versa). Legacy files lack this metadata and
!  retain the caller-supplied boundary convention.
      status = nf90_inq_varid(ncid, vn_plasma_nrad, varid)
      IF (status .ne. nf90_enotvar) THEN
         CALL check_restart_io(status, vn_plasma_nrad)
         stored_plasma_ns = read_restart_integer(ncid, vn_plasma_nrad)
         CALL assert(stored_plasma_ns .ge. 3 .and. stored_plasma_ns .le. ns, &
                     'Invalid plasma_nrad in restart file')
         CALL assert(l_vessel .eqv. (stored_plasma_ns .lt. ns),             &
                     'L_VESSEL does not match restart boundary metadata')
      END IF
      wtotal0 = read_restart_real(ncid, vn_wtotal0)
      wb0 = read_restart_real(ncid, vn_wb0)
      wp0 = read_restart_real(ncid, vn_wp0)
      p_factor = read_restart_real(ncid, vn_p_factor)
      b_factor = read_restart_real(ncid, vn_b_factor)
      rmajor = read_restart_real(ncid, vn_rmajor)
      CALL assert(p_factor .gt. 0 .and. b_factor .gt. 0,                   &
                  'Restart normalization factors must be positive.')

      ALLOCATE(temp_modes(-ntor:ntor))
      varid = require_restart_shape(ncid, vn_tor_modes, [2*ntor+1])
      CALL check_restart_io(nf90_get_var(ncid, varid, temp_modes), vn_tor_modes)
      CALL validate_tor_modes(ntor, temp_modes)
      CALL read_restart_string(ncid, vn_wout, wout_file)

!  Check the file geometry shape before allocating by its header sizes.
      varid = require_restart_shape(ncid, vn_rmnc, [mpol+1, 2*ntor+1, ns])
      CALL dealloc_quantities
      CALL alloc_quantities

      IF (nfpin .lt. 1) THEN
         nfp_i = nfp
      ELSE
         nfp_i = nfpin
      END IF

      fourier_context => fourier_class(mpolin, ntorin, nu_i, nv_i, nfp_i,      &
     &                                 lasym, tor_modesin)

      legacy_flux_fill = l_vessel .and. ns .eq. nsin

!  The namelist input file may turn the asymmetric terms on and off.
      ALLOCATE(tempmn_r(0:mpol,-ntor:ntor,ns))
      ALLOCATE(temp_r(ns))
      CALL vmec_info_destruct_island
      CALL vmec_info_construct_island(mpolin, ntorin, nsin, lasym)

      IF (.not.ALLOCATED(chipf)) THEN
         ALLOCATE(chipf(nsin))
      END IF
      CALL read_profile(vn_chipf, .false.)
!  Derivatives with respect to rho are odd; the flux profiles are even.
      CALL interpit_1d(temp_r, chipf, ns, nsin, .false., -1)

      IF (.not.ALLOCATED(phipf)) THEN
         ALLOCATE(phipf(nsin))
      END IF
      CALL read_profile(vn_phipf, .false.)
      CALL interpit_1d(temp_r, phipf, ns, nsin, .false., -1)

      IF (.not.ALLOCATED(chif)) THEN
         ALLOCATE(chif(nsin))
      END IF
      CALL read_profile(vn_chif, legacy_flux_fill)
      CALL interpit_1d(temp_r, chif, ns, nsin, .false., 1)

      IF (.not.ALLOCATED(phif)) THEN
         ALLOCATE(phif(nsin))
      END IF
      CALL read_profile(vn_phif, legacy_flux_fill)
      CALL interpit_1d(temp_r, phif, ns, nsin, .false., 1)

      CALL read_spectral(vn_jbsupss)
      jbsupsmnsh(:,:,1) = 0
      CALL interpit(tempmn_r, jbsupsmnsh, ns, nsin, mpol, mpolin,              &
     &              ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,         &
     &              .true., odd_jacobian=.false.)

      CALL read_spectral(vn_jbsupuc)
      jbsupumnch(:,:,1) = 0
      CALL interpit(tempmn_r, jbsupumnch, ns, nsin, mpol, mpolin,              &
     &              ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,         &
     &              .true.)

      CALL read_spectral(vn_jbsupvc)
      jbsupvmnch(:,:,1) = 0
      CALL interpit(tempmn_r, jbsupvmnch, ns, nsin, mpol, mpolin,              &
     &              ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,         &
     &              .true.)

      CALL read_spectral(vn_jpresc)
      jpmnch(:,:,1) = 0
      CALL interpit(tempmn_r, jpmnch,     ns, nsin, mpol, mpolin,              &
     &              ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,         &
     &              .true.)

      CALL read_spectral(vn_rmnc)
      CALL interpit(tempmn_r, rmnc, ns, nsin, mpol, mpolin,                    &
     &              ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,         &
     &              .false.)

      CALL read_spectral(vn_zmns)
      CALL interpit(tempmn_r, zmns, ns, nsin, mpol, mpolin,                    &
     &              ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,         &
     &              .false.)

      IF (BTEST(flags, restart_lasym) .and. lasym) THEN
         CALL read_spectral(vn_jbsupsc)
         CALL interpit(tempmn_r, jbsupsmnch, ns, nsin, mpol, mpolin,           &
     &                 ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,      &
     &                 .true., odd_jacobian=.false.)

         CALL read_spectral(vn_jbsupus)
         CALL interpit(tempmn_r, jbsupumnsh, ns, nsin, mpol, mpolin,           &
     &                 ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,      &
     &                 .true.)

         CALL read_spectral(vn_jbsupvs)
         CALL interpit(tempmn_r, jbsupvmnsh, ns, nsin, mpol, mpolin,           &
     &                 ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,      &
     &                 .true.)

         CALL read_spectral(vn_jpress)
         CALL interpit(tempmn_r, jpmnsh,     ns, nsin, mpol, mpolin,           &
     &                 ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,      &
     &                 .true.)

         CALL read_spectral(vn_rmns)
         CALL interpit(tempmn_r, rmns, ns, nsin, mpol, mpolin,                 &
     &                 ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,      &
     &                 .false.)

         CALL read_spectral(vn_zmnc)
         CALL interpit(tempmn_r, zmnc, ns, nsin, mpol, mpolin,                 &
     &                 ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,      &
     &                 .false.)

      ELSE IF (lasym) THEN
         jbsupsmnch = 0
         jbsupumnsh = 0
         jbsupvmnsh = 0
         jpmnsh = 0
         rmns = 0
         zmnc = 0
      END IF

      CALL restore_lambda(vn_lmns, lmns)
      IF (BTEST(flags, restart_lasym) .and. lasym) CALL restore_lambda(vn_lmnc, lmnc)

      CALL cdf_close(ncid)

      CALL restart_normalize(rmnc, one)
      CALL restart_normalize(zmns, one)
      IF (lasym) THEN
         CALL restart_normalize(rmns, one)
         CALL restart_normalize(zmnc, one)
      END IF

      CALL LoadGrid(status)
      CALL assert_eq(0, status, 'Failed to load restart grid')

      DEALLOCATE(tempmn_r)
      DEALLOCATE(temp_r)
      DEALLOCATE(temp_modes)

!  Init quantities.
      gnorm = ABS(wb0)/(wb0 + wp0/(gamma - 1.0))

      WRITE (unit_out, 1000) mpol, ntor, ns

      restart_read = 2

1000  FORMAT(/,' RESTARTED FROM RUN PARAMETERS M: ',i3,' N: ',i3,' NS: ', i3,/)

      CONTAINS

      SUBROUTINE read_profile(name, allow_fill)
      CHARACTER (LEN=*), INTENT(in) :: name
      LOGICAL, INTENT(in) :: allow_fill
      INTEGER :: id

      id = require_restart_shape(ncid, name, [ns])
      CALL check_restart_io(nf90_get_var(ncid, id, temp_r), name)
      CALL assert(ALL(ieee_is_finite(temp_r)), 'Nonfinite restart field ' // name)
      IF (.not.allow_fill) THEN
         CALL assert(ALL(temp_r .ne. nf90_fill_double), 'Unwritten restart field ' // name)
      END IF
      END SUBROUTINE read_profile

      SUBROUTINE read_spectral(name)
      CHARACTER (LEN=*), INTENT(in) :: name
      INTEGER :: id

      id = require_restart_shape(ncid, name, SHAPE(tempmn_r))
      CALL check_restart_io(nf90_get_var(ncid, id, tempmn_r), name)
      CALL assert(ALL(ieee_is_finite(tempmn_r)), 'Nonfinite restart field ' // name)
      CALL assert(ALL(tempmn_r .ne. nf90_fill_double), 'Unwritten restart field ' // name)
      END SUBROUTINE read_spectral

      SUBROUTINE restore_lambda(name, coefficients)
      CHARACTER (LEN=*), INTENT(in) :: name
      REAL(dp), INTENT(inout) :: coefficients(:,:,:)
      INTEGER :: read_status, id

!  Lambda is diagnostic metadata. Older checkpoints may lack the field.
      read_status = nf90_inq_varid(ncid, name, id)
      IF (read_status .eq. nf90_enotvar) RETURN
      CALL check_restart_io(read_status, name)
      IF (.not.restart_shape_matches(ncid, id, SHAPE(tempmn_r))) THEN
         IF (iam .eq. 0) WRITE(*,*) 'Skipping restart metadata with invalid shape: ', name
         RETURN
      END IF
      read_status = nf90_get_var(ncid, id, tempmn_r)
      CALL check_restart_io(read_status, name)
      IF (.not.ALL(ieee_is_finite(tempmn_r))) THEN
         IF (iam .eq. 0) WRITE(*,*) 'Skipping nonfinite restart metadata ', name
         RETURN
      END IF
      WHERE (tempmn_r .eq. nf90_fill_double) tempmn_r = 0
      CALL interpit(tempmn_r, coefficients(:,:,1:nsin), ns, nsin, mpol, mpolin, &
     &              ntor, ntorin, nfp, nfp_i, temp_modes, tor_modesin,        &
     &              .true., odd_jacobian=.false.)
      CALL restart_normalize(coefficients, one)
      END SUBROUTINE restore_lambda

      END FUNCTION

!-------------------------------------------------------------------------------
!>  @brief Write the free boundary information.
!>
!>  The way the restart file is created not it's easier to write this to a
!>  separate restart file.
!>
!>  FIXME: Marge this into the current restart file. This will involve
!>         refactoring the restart so it doesn't overwrite the extire file every
!>         time it updates.
!>
!>
!>  @param[in] restart_ext Restart file extension.
!-------------------------------------------------------------------------------
      SUBROUTINE restart_write_free(restart_ext)
      USE shared_data, ONLY: asubsmnsf, asubumncf, asubvmncf,                  &
                             asubsmncf, asubumnsf, asubvmnsf
      USE island_params, ONLY: mpol=>mpol_i, ntor=>ntor_i, ns=>ns_i,           &
                               nfp => nfp_i, fourier_context
      USE stel_constants, ONLY: one

      IMPLICIT NONE

!  Declare Arguments
      CHARACTER (len=*), INTENT(in)            :: restart_ext

!  Local Variables
      INTEGER                                  :: flags
      INTEGER                                  :: ncid
      INTEGER                                  :: s
      INTEGER                                  :: m
      INTEGER                                  :: n
      INTEGER                                  :: status
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: tempmn_w

!  Start of executable code.
      CALL cdf_open(ncid, 'siesta_' // TRIM(restart_ext) // '_free.nc', 'w', status)
      CALL assert_eq(0, status, 'Failed to write restart file.')

      flags = restart_version

      IF (lasym) THEN
         flags = IBSET(flags, restart_lasym)
      END IF

      ALLOCATE(tempmn_w(0:mpol,-ntor:ntor,ns))

      CALL cdf_define(ncid, vn_flags, flags)
      CALL cdf_define(ncid, vn_nsin, ns)
      CALL cdf_define(ncid, vn_mpolin, mpol)
      CALL cdf_define(ncid, vn_ntorin, ntor)
      CALL cdf_define(ncid, vn_nfpin, nfp)

      CALL cdf_define(ncid, vn_tor_modes, fourier_context%tor_modes,           &
     &                dimname=ntor_dim)

      CALL cdf_define(ncid, vn_asubsmns, tempmn_w, dimname=restart_dims)
      CALL cdf_define(ncid, vn_asubumnc, tempmn_w, dimname=restart_dims)
      CALL cdf_define(ncid, vn_asubvmnc, tempmn_w, dimname=restart_dims)
      IF (lasym) THEN
         CALL cdf_define(ncid, vn_asubsmnc, tempmn_w, dimname=restart_dims)
         CALL cdf_define(ncid, vn_asubumns, tempmn_w, dimname=restart_dims)
         CALL cdf_define(ncid, vn_asubvmns, tempmn_w, dimname=restart_dims)
      END IF

      CALL cdf_write(ncid, vn_flags, flags)
      CALL cdf_write(ncid, vn_nsin, ns)
      CALL cdf_write(ncid, vn_mpolin, mpol)
      CALL cdf_write(ncid, vn_ntorin, ntor)
      CALL cdf_write(ncid, vn_nfpin, nfp)

      CALL cdf_write(ncid, vn_tor_modes, fourier_context%tor_modes)

      tempmn_w = asubsmnsf
      CALL restart_denormalize(tempmn_w, one)
      CALL cdf_write(ncid, vn_asubsmns, tempmn_w)
      tempmn_w = asubumncf
      CALL restart_denormalize(tempmn_w, one)
      CALL cdf_write(ncid, vn_asubumnc, tempmn_w)
      tempmn_w = asubvmncf
      CALL restart_denormalize(tempmn_w, one)
      CALL cdf_write(ncid, vn_asubvmnc, tempmn_w)

      IF (lasym) THEN
         tempmn_w = asubsmncf
         CALL restart_denormalize(tempmn_w, one)
         CALL cdf_write(ncid, vn_asubsmnc, tempmn_w)
         tempmn_w = asubumnsf
         CALL restart_denormalize(tempmn_w, one)
         CALL cdf_write(ncid, vn_asubumns, tempmn_w)
         tempmn_w = asubvmnsf
         CALL restart_denormalize(tempmn_w, one)
         CALL cdf_write(ncid, vn_asubvmns, tempmn_w)
      END IF

      DEALLOCATE(tempmn_w)

      CALL cdf_close(ncid)

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Write the restart file.
!>
!>  Writes the restart information.
!>
!>  @param[in] restart_ext Restart file extension.
!>  @param[in] wout_file   Name of the wout file.
!>  @param[in] iteration  Completed outer iteration in this run.
!>  @param[in] role       Checkpoint role (best_ideal, forced_ideal, or final).
!>  @param[in] reason     Run termination reason, or in_progress.
!>  @param[in] ftol       Target force residual squared.
!-------------------------------------------------------------------------------
      SUBROUTINE restart_write(restart_ext, wout_file, iteration, role, reason, ftol)
      USE quantities, ONLY: jbsupsmnsh, jbsupsmnch,                            &
                            jbsupumnsh, jbsupumnch,                            &
                            jbsupvmnsh, jbsupvmnch,                            &
                            jpmnsh,     jpmnch,                                &
                            fsubsmncf, fsubumnsf, fsubvmnsf,                   &
                            fsubsmnsf, fsubumncf, fsubvmncf,                   &
                            fsupsmncf, fsupumnsf, fsupvmnsf,                   &
                            fsupsmnsf, fsupumncf, fsupvmncf,                   &
                            b_factor,   p_factor, jacobh, wp, wb,              &
                            jmnc, jmns
      USE fourier, ONLY: f_cos, f_sin, f_sum, f_none, n0, m0
      USE island_params, ONLY: nfp => nfp_i, chipf => chipf_i,                 &
                               phipf => phipf_i, wb0 => wb_i, wp0 => wp_i,     &
                               rmajor => rmajor_i, fourier_context,            &
                               mpol=>mpol_i, ntor=>ntor_i, ns=>ns_i,           &
                               ntheta=>nu_i, nzeta=>nv_i, phif=>phif_i,        &
                               chif=>chif_i
      USE utilities, ONLY: curl_htof
      USE stel_constants, ONLY: one
      USE vmec_info, ONLY: rmnc => rmnc_i, zmns => zmns_i,                     &
     &                     rmns => rmns_i, zmnc => zmnc_i,                     &
     &                     lmns => lmns_i, lmnc => lmnc_i
      USE shared_data, ONLY: nsp
      USE siesta_namelist, ONLY: l_vessel

      IMPLICIT NONE

!  Declare Arguments
      CHARACTER (len=*), INTENT(in)            :: restart_ext
      CHARACTER (len=*), INTENT(in)            :: wout_file
      INTEGER, OPTIONAL, INTENT(in)            :: iteration
      CHARACTER (len=*), OPTIONAL, INTENT(in)  :: role, reason
      REAL (dp), OPTIONAL, INTENT(in)          :: ftol

!  Local Variables
      INTEGER                                  :: flags
      INTEGER                                  :: ncid
      INTEGER                                  :: nblock
      INTEGER                                  :: s
      INTEGER                                  :: m
      INTEGER                                  :: n
      INTEGER                                  :: status
      INTEGER                                  :: plasma_ns
      INTEGER                                  :: converged

      REAL (dp)                                :: r0
      REAL (dp)                                :: tempscalar
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsupsijh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsupuijh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsupvijh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsubsijh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsubuijh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsubvijh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsubsmnh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsubumnh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: bsubvmnh
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: jksupsmnf
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: jksupumnf
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: jksupvmnf
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: tempmn_w
      REAL (dp), DIMENSION(:,:,:), ALLOCATABLE :: pijh

!  Start of executable code.
      CALL cdf_open(ncid, 'siesta_' // TRIM(restart_ext) // '.nc', 'w', status)
      CALL assert_eq(0, status, 'Failed to write restart file.')

      flags = restart_version
      IF (lasym) THEN
         flags = IBSET(flags, restart_lasym)
      END IF

      ALLOCATE(tempmn_w(0:mpol,-ntor:ntor,ns))

      CALL cdf_define(ncid, vn_flags, flags)
      CALL cdf_define(ncid, vn_nsin, ns)
      plasma_ns = ns
      IF (l_vessel) plasma_ns = nsp
      CALL cdf_define(ncid, vn_plasma_nrad, plasma_ns)
      CALL cdf_define(ncid, vn_mpolin, mpol)
      CALL cdf_define(ncid, vn_ntorin, ntor)
      CALL cdf_define(ncid, vn_nfpin, nfp)
      CALL cdf_define(ncid, vn_wout, wout_file)

      CALL cdf_define(ncid, vn_wtotal0, wtotal0)
      CALL cdf_define(ncid, vn_wtotal, wtotal)

      CALL cdf_define(ncid, vn_tor_modes, fourier_context%tor_modes,           &
     &                dimname=ntor_dim)
      CALL cdf_define(ncid, vn_found_modes, fourier_context%found_modes,       &
     &                dimname=found_dim)

      CALL cdf_define(ncid, vn_jbsupss, jbsupsmnsh, dimname=restart_dims)
      CALL cdf_define(ncid, vn_jbsupuc, jbsupumnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_jbsupvc, jbsupvmnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_jpresc,  jpmnch,     dimname=restart_dims)

      CALL cdf_define(ncid, vn_rmnc, tempmn_w, dimname=restart_dims)
      CALL cdf_define(ncid, vn_zmns, tempmn_w, dimname=restart_dims)

      CALL cdf_define(ncid, vn_chipf, chipf, dimname=radial_dim)
      CALL cdf_define(ncid, vn_phipf, phipf, dimname=radial_dim)
      CALL cdf_define(ncid, vn_chif, chipf, dimname=radial_dim)
      CALL cdf_define(ncid, vn_phif, phipf, dimname=radial_dim)

      CALL cdf_define(ncid, vn_wb0, wb0)
      CALL cdf_define(ncid, vn_wp0, wp0)
      CALL cdf_define(ncid, vn_wb, wb)
      CALL cdf_define(ncid, vn_wp, wp)
      CALL cdf_define(ncid, vn_fsq, fsq_total1)
      IF (PRESENT(iteration)) CALL cdf_define(ncid, 'iteration', iteration)
      IF (PRESENT(role)) CALL cdf_define(ncid, 'checkpoint_role', role)
      IF (PRESENT(reason)) THEN
         converged = MERGE(1, 0, reason .EQ. 'converged')
         CALL cdf_define(ncid, 'termination_reason', reason)
         CALL cdf_define(ncid, 'converged', converged)
      END IF
      IF (PRESENT(ftol)) CALL cdf_define(ncid, 'ftol', ftol)

!  Using variable with jacobian only for the dimension sizes and types. Before
!  writting, the jacobian normalization will be removed.
      CALL cdf_define(ncid, vn_bsupsmns,  jbsupsmnsh, dimname=restart_dims)
      CALL cdf_define(ncid, vn_bsupumnc,  jbsupumnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_bsupvmnc,  jbsupvmnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_bsubsmns,  jbsupsmnsh, dimname=restart_dims)
      CALL cdf_define(ncid, vn_bsubumnc,  jbsupumnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_bsubvmnc,  jbsupvmnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_jksupsmns, jbsupsmnsh, dimname=restart_dims)
      CALL cdf_define(ncid, vn_jksupumnc, jbsupumnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_jksupvmnc, jbsupvmnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_fsupsmnc,  jbsupsmnsh, dimname=restart_dims)
      CALL cdf_define(ncid, vn_fsupumns,  jbsupumnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_fsupvmns,  jbsupvmnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_fsubsmnc,  jbsupsmnsh, dimname=restart_dims)
      CALL cdf_define(ncid, vn_fsubumns,  jbsupumnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_fsubvmns,  jbsupvmnch, dimname=restart_dims)
      CALL cdf_define(ncid, vn_lmns,      tempmn_w,   dimname=restart_dims)
      CALL cdf_define(ncid, vn_jmnc,      jmnc,       dimname=restart_dims)
      CALL cdf_define(ncid, vn_pmnc,      jpmnch,     dimname=restart_dims)
      CALL cdf_define(ncid, vn_b_factor,  b_factor)
      CALL cdf_define(ncid, vn_p_factor,  p_factor)
      CALL cdf_define(ncid, vn_rmajor,    rmajor)
      CALL cdf_define(ncid, vn_p_max,     b_factor)
      CALL cdf_define(ncid, vn_p_min,     p_factor)
      CALL cdf_define(ncid, vn_curtor,    tempscalar)

      IF (lasym) THEN
         CALL cdf_define(ncid, vn_jbsupsc, jbsupsmnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_jbsupus, jbsupumnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_jbsupvs, jbsupvmnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_jpress,  jpmnsh,     dimname=restart_dims)

         CALL cdf_define(ncid, vn_rmns, tempmn_w, dimname=restart_dims)
         CALL cdf_define(ncid, vn_zmnc, tempmn_w, dimname=restart_dims)

         CALL cdf_define(ncid, vn_bsupsmnc,  jbsupsmnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_bsupumns,  jbsupumnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_bsupvmns,  jbsupvmnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_bsubsmnc,  jbsupsmnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_bsubumns,  jbsupumnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_bsubvmns,  jbsupvmnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_jksupsmnc, jbsupsmnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_jksupumns, jbsupumnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_jksupvmns, jbsupvmnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_fsupsmns,  jbsupsmnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_fsupumnc,  jbsupumnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_fsupvmnc,  jbsupvmnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_fsubsmns,  jbsupsmnsh, dimname=restart_dims)
         CALL cdf_define(ncid, vn_fsubumnc,  jbsupumnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_fsubvmnc,  jbsupvmnch, dimname=restart_dims)
         CALL cdf_define(ncid, vn_lmnc,      tempmn_w,   dimname=restart_dims)
         CALL cdf_define(ncid, vn_jmns,      jmns,       dimname=restart_dims)
         CALL cdf_define(ncid, vn_pmns, jpmnsh, dimname=restart_dims)
      END IF

      CALL cdf_write(ncid, vn_flags, flags)
      CALL cdf_write(ncid, vn_nsin, ns)
      CALL cdf_write(ncid, vn_plasma_nrad, plasma_ns)
      CALL cdf_write(ncid, vn_mpolin, mpol)
      CALL cdf_write(ncid, vn_ntorin, ntor)
      CALL cdf_write(ncid, vn_nfpin, nfp)
      CALL cdf_write(ncid, vn_wout, wout_file)

      CALL cdf_write(ncid, vn_wtotal0, wtotal0)
      CALL cdf_write(ncid, vn_wtotal, wtotal)

      CALL cdf_write(ncid, vn_tor_modes, fourier_context%tor_modes)
      CALL cdf_write(ncid, vn_found_modes, fourier_context%found_modes)

      CALL cdf_write(ncid, vn_jbsupss, jbsupsmnsh)
      CALL cdf_write(ncid, vn_jbsupuc, jbsupumnch)
      CALL cdf_write(ncid, vn_jbsupvc, jbsupvmnch)
      CALL cdf_write(ncid, vn_jpresc,  jpmnch)

      CALL cdf_write(ncid, vn_chipf, chipf)
      CALL cdf_write(ncid, vn_phipf, phipf)
      CALL cdf_write(ncid, vn_chif, chif)
      CALL cdf_write(ncid, vn_phif, phif)

      tempmn_w = rmnc
      CALL restart_denormalize(tempmn_w, one)
      CALL cdf_write(ncid, vn_rmnc, tempmn_w)
      tempmn_w = zmns
      CALL restart_denormalize(tempmn_w, one)
      CALL cdf_write(ncid, vn_zmns, tempmn_w)

      IF (lasym) THEN
         CALL cdf_write(ncid, vn_jbsupsc, jbsupsmnch)
         CALL cdf_write(ncid, vn_jbsupus, jbsupumnsh)
         CALL cdf_write(ncid, vn_jbsupvs, jbsupvmnsh)
         CALL cdf_write(ncid, vn_jpress,  jpmnsh)

         tempmn_w = rmns
         CALL restart_denormalize(tempmn_w, one)
         CALL cdf_write(ncid, vn_rmns, tempmn_w)
         tempmn_w = zmnc
         CALL restart_denormalize(tempmn_w, one)
         CALL cdf_write(ncid, vn_zmnc, tempmn_w)
      END IF

      CALL cdf_write(ncid, vn_wb0, wb0)
      CALL cdf_write(ncid, vn_wp0, wp0)
      CALL cdf_write(ncid, vn_wb, wb)
      CALL cdf_write(ncid, vn_wp, wp)
      CALL cdf_write(ncid, vn_rmajor, rmajor)
      CALL cdf_write(ncid, vn_fsq, fsq_total1)
      IF (PRESENT(iteration)) CALL cdf_write(ncid, 'iteration', iteration)
      IF (PRESENT(role)) CALL cdf_write(ncid, 'checkpoint_role', role)
      IF (PRESENT(reason)) THEN
         CALL cdf_write(ncid, 'termination_reason', reason)
         CALL cdf_write(ncid, 'converged', converged)
      END IF
      IF (PRESENT(ftol)) CALL cdf_write(ncid, 'ftol', ftol)

      CALL cdf_write(ncid, vn_p_factor, p_factor)
      CALL cdf_write(ncid, vn_b_factor, b_factor)

      ALLOCATE(bsupsijh(ntheta,nzeta,ns))
      ALLOCATE(bsupuijh(ntheta,nzeta,ns))
      ALLOCATE(bsupvijh(ntheta,nzeta,ns))
      ALLOCATE(pijh(ntheta,nzeta,ns))

      bsupsijh = 0
      bsupuijh = 0
      bsupvijh = 0
      pijh = 0

      CALL fourier_context%toijsp(jbsupsmnsh, bsupsijh, f_none, f_sin)
      CALL fourier_context%toijsp(jbsupumnch, bsupuijh, f_none, f_cos)
      CALL fourier_context%toijsp(jbsupvmnch, bsupvijh, f_none, f_cos)
      CALL fourier_context%toijsp(jpmnch, pijh, f_none, f_cos)

      IF (lasym) THEN
         CALL fourier_context%toijsp(jbsupsmnch, bsupsijh, f_sum, f_cos)
         CALL fourier_context%toijsp(jbsupumnsh, bsupuijh, f_sum, f_sin)
         CALL fourier_context%toijsp(jbsupvmnsh, bsupvijh, f_sum, f_sin)
         CALL fourier_context%toijsp(jpmnsh, pijh, f_sum, f_sin)
      END IF

      bsupsijh(:,:,1) = 0
      bsupuijh(:,:,1) = 0
      bsupvijh(:,:,1) = 0
      pijh(:,:,1) = 0

!  Remove the jacobian term.
      bsupsijh = bsupsijh/jacobh
      bsupuijh = bsupuijh/jacobh
      bsupvijh = bsupvijh/jacobh
      pijh = pijh/jacobh

      tempscalar = MAXVAL(pijh(:,:,2:))
      CALL cdf_write(ncid, vn_p_max, tempscalar/(p_factor*mu0))
      tempscalar = MINVAL(pijh(:,:,2:))
      CALL cdf_write(ncid, vn_p_min, tempscalar/(p_factor*mu0))

      tempmn_w = 0

!  Remove the orthonorm and b_factor so these quantities can be directly summed.
      CALL fourier_context%tomnsp(bsupsijh, tempmn_w, f_sin)
      CALL restart_denormalize(tempmn_w, b_factor)
      CALL cdf_write(ncid, vn_bsupsmns, tempmn_w)

      CALL fourier_context%tomnsp(bsupuijh, tempmn_w, f_cos)
      CALL restart_denormalize(tempmn_w, b_factor)
      CALL cdf_write(ncid, vn_bsupumnc, tempmn_w)

      CALL fourier_context%tomnsp(bsupvijh, tempmn_w, f_cos)
      CALL restart_denormalize(tempmn_w, b_factor)
      CALL cdf_write(ncid, vn_bsupvmnc, tempmn_w)

      tempmn_w = fsubsmncf
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_fsubsmnc, tempmn_w)

      tempmn_w = fsubumnsf
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_fsubumns, tempmn_w)

      tempmn_w = fsubvmnsf
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_fsubvmns, tempmn_w)

      tempmn_w = fsupsmncf
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_fsupsmnc, tempmn_w)

      tempmn_w = fsupumnsf
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_fsupumns, tempmn_w)

      tempmn_w = fsupvmnsf
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_fsupvmns, tempmn_w)

      tempmn_w = 0
      tempmn_w(:,:,1:MIN(ns,SIZE(lmns,3))) = lmns(:,:,1:MIN(ns,SIZE(lmns,3)))
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_lmns, tempmn_w)

      tempmn_w = jmnc
      CALL restart_denormalize(tempmn_w, 1.0_dp)
      CALL cdf_write(ncid, vn_jmnc, tempmn_w)

!  Remove the orthonorm and p_factor so this quantity can be directly summed.
      CALL fourier_context%tomnsp(pijh, tempmn_w, f_cos)
      CALL restart_denormalize(tempmn_w, p_factor*mu0)
      CALL cdf_write(ncid, vn_pmnc, tempmn_w)

      ALLOCATE(bsubsijh(ntheta,nzeta,ns))
      ALLOCATE(bsubuijh(ntheta,nzeta,ns))
      ALLOCATE(bsubvijh(ntheta,nzeta,ns))

      CALL tolowerh(bsupsijh, bsupuijh, bsupvijh,                              &
                    bsubsijh, bsubuijh, bsubvijh, 1, ns)

!  Need these to compute the currents later.
      ALLOCATE(bsubsmnh(0:mpol,-ntor:ntor,ns))
      ALLOCATE(bsubumnh(0:mpol,-ntor:ntor,ns))
      ALLOCATE(bsubvmnh(0:mpol,-ntor:ntor,ns))

!  Need to compute current before denormalizing quantities.
      CALL fourier_context%tomnsp(bsubsijh, bsubsmnh, f_sin)
      CALL fourier_context%tomnsp(bsubuijh, bsubumnh, f_cos)
      CALL fourier_context%tomnsp(bsubvijh, bsubvmnh, f_cos)

!  Compute currents on the full mesh.
      ALLOCATE(jksupsmnf(0:mpol,-ntor:ntor,ns))
      ALLOCATE(jksupumnf(0:mpol,-ntor:ntor,ns))
      ALLOCATE(jksupvmnf(0:mpol,-ntor:ntor,ns))

      CALL curl_htof(bsubsmnh, bsubumnh, bsubvmnh,                             &
     &               jksupsmnf, jksupumnf, jksupvmnf,                          &
     &               f_sin, 1, ns, ns, tempscalar)

!  Remove the orthonorm and b_factor so these quantities can be directly summed.
      CALL restart_denormalize(bsubsmnh, b_factor)
      CALL restart_denormalize(bsubvmnh, b_factor)
      CALL restart_denormalize(bsubumnh, b_factor)

      CALL cdf_write(ncid, vn_bsubsmns, bsubsmnh)
      CALL cdf_write(ncid, vn_bsubumnc, bsubumnh)
      CALL cdf_write(ncid, vn_bsubvmnc, bsubvmnh)

      CALL restart_denormalize(jksupsmnf, b_factor)
      CALL restart_denormalize(jksupumnf, b_factor)
      CALL restart_denormalize(jksupvmnf, b_factor)

      CALL cdf_write(ncid, vn_jksupsmns, jksupsmnf)
      CALL cdf_write(ncid, vn_jksupumnc, jksupumnf)
      CALL cdf_write(ncid, vn_jksupvmnc, jksupvmnf)

      tempscalar = -fourier_context%orthonorm(m0,n0)*tempscalar/b_factor
      CALL cdf_write(ncid, vn_curtor, tempscalar)

      IF (lasym) THEN
!  Remove the orthonorm and b_factor so these quantities can be directly summed.
         CALL fourier_context%tomnsp(bsupsijh, tempmn_w, f_cos)
         CALL restart_denormalize(tempmn_w, b_factor)
         CALL cdf_write(ncid, vn_bsupsmnc, tempmn_w)

         CALL fourier_context%tomnsp(bsupuijh, tempmn_w, f_sin)
         CALL restart_denormalize(tempmn_w, b_factor)
         CALL cdf_write(ncid, vn_bsupumns, tempmn_w)

         CALL fourier_context%tomnsp(bsupvijh, tempmn_w, f_sin)
         CALL restart_denormalize(tempmn_w, b_factor)
         CALL cdf_write(ncid, vn_bsupvmns, tempmn_w)

         tempmn_w = fsubsmnsf
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_fsubsmns, tempmn_w)

         tempmn_w = fsubumncf
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_fsubumnc, tempmn_w)

         tempmn_w = fsubvmncf
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_fsubvmnc, tempmn_w)

         tempmn_w = fsupsmnsf
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_fsupsmns, tempmn_w)

         tempmn_w = fsupumncf
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_fsupumnc, tempmn_w)

         tempmn_w = fsupvmncf
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_fsupvmnc, tempmn_w)

         tempmn_w = 0
         tempmn_w(:,:,1:MIN(ns,SIZE(lmnc,3))) = lmnc(:,:,1:MIN(ns,SIZE(lmnc,3)))
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_lmnc, tempmn_w)

         tempmn_w = jmns
         CALL restart_denormalize(tempmn_w, 1.0_dp)
         CALL cdf_write(ncid, vn_jmns, tempmn_w)

!  Remove the orthonorm and p_factor so this quantity can be directly summed.
         CALL fourier_context%tomnsp(pijh, tempmn_w, f_sin)
         CALL restart_denormalize(tempmn_w, p_factor*mu0)
         CALL cdf_write(ncid, vn_pmns, tempmn_w)

!  Need to compute current before denormalizing quantities.
         CALL fourier_context%tomnsp(bsubsijh, bsubsmnh, f_cos)
         CALL fourier_context%tomnsp(bsubuijh, bsubumnh, f_sin)
         CALL fourier_context%tomnsp(bsubvijh, bsubvmnh, f_sin)

         CALL curl_htof(bsubsmnh, bsubumnh, bsubvmnh,                          &
     &                  jksupsmnf, jksupumnf, jksupvmnf,                       &
     &                  f_cos, 1, ns, ns, tempscalar)

!  Remove the orthonorm and b_factor so these quantities can be directly summed.
         CALL restart_denormalize(bsubsmnh, b_factor)
         CALL restart_denormalize(bsubumnh, b_factor)
         CALL restart_denormalize(bsubvmnh, b_factor)

         CALL cdf_write(ncid, vn_bsubsmnc, bsubsmnh)
         CALL cdf_write(ncid, vn_bsubumns, bsubumnh)
         CALL cdf_write(ncid, vn_bsubvmns, bsubvmnh)

         CALL restart_denormalize(jksupsmnf, b_factor)
         CALL restart_denormalize(jksupumnf, b_factor)
         CALL restart_denormalize(jksupvmnf, b_factor)

         CALL cdf_write(ncid, vn_jksupsmnc, jksupsmnf)
         CALL cdf_write(ncid, vn_jksupumns, jksupumnf)
         CALL cdf_write(ncid, vn_jksupvmns, jksupvmnf)
      END IF

      DEALLOCATE(bsupsijh)
      DEALLOCATE(bsupuijh)
      DEALLOCATE(bsupvijh)
      DEALLOCATE(pijh)

      DEALLOCATE(bsubsmnh)
      DEALLOCATE(bsubumnh)
      DEALLOCATE(bsubvmnh)

      DEALLOCATE(jksupsmnf)
      DEALLOCATE(jksupumnf)
      DEALLOCATE(jksupvmnf)

      DEALLOCATE(tempmn_w)

      CALL cdf_close(ncid)

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Interpolate fourier quantites from the restart file.
!>
!>  Restart files can change the number of surfaces and modes.
!>
!>  @param[in]  aold          Value from the restart file.
!>  @param[out] anew          New interpolated value.
!>  @param[in]  ns_old        Radial grid size in the restart file.
!>  @param[in]  ns_new        New radial grid size.
!>  @param[in]  mpol_old      Number of poloidal modes in the restart file.
!>  @param[in]  mpol_new      New number of poloidal modes.
!>  @param[in]  ntor_old      Number of totoidal modes in the restart file.
!>  @param[in]  ntor_new      New number of totoidal modes.
!>  @param[in]  nfp_old       Number of field periods in the restart file.
!>  @param[in]  nfp_new       New number of field periods.
!>  @param[in]  tor_modes_old Toroidal modes in the restart file.
!>  @param[in]  tor_modes_new New toroidal modes.
!>  @param[in]  lhalf         Grid type.
!>  @param[in]  odd_jacobian Whether the quantity gains an extra sign on radial reflection.
!-------------------------------------------------------------------------------
      SUBROUTINE interpit(aold,     anew,                                      &
     &                    ns_old,   ns_new,                                    &
     &                    mpol_old, mpol_new,                                  &
     &                    ntor_old, ntor_new,                                  &
     &                    nfp_old,  nfp_new,                                   &
     &                    tor_modes_old, tor_modes_new,                        &
     &                    lhalf, odd_jacobian)
      USE stel_constants, ONLY: one, zero
      IMPLICIT NONE

!  Declare Arguments
      REAL (dp), DIMENSION(:,:,:), INTENT(in)            :: aold
      REAL (dp), DIMENSION(:,:,:), INTENT(out)           :: anew
      INTEGER, INTENT(in)                                :: ns_old
      INTEGER, INTENT(in)                                :: ns_new
      INTEGER, INTENT(in)                                :: mpol_old
      INTEGER, INTENT(in)                                :: mpol_new
      INTEGER, INTENT(in)                                :: ntor_old
      INTEGER, INTENT(in)                                :: ntor_new
      INTEGER, INTENT(in)                                :: nfp_old
      INTEGER, INTENT(in)                                :: nfp_new
      INTEGER, DIMENSION(-ntor_old:ntor_old), INTENT(in) :: tor_modes_old
      INTEGER, DIMENSION(-ntor_new:ntor_new), INTENT(in) :: tor_modes_new
      LOGICAL, INTENT(in)                                :: lhalf
      LOGICAL, OPTIONAL, INTENT(in)                      :: odd_jacobian

!  local variables
      INTEGER                                            :: i_n
      INTEGER                                            :: n
      INTEGER                                            :: i_m
      INTEGER                                            :: parity
      INTEGER                                            :: mpol_min
      INTEGER                                            :: mold_off
      INTEGER                                            :: mnew_off
      INTEGER                                            :: nold_off
      INTEGER                                            :: nnew_off
      LOGICAL                                            :: jacobian_changes_parity

!  Start of executable code
      mold_off = LBOUND(aold,1)
      mnew_off = LBOUND(anew,1)

      nold_off = LBOUND(aold,2) + ntor_old
      nnew_off = LBOUND(anew,2) + ntor_new

      mpol_min = MIN(mpol_new, mpol_old)
      jacobian_changes_parity = lhalf
      IF (PRESENT(odd_jacobian)) THEN
!  Reflecting rho reverses both J and B^rho. For J B^u, J B^v and J p
!  only J changes sign in addition to the Fourier parity.
         jacobian_changes_parity = odd_jacobian
      END IF

!  Compare mode arrays only after establishing that their shapes match.
      IF (ns_old .eq. ns_new .and. mpol_old .eq. mpol_new .and.               &
          ntor_old .eq. ntor_new .and. nfp_old .eq. nfp_new) THEN
         IF (ALL(tor_modes_old .eq. tor_modes_new)) THEN
            anew = aold
            RETURN
         END IF
      END IF

      anew = 0
      DO i_n = -ntor_old, ntor_old
!  The physical toroidal harmonic is the mode number times NFP.
         DO n = -ntor_new, ntor_new
            IF (tor_modes_new(n)*nfp_new .eq. tor_modes_old(i_n)*nfp_old) EXIT
         END DO
         IF (n .gt. ntor_new) CYCLE

         DO i_m = 0, mpol_min
            parity = 1
            IF (MOD(i_m, 2) .ne. 0) parity = -1
            IF (jacobian_changes_parity) parity = -parity
            CALL interpit_1d(aold(i_m + mold_off, i_n + nold_off, :),          &
     &                       anew(i_m + mnew_off, n   + nnew_off, :),          &
     &                       ns_old, ns_new, lhalf, parity)
         END DO
      END DO

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Interpolate radial quantites from the restart file.
!>
!>  Restart files can change the number of surfaces.
!>
!>  @param[in]  aold     Value from the restart file.
!>  @param[out] anew     New interpolated value.
!>  @param[in]  ns_old   Radial grid size in the restart file.
!>  @param[in]  ns_new   New radial grid size.
!-------------------------------------------------------------------------------
      SUBROUTINE interpit_1d(aold, anew, ns_old, ns_new, lhalf, parity)
      USE stel_constants, ONLY: one, zero

      IMPLICIT NONE

!  Declare Arguments
      REAL (dp), DIMENSION(:), INTENT(in)  :: aold
      REAL (dp), DIMENSION(:), INTENT(out) :: anew
      INTEGER, INTENT(in)                  :: ns_old
      INTEGER, INTENT(in)                  :: ns_new
      LOGICAL, INTENT(in)                  :: lhalf
      INTEGER, INTENT(in)                  :: parity

!  local variables
      REAL (dp), ALLOCATABLE, DIMENSION(:) :: temp_y
      REAL (dp), ALLOCATABLE, DIMENSION(:) :: temp_x
      REAL (dp), ALLOCATABLE, DIMENSION(:) :: temp
      REAL (dp)                            :: ds
      REAL (dp)                            :: s_new
      INTEGER                              :: i_s

!  local parameters
      REAL (dp), PARAMETER                 :: lower_b = -1.e30_dp
      REAL (dp), PARAMETER                 :: upper_b = -1.e30_dp

!  Start of executable code
      anew = 0
      IF (ns_old .EQ. ns_new) THEN
         anew = aold
         RETURN
      END IF

!  Need to radially interpolate. Extend the arrays from -ns to ns to get the
!  correct behavior at s=0.
      ds = 1.0_dp/(ns_old - 1)
      IF (lhalf) THEN
         ALLOCATE(temp_y(2*(ns_old - 1)))
         ALLOCATE(temp_x(2*(ns_old - 1)))
         ALLOCATE(temp(2*(ns_old - 1)))

         DO i_s = 2, ns_old
            temp_x(ns_old - i_s + 1) = -ds*(i_s - 1.5)
            temp_x(ns_old + i_s - 2) = ds*(i_s - 1.5_dp)
            temp_y(ns_old - i_s + 1) = parity*aold(i_s)
            temp_y(ns_old + i_s - 2) = aold(i_s)
         END DO
      ELSE
         ALLOCATE(temp_y(2*ns_old - 1))
         ALLOCATE(temp_x(2*ns_old - 1))
         ALLOCATE(temp(2*ns_old - 1))

         DO i_s = 1, ns_old
            temp_x(ns_old - i_s + 1) = -ds*(i_s - 1)
            temp_x(ns_old + i_s - 1) = ds*(i_s - 1)
            temp_y(ns_old - i_s + 1) = parity*aold(i_s)
            temp_y(ns_old + i_s - 1) = aold(i_s)
         END DO
      END IF

      CALL spline(temp_x, temp_y, SIZE(temp_x), lower_b, upper_b, temp)

      ds = 1.0_dp/(ns_new - 1)
      IF (lhalf) THEN
         DO i_s = 2, ns_new
            s_new = ds*(i_s - 1.5_dp)
            CALL splINT(temp_x, temp_y, temp, SIZE(temp_x), s_new, anew(i_s))
         END DO
      ELSE
         DO i_s = 1, ns_new
            s_new = ds*(i_s - 1)
            CALL splINT(temp_x, temp_y, temp, SIZE(temp_x), s_new, anew(i_s))
         END DO
      END IF

      DEALLOCATE(temp_y)
      DEALLOCATE(temp_x)
      DEALLOCATE(temp)

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Denormalize a quantity so the value written to the restart file can
!>         be summed directly.
!>
!>  This removes the orthonorm and energy scale factors for a fourier quantity.
!>
!>  @param[inout] xmn    Fourier quantity to denormalize.
!>  @param[in]    factor Energy scale factor.
!-------------------------------------------------------------------------------
      SUBROUTINE restart_normalize(xmn, factor)
      USE island_params, ONLY: fourier_context

      IMPLICIT NONE

!  Declare Arguments
      REAL (dp), DIMENSION(:,:,:) :: xmn
      REAL (dp)                   :: factor

!  Local Variables
      INTEGER                     :: s

!  Start of executable code.
      DO s = 1, SIZE(xmn,3)
         xmn(:,:,s) = xmn(:,:,s)*factor/fourier_context%orthonorm
      END DO

      END SUBROUTINE

!-------------------------------------------------------------------------------
!>  @brief Denormalize a quantity so the value written to the restart file can
!>         be summed directly.
!>
!>  This removes the orthonorm and energy scale factors for a fourier quantity.
!>
!>  @param[inout] xmn    Fourier quantity to denormalize.
!>  @param[in]    factor Energy scale factor.
!-------------------------------------------------------------------------------
      SUBROUTINE restart_denormalize(xmn, factor)
      USE island_params, ONLY: fourier_context

      IMPLICIT NONE

!  Declare Arguments
      REAL (dp), DIMENSION(:,:,:) :: xmn
      REAL (dp)                   :: factor

!  Local Variables
      INTEGER                     :: s

!  Start of executable code.
      DO s = 1, SIZE(xmn,3)
         xmn(:,:,s) = fourier_context%orthonorm*xmn(:,:,s)/factor
      END DO

      END SUBROUTINE

      END MODULE

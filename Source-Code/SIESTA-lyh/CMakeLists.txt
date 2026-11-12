cmake_minimum_required (VERSION 3.19)

project (siesta C CXX Fortran)

add_library (siesta)
add_dependencies (siesta pull_siesta)

option (SIESTA_ENABLE_OPENMP "Parallelize independent radial Fourier transforms" ON)
if (SIESTA_ENABLE_OPENMP)
    find_package (OpenMP COMPONENTS Fortran)
    if (OpenMP_Fortran_FOUND)
        target_link_libraries (siesta PUBLIC OpenMP::OpenMP_Fortran)
        target_compile_definitions (siesta PUBLIC SIESTA_OPENMP)
    else ()
        message (WARNING "OpenMP Fortran unavailable; SIESTA uses serial Fourier transforms")
    endif ()
endif ()

target_link_libraries (siesta PUBLIC bmw)
target_include_directories (siesta

                            PUBLIC

                            $<TARGET_PROPERTY:siesta,BINARY_DIR>
)

add_executable (xsiesta)

target_link_libraries (xsiesta PUBLIC siesta)

add_subdirectory (Sources)

# Stellarator-Tools can register SIESTA before LIBSTELL. Install the
# compatibility source replacements after all framework targets exist.
cmake_language (DEFER DIRECTORY "${CMAKE_SOURCE_DIR}" CALL siesta_patch_libstell)

install (TARGETS xsiesta)

################################################################################
#  Testing                                                                     #
################################################################################

#  Build test utilities.
add_executable (xsiesta_test)
add_dependencies (siesta pull_siesta)

target_link_libraries (xsiesta_test PUBLIC stell)
target_compile_features (xsiesta_test PRIVATE cxx_std_11)

add_executable (xsiesta_unit_tests)
target_link_libraries (xsiesta_unit_tests PUBLIC siesta)

add_subdirectory (Testing)

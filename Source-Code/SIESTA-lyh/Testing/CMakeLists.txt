function (siesta_case_fixtures case_name)
    set (vmec_test "siesta_${case_name}_vmec_test")
    set (siesta_test "siesta_${case_name}_siesta_test")
    set_tests_properties (${vmec_test} PROPERTIES FIXTURES_SETUP "${vmec_test}")
    set_tests_properties (${siesta_test} PROPERTIES
                          FIXTURES_REQUIRED "${vmec_test}"
                          FIXTURES_SETUP "${siesta_test}")
    get_property (comparison_tests DIRECTORY PROPERTY TESTS)
    list (REMOVE_ITEM comparison_tests ${vmec_test} ${siesta_test})
    if (comparison_tests)
        set_tests_properties (${comparison_tests} PROPERTIES FIXTURES_REQUIRED "${siesta_test}")
    endif ()
endfunction ()

add_subdirectory (tests)
add_subdirectory (test_utilities)

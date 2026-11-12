#include <vector>
#include <iostream>
#include <random>
#include <chrono>
#include <functional>
#include <cmath>
#include <limits>

#include "vmec_quantities.hpp"
#include "siesta_quantities.hpp"
#include "commandline_parser.hpp"

#define RUN_TEST_3D(vmec, siesta, method, name, args)                 \
if (args.is_set("-dump")) {                                           \
    dump([&vmec]   (const double s, const double u, const double v) { \
             return vmec.method(s,u,v);                               \
         },                                                           \
         [&siesta] (const double s, const double u, const double v) { \
             return siesta.method(s,u,v);                             \
         },                                                           \
         args.get<double> ("-u"),                                     \
         args.get<double> ("-v"),                                     \
         args.is_set("-relative"));                                   \
} else {                                                              \
    test([&vmec]   (const double s, const double u, const double v) { \
             return vmec.method(s,u,v);                               \
         },                                                           \
         [&siesta] (const double s, const double u, const double v) { \
             return siesta.method(s,u,v);                             \
         },                                                           \
         name,                                                        \
         args.get<double> ("-tol"),                                   \
         args.get<double> ("-min"),                                   \
         args.get<double> ("-max"),                                   \
         args.is_set("-relative"));                                   \
}

#define RUN_TEST_13D(vmec, siesta, method, name, args) \
if (args.is_set("-dump")) {                            \
    dump([&vmec]   (const double s) {                  \
            return vmec.method(s);                     \
         },                                            \
         [&siesta] (const double s) {                  \
            return siesta.method(s, 0.0, 0.0);         \
         },                                            \
         args.is_set("-relative"));                    \
} else {                                               \
    test([&vmec]   (const double s) {                  \
            return vmec.method(s);                     \
         },                                            \
         [&siesta] (const double s) {                  \
            return siesta.method(s, 0.0, 0.0);         \
         },                                            \
         name,                                         \
         args.get<double> ("-tol"),                    \
         args.get<double> ("-min"),                    \
         args.get<double> ("-max"),                    \
         args.is_set("-relative"));                    \
}

#define RUN_TEST_1D(vmec, siesta, method, name, arsg)           \
if (args.is_set("-dump")) {                                     \
    dump([&vmec]   (const double s) {return vmec.method(s);},   \
         [&siesta] (const double s) {return siesta.method(s);}, \
         args.is_set("-relative"));                             \
} else {                                                        \
    test([&vmec]   (const double s) {return vmec.method(s);},   \
         [&siesta] (const double s) {return siesta.method(s);}, \
         name,                                                  \
         args.get<double> ("-tol"),                             \
         args.get<double> ("-min"),                             \
         args.get<double> ("-max"),                             \
         args.is_set("-relative"));                             \
}

#define RUN_TEST_0D(vmec, siesta, method, name, args) \
if (args.is_set("-dump")) {                           \
    dump([&vmec]   () {return vmec.method();},        \
         [&siesta] () {return siesta.method();},      \
         args.is_set("-relative"));                   \
} else {                                              \
    test([&vmec]   () {return vmec.method();},        \
         [&siesta] () {return siesta.method();},      \
         name, args.get<double> ("-tol"),             \
         args.is_set("-relative"));                   \
}

#define RUN_TEST_DIV(eq, method, name, args)                  \
test([&eq] (const double s, const double u, const double v) { \
        return eq.method(s,u,v);                              \
     },                                                       \
     name,                                                    \
     args.get<double> ("-tol"),                               \
     args.get<double> ("-min"),                               \
     args.get<double> ("-max"))

static double comparison_error(double vmec, double siesta, bool relative) {
    if (!std::isfinite(vmec) || !std::isfinite(siesta) ||
        vmec == NC_FILL_DOUBLE || siesta == NC_FILL_DOUBLE ||
        vmec == NC_FILL_FLOAT || siesta == NC_FILL_FLOAT) {
        return std::numeric_limits<double>::infinity();
    }
    const double difference = std::abs(vmec - siesta);
    if (!relative || difference == 0.0) return difference;
    return difference/std::max(std::abs(vmec), std::abs(siesta));
}

//------------------------------------------------------------------------------
///  @brief Dump vmec and siesta scalar quantities.
///
///  @param[in] vmec     Getter function for the vmec value.
///  @param[in] siesta   Getter function for the siesta value.
///  @param[in] relative Use relative error.
//------------------------------------------------------------------------------
void dump(std::function<double()> vmec,
          std::function<double()> siesta,
          const bool relative) {
    const double vmec_value = vmec();
    const double siesta_value = siesta();
    double diff = comparison_error(vmec_value, siesta_value, relative);

    std::cout << vmec_value   << " ";
    std::cout << siesta_value << " ";
    std::cout << diff << std::endl;
}

//------------------------------------------------------------------------------
///  @brief Dump vmec and siesta 1D profile quantities.
///
///  @param[in] vmec     Getter function for the vmec value.
///  @param[in] siesta   Getter function for the siesta value.
///  @param[in] relative Use relative error.
//------------------------------------------------------------------------------
void dump(std::function<double(const double s)> vmec,
          std::function<double(const double s)> siesta,
          const bool relative) {
    for (double s = 0; s <= 1.0; s += 0.005) {
        const double vmec_value = vmec(s);
        const double siesta_value = siesta(s);
        double diff = comparison_error(vmec_value, siesta_value, relative);

        std::cout << s << " ";
        std::cout << vmec_value   << " ";
        std::cout << siesta_value << " ";
        std::cout << diff << std::endl;
    }
}

//------------------------------------------------------------------------------
///  @brief Dump vmec and siesta 3D profile quantities.
///
///  @param[in] vmec     Getter function for the vmec value.
///  @param[in] siesta   Getter function for the siesta value.
///  @param[in] u        Poloidal angle.
///  @param[in] v        Toroidal angle.
///  @param[in] relative Use relative error.
//------------------------------------------------------------------------------
void dump(std::function<double(const double, const double, const double)> vmec,
          std::function<double(const double, const double, const double)> siesta,
          const double u, const double v,
          const bool relative) {
    for (double s = 0; s <= 1.0; s += 0.005) {
        const double vmec_value = vmec(s, u, v);
        const double siesta_value = siesta(s, u, v);
        double diff = comparison_error(vmec_value, siesta_value, relative);

        std::cout << s << " ";
        std::cout << vmec_value   << " ";
        std::cout << siesta_value << " ";
        std::cout << diff << std::endl;
    }
}

//------------------------------------------------------------------------------
///  @brief Test comparitor.
///
///  Randomly samples s,u,v positions to check that the value fall with in the
///  tolerance value.
///
///  @param[in] vmec      Getter function for the vmec value.
///  @param[in] siesta    Getter function for the siesta value.
///  @param[in] name      Name of the test.
///  @param[in] tolarance Tolarnce threshold that values must fall with in.
///  @param[in] smin      Minimum radial extent.
///  @param[in] smax      Maximum radial extent.
///  @param[in] relative  Use relative error.
//------------------------------------------------------------------------------
void test(std::function<double(const double,const double,const double)> vmec,
          std::function<double(const double,const double,const double)> siesta,
          const std::string &name,
          const double tolarance,
          const double smin,
          const double smax,
          const bool relative) {
    std::default_random_engine engine(std::chrono::system_clock::now().time_since_epoch().count());
    std::uniform_real_distribution<double> min_to_max(smin, smax);
    std::uniform_real_distribution<double> zero_to_twopi(0.0, 2.0*M_PI);

    for (size_t i = 0; i < 1000000; i++) {
        double s = min_to_max(engine);
        const double u = zero_to_twopi(engine);
        const double v = zero_to_twopi(engine);
        double vmec_value = vmec(s, u, v);
        double siesta_value = siesta(s, u, v);
        double diff = comparison_error(vmec_value, siesta_value, relative);

        const bool pass = diff < tolarance;

        if (!pass) {
            std::cout << name << ": failed at s = " << s
                      <<                    " u = " << u
                      <<                    " v = " << v << std::endl;
            std::cout <<            "vmec value = " << vmec_value
                      <<         " siesta value = " << siesta_value
                      << " difference between vmec and siesta = "
                      << diff << std::endl;

            for (s = 0; s <= 1.0; s += 0.001) {
                vmec_value = vmec(s, u, v);
                siesta_value = siesta(s, u, v);
                diff = comparison_error(vmec_value, siesta_value, relative);

                std::cout << s << " "
                          << vmec_value << " " << siesta_value << " "
                          << diff << std::endl;
            }

            exit(1);
        }
    }

    std::cout << name << " : passed" << std::endl;
}

//------------------------------------------------------------------------------
///  @brief Test comparitor.
///
///  Randomly samples s,u,v positions to check that the value fall with in the
///  tolerance value.
///
///  @param[in] div       Getter function for the diveregnce value.
///  @param[in] name      Name of the test.
///  @param[in] tolarance Tolarnce threshold that values must fall with in.
///  @param[in] smin      Minimum radial extent.
///  @param[in] smax      Maximum radial extent.
//------------------------------------------------------------------------------
void test(std::function<double(const double,const double,const double)> div,
          const std::string &name,
          const double tolarance,
          const double smin,
          const double smax) {
    std::default_random_engine engine(std::chrono::system_clock::now().time_since_epoch().count());
    std::uniform_real_distribution<double> min_to_max(smin, smax);
    std::uniform_real_distribution<double> zero_to_twopi(0.0, 2.0*M_PI);

    for (size_t i = 0; i < 1000000; i++) {
        double s = min_to_max(engine);
        const double u = zero_to_twopi(engine);
        const double v = zero_to_twopi(engine);
        double diff = std::abs(div(s, u, v));

        const bool pass = diff < tolarance;

        if (!pass) {
            std::cout << name << ": failed at s = " << s
                      <<                    " u = " << u
                      <<                    " v = " << v << std::endl;
            std::cout << " divergence = "
                      << diff << std::endl;

            for (s = 0; s <= 1.0; s += 0.001) {
                diff = std::abs(div(s, u, v));
                std::cout << s << " "
                          << diff << std::endl;
            }

            exit(1);
        }
    }

    std::cout << name << " : passed" << std::endl;
}

//------------------------------------------------------------------------------
///  @brief Test comparitor.
///
///  Randomly samples s positions to check that the value fall with in the
///  tolerance value.
///
///  @param[in] vmec      Getter function for the vmec value.
///  @param[in] siesta    Getter function for the siesta value.
///  @param[in] name      Name of the test.
///  @param[in] tolarance Tolarnce threshold that values must fall with in.
///  @param[in] smin      Minimum radial extent.
///  @param[in] smax      Maximum radial extent.
///  @param[in] relative  Use relative error.
//------------------------------------------------------------------------------
void test(std::function<double(const double)> vmec,
          std::function<double(const double)> siesta,
          const std::string &name,
          const double tolarance,
          const double smin,
          const double smax,
          const bool relative) {
    std::default_random_engine engine(std::chrono::system_clock::now().time_since_epoch().count());
    std::uniform_real_distribution<double> min_to_max(smin, smax);
    std::uniform_real_distribution<double> zero_to_twopi(0.0, 2.0*M_PI);

    for (size_t i = 0; i < 1000000; i++) {
        double s = min_to_max(engine);
        double vmec_value = vmec(s);
        double siesta_value = siesta(s);
        double diff = comparison_error(vmec_value, siesta_value, relative);

        const bool pass = diff < tolarance;

        if (!pass) {
            std::cout << name << ": failed at s = " << s << std::endl;
            std::cout <<            "vmec value = " << vmec_value
                      <<         " siesta value = " << siesta_value
                      << " difference between vmec and siesta = "
                      << diff << std::endl;

            for (s = 0; s <= 1.0; s += 0.001) {
                vmec_value = vmec(s);
                siesta_value = siesta(s);
                diff = comparison_error(vmec_value, siesta_value, relative);

                std::cout << s << " "
                          << vmec_value << " " << siesta_value << " "
                          << diff << std::endl;
            }

            exit(1);
        }
    }

    std::cout << name << " : passed" << std::endl;
}

//------------------------------------------------------------------------------
///  @brief Test comparitor.
///
///  Randomly samples s positions to check that the value fall with in the
///  tolerance value.
///
///  @param[in] vmec      Getter function for the vmec value.
///  @param[in] siesta    Getter function for the siesta value.
///  @param[in] name      Name of the test.
///  @param[in] tolarance Tolarnce threshold that values must fall with in.
///  @param[in] smin      Minimum radial extent.
///  @param[in] smax      Maximum radial extent.
///  @param[in] relative  Use relative error.
//------------------------------------------------------------------------------
void test(std::function<double(void)> vmec,
          std::function<double(void)> siesta,
          const std::string &name,
          const double tolarance,
          const bool relative) {

    double vmec_value = vmec();
    double siesta_value = siesta();
    double diff = comparison_error(vmec_value, siesta_value, relative);

    const bool pass = diff < tolarance;

    if (!pass) {
        std::cout << name << ": failed " << std::endl;
        std::cout <<     "vmec value = " << vmec_value
                  <<  " siesta value = " << siesta_value
                  << " difference between vmec and siesta = "
                  << diff << std::endl;

        exit(1);
    }

    std::cout << name << " : passed" << std::endl;
}

// Check a quadratic profile with an explicitly invalid unused axis slot.
static int test_half_grid_derivative() {
    for (const size_t count : {3, 9, 65}) {
        const double h = 1.0/(count - 1);
        std::vector<double> values(count);
        values[0] = std::numeric_limits<double>::quiet_NaN();
        for (size_t i = 1; i < count; ++i) {
            const double radius = (i - 0.5)*h;
            values[i] = radius*radius;
        }
        const auto derivative = half_grid(values).get_prime(0.0);
        for (size_t i = 1; i + 1 < count; ++i) {
            const double actual = derivative.get(i*h);
            if (!std::isfinite(actual) || std::abs(actual - 2*i*h) > 1e-14) {
                std::cerr << "Half-grid derivative mismatch at full-grid point "
                          << i << " of " << count << std::endl;
                return 1;
            }
        }
    }
    std::cout << "Half-grid derivative passed" << std::endl;
    return 0;
}

//------------------------------------------------------------------------------
///  @brief Main test program.
///
///  @param[in] argc Number of commandline arguments.
///  @param[in] argv Array of arguments strings.
//------------------------------------------------------------------------------
int main(int argc, const char * argv[]) try {
    const commandline_parser args(argc, argv);
    const std::string test_name = args.get<std::string> ("-test_name");
    if (test_name == "half_grid_derivative") return test_half_grid_derivative();

    // The interpolation domain is normalized VMEC flux, 0 <= s <= 1.
    // Validate before loading either file or constructing a distribution:
    // negative s reaches sqrt(s), and out-of-domain sampling can otherwise
    // compare endpoint-clamped values instead of the requested profiles.
    if (!args.is_set("-dump")) {
        const double tolerance = args.get<double>("-tol");
        if (!std::isfinite(tolerance) || tolerance <= 0.0) {
            throw std::runtime_error("-tol must be finite and positive");
        }
        if (test_name != "curtor") {
            const double minimum = args.get<double>("-min");
            const double maximum = args.get<double>("-max");
            if (!std::isfinite(minimum) || !std::isfinite(maximum) ||
                minimum < 0.0 || maximum > 1.0 || minimum > maximum) {
                throw std::runtime_error("Sampling requires 0 <= -min <= -max <= 1");
            }
        }
    }
    for (const auto *angle : {"-u", "-v"}) {
        if (args.is_set(angle) && !std::isfinite(args.get<double>(angle))) {
            throw std::runtime_error(std::string(angle) + " must be finite");
        }
    }

    const vmec_quantities vmec(args.get<std::string> ("-wout_file"));
    const siesta_quantities siesta(args.get<std::string> ("-restart_file"));

    if (test_name == "r") {
        RUN_TEST_3D(vmec, siesta, get_r, test_name, args);
    } else if (test_name == "z") {
        RUN_TEST_3D(vmec, siesta, get_z, test_name, args);
    } else if (test_name == "drdu") {
        RUN_TEST_3D(vmec, siesta, get_dr_du, test_name, args);
    } else if (test_name == "drdv") {
        RUN_TEST_3D(vmec, siesta, get_dr_dv, test_name, args);
    } else if (test_name == "dzdu") {
        RUN_TEST_3D(vmec, siesta, get_dz_du, test_name, args);
    } else if (test_name == "dzdv") {
        RUN_TEST_3D(vmec, siesta, get_dz_dv, test_name, args);
    } else if (test_name == "phipf") {
        RUN_TEST_1D(vmec, siesta, get_phipf, test_name, args);
    } else if (test_name == "chipf") {
        RUN_TEST_1D(vmec, siesta, get_chipf, test_name, args);
    } else if (test_name == "bsups") {
        RUN_TEST_3D(vmec, siesta, get_bsups, test_name, args);
    } else if (test_name == "bsupu") {
        RUN_TEST_3D(vmec, siesta, get_bsupu, test_name, args);
    } else if (test_name == "bsupv") {
        RUN_TEST_3D(vmec, siesta, get_bsupv, test_name, args);
    } else if (test_name == "bsubs") {
        RUN_TEST_3D(vmec, siesta, get_bsubs, test_name, args);
    } else if (test_name == "bsubu") {
        RUN_TEST_3D(vmec, siesta, get_bsubu, test_name, args);
    } else if (test_name == "bsubv") {
        RUN_TEST_3D(vmec, siesta, get_bsubv, test_name, args);
    } else if (test_name == "jbsups") {
        RUN_TEST_3D(vmec, siesta, get_jbsups, test_name, args);
    } else if (test_name == "jbsupu") {
        RUN_TEST_3D(vmec, siesta, get_jbsupu, test_name, args);
    } else if (test_name == "jbsupv") {
        RUN_TEST_3D(vmec, siesta, get_jbsupv, test_name, args);
    } else if (test_name == "jksups") {
        RUN_TEST_3D(vmec, siesta, get_jksups, test_name, args);
    } else if (test_name == "jksupu") {
        RUN_TEST_3D(vmec, siesta, get_jksupu, test_name, args);
    } else if (test_name == "jksupv") {
        RUN_TEST_3D(vmec, siesta, get_jksupv, test_name, args);
    } else if (test_name == "jacobian") {
        RUN_TEST_3D(vmec, siesta, get_jacobian, test_name, args);
    } else if (test_name == "curtor") {
        RUN_TEST_0D(vmec, siesta, get_curtor, test_name, args);
    } else if (test_name == "vmec_divb") {
        RUN_TEST_DIV(vmec, get_divb, test_name, args);
    } else if (test_name == "siesta_divb") {
        RUN_TEST_DIV(siesta, get_divb, test_name, args);
    } else if (test_name == "pressure") {
        RUN_TEST_13D(vmec, siesta, get_pressure, test_name, args);
    } else if (test_name == "test") {
        RUN_TEST_1D(vmec, siesta, get_test, test_name, args);
    } else {
        std::cerr << "Unknown test name " << test_name << "." << std::endl;
        return 1;
    }
    return 0;
} catch (const std::exception &error) {
    std::cerr << error.what() << std::endl;
    return 1;
}

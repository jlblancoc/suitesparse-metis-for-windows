# -----------------------------------------------
# Test CMake script for building against SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# Updated by NeroBurner (pyro4hell@gmail.com) 2019-04-11
# -----------------------------------------------

PROJECT(SPQR_example)

cmake_minimum_required(VERSION 2.8)

# ------------------------------------------------------------------
# Detect SuiteSparse libraries:
# If not found automatically, set SuiteSparse_DIR in CMake to the
# directory containing suitesparse-config.cmake located in the
# installed directory.
# for example use the following command line
# cmake -S . -B _build -DSuiteSparse_DIR=../../_install/lib/cmake/suitesparse-5.1.0
# ------------------------------------------------------------------
find_package(SuiteSparse CONFIG REQUIRED)
# ------------------------------------------------------------------
#   End of SuiteSparse detection
# ------------------------------------------------------------------


# ------------------------------------------------------------------
# Declare an example program:
# ------------------------------------------------------------------
add_executable(spqr-test spqr-test.cpp)
target_link_libraries(spqr-test PRIVATE SuiteSparse::spqr)

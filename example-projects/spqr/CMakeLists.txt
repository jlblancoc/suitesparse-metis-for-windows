# -----------------------------------------------
# Test CMake script for building against SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# Updated by NeroBurner (pyro4hell@gmail.com) 2019-04-11
# -----------------------------------------------

# Hunter stuff must be included before project()
if (WIN32)
  set(HUNTER_ENABLED_DEFAULT ON)
else()
  set(HUNTER_ENABLED_DEFAULT OFF)
endif()
option(HUNTER_ENABLED "Enable Hunter package manager support" ${HUNTER_ENABLED_DEFAULT})
include("../../cmake/HunterGate.cmake")
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.23.244.tar.gz"
    SHA1 "2c0f491fd0b80f7b09e3d21adb97237161ef9835"
)

project(SPQR_example CXX)

cmake_minimum_required(VERSION 3.1)

include(CheckLanguage)
check_language(Fortran)
if(CMAKE_Fortran_COMPILER)
  enable_language(Fortran)
else()
  # if there are undefined references like "undefined reference to '_gfortran_st_write'"
  # try to install a fortran compiler like gfortran
  message(STATUS "No Fortran support. If there are link errors try installing gfortran (or similar)")
endif()

# ------------------------------------------------------------------
# Detect SuiteSparse libraries:
# Either tell Hunter to provide SuiteSparse for you or manually
# define where SuiteSparse and LAPACK can be found.
# To activate Hunter use the following commandline
# cmake -S . -B _build -DHUNTER_ENABLED=ON
#
# In the manual case, if not found automatically, set SuiteSparse_DIR
# in CMake to the directory containing suitesparse-config.cmake located
# in the installed directory.
# for example use the following command line
# cmake -S . -B _build -DSuiteSparse_DIR=../../_install/lib/cmake/suitesparse-5.1.0
# ------------------------------------------------------------------
hunter_add_package(SuiteSparse)
find_package(SuiteSparse CONFIG REQUIRED)
# ------------------------------------------------------------------
#   End of SuiteSparse detection
# ------------------------------------------------------------------

# ------------------------------------------------------------------
# Declare an example program:
# ------------------------------------------------------------------
add_executable(spqr-test spqr-test.cpp)
target_link_libraries(spqr-test PRIVATE SuiteSparse::spqr)

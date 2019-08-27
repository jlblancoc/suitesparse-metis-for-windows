# -----------------------------------------------
# Test CMake script for building against SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# Updated by NeroBurner (pyro4hell@gmail.com) 2019-04-11
# -----------------------------------------------

option(HUNTER_ENABLED "Enable Hunter package manager support" OFF)
include("../../cmake/HunterGate.cmake")
HunterGate(
  URL "https://github.com/ruslo/hunter/archive/v0.23.34.tar.gz"
  SHA1 "70287b1ffa810ee4e952052a9adff9b4856d0d54"
)

project(CholmodExample C)

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
add_executable(cholmod-test cholmod-test.c)
target_link_libraries(cholmod-test PRIVATE SuiteSparse::cholmod)

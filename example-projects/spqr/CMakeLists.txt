# -----------------------------------------------
# Test CMake script for building against SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# -----------------------------------------------

PROJECT(SPQR_example)

cmake_minimum_required(VERSION 2.8)

# ------------------------------------------------------------------
# Detect SuiteSparse libraries:
# If not found automatically, set SuiteSparse_DIR in CMake to the 
# directory where SuiteSparse was built.
# ------------------------------------------------------------------
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/../../cmakemodule/") # Add the directory where FindSuiteSparse.cmake module can be found.

set(SuiteSparse_USE_LAPACK_BLAS ON)
find_package(SuiteSparse QUIET NO_MODULE)  # 1st: Try to locate the *config.cmake file.
if(NOT SuiteSparse_FOUND)
        #set(SuiteSparse_VERBOSE ON)
        find_package(SuiteSparse REQUIRED) # 2nd: Use FindSuiteSparse.cmake module
        include_directories(${SuiteSparse_INCLUDE_DIRS})
else()
        message(STATUS "Find SuiteSparse : include(${USE_SuiteSparse})")
        include(${USE_SuiteSparse})
endif()
MESSAGE(STATUS "SuiteSparse_LIBS: ${SuiteSparse_LIBRARIES}")
# ------------------------------------------------------------------
#   End of SuiteSparse detection
# ------------------------------------------------------------------


# ------------------------------------------------------------------
# Declare an example program:
# ------------------------------------------------------------------
ADD_EXECUTABLE(spqr-test spqr-test.cpp)
TARGET_LINK_LIBRARIES(spqr-test ${SuiteSparse_LIBRARIES})

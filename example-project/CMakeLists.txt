# -----------------------------------------------
# Test CMake script for building against SuiteSparse
#  By Jose Luis Blanco - 2013
#  http://code.google.com/p/suitesparse-metis-for-windows/
# -----------------------------------------------

PROJECT(CholmodExample)

cmake_minimum_required(VERSION 2.6)

# ------------------------------------------------------------------
# If not found automatically, set SuiteSparse_DIR in CMake to the 
# directory where SuiteSparse was built.
# ------------------------------------------------------------------
FIND_PACKAGE(SuiteSparse REQUIRED )

# ------------------------------------------------------------------
# Declare an example program:
# ------------------------------------------------------------------
ADD_EXECUTABLE(cholmod-test cholmod-test.c)
TARGET_LINK_LIBRARIES(cholmod-test ${SuiteSparse_LIBS})

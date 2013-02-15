# -----------------------------------------------
# CMake build system for SuiteSparse
#  By Jose Luis Blanco - 2013
#  http://code.google.com/p/suitesparse-metis-for-windows/
# -----------------------------------------------

PROJECT(SuiteSparseProject)

cmake_minimum_required(VERSION 2.6)

SET(LIBRARY_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/lib CACHE PATH "Output directory for libraries" )
SET(EXECUTABLE_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/bin CACHE PATH "Output directory for applications" )

SET(BUILD_METIS_DEFAULT ON)	
IF(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/metis/CMakeLists.txt")
	SET(BUILD_METIS_DEFAULT OFF)	
ENDIF(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/metis/CMakeLists.txt")

SET(BUILD_METIS ${BUILD_METIS_DEFAULT} CACHE BOOL "Build METIS for partitioning?")

if(BUILD_METIS)
	add_subdirectory(metis)
endif(BUILD_METIS)

add_subdirectory(SuiteSparse)

#add_subdirectory(SPQR)


# Parse config file:
# -------------------------------------------------
SET(THE_SuiteSparse_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse/")
SET(THE_SuiteSparse_LIBS_INCL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse/include")
SET(THE_CMAKE_BINARY_DIR "${CMAKE_BINARY_DIR}")

# Linker libs:
SET(SuiteSparse_LINKER_LIBS "suitesparse")
IF(BUILD_METIS)
	SET(SuiteSparse_LINKER_LIBS "${SuiteSparse_LINKER_LIBS};metis")
ENDIF(BUILD_METIS)

IF (UNIX)
	SET(SuiteSparse_LINKER_LIBS
		${SuiteSparse_LINKER_LIBS}
		lapack
		blas
		rt
		)
ELSE(UNIX)
	IF(CMAKE_SIZEOF_VOID_P EQUAL 8)  # Size in bytes!
		set(PATH_WORD_SIZE "x64")
	ELSE(CMAKE_SIZEOF_VOID_P EQUAL 8)  # Size in bytes!
		set(PATH_WORD_SIZE "x32")
	ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 8)

	SET(SuiteSparse_LINKER_LIBS
		${SuiteSparse_LINKER_LIBS}
		${SuiteSparseProject_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/libblas.lib
		${SuiteSparseProject_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/liblapack.lib
		)
ENDIF(UNIX)

CONFIGURE_FILE(
	"${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparseConfig.cmake.in"
	"${CMAKE_CURRENT_BINARY_DIR}/SuiteSparseConfig.cmake"
	@ONLY)
	

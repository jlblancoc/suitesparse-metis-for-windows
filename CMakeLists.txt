# -----------------------------------------------
# CMake build system for SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# -----------------------------------------------

PROJECT(SuiteSparseProject)

cmake_minimum_required(VERSION 2.6)

SET(LIBRARY_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/lib CACHE PATH "Output directory for libraries" )
SET(EXECUTABLE_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/bin CACHE PATH "Output directory for applications" )

## get POSTFIX for lib install dir
if(CMAKE_SIZEOF_VOID_P MATCHES "8")
  set(LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 inst dir placement")
else()
  set(LIB_POSTFIX "" CACHE STRING "suffix for 32/64 inst dir placement")
endif()
mark_as_advanced(LIB_POSTFIX)

## check if we can build metis	
SET(BUILD_METIS_DEFAULT ON)	
IF(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/metis/CMakeLists.txt")
	SET(BUILD_METIS_DEFAULT OFF)
ENDIF(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/metis/CMakeLists.txt")

SET(BUILD_METIS ${BUILD_METIS_DEFAULT} CACHE BOOL "Build METIS for partitioning?")

SET(METIS_DIR ${${PROJECT_NAME}_SOURCE_DIR}/metis CACHE PATH "Source directory of METIS")

if(BUILD_METIS)
	## prepare the installation :
	## using metis target here is not possible because this target is added in another branch of the CMake structure
	## TRICK: need to dynamically modify the metis CMakeLists.txt file before it going to parsed... 
	## (very ugly/poor for a metis project get from SCM (git/svn/cvs) but it's works ;) and it doesn't matter if metis was get from .zip)
	if(EXISTS "${METIS_DIR}/libmetis/CMakeLists.txt")
		file(READ "${METIS_DIR}/libmetis/CMakeLists.txt" contentFile)
		string(REGEX MATCH "EXPORT 	SuiteSparse" alreadyModified ${contentFile}) ## use a string pattern to check if we have to do the modif
		if(NOT alreadyModified)
			file(APPEND "${METIS_DIR}/libmetis/CMakeLists.txt"
			"
				set_target_properties(metis PROPERTIES PUBLIC_HEADER \"../include/metis.h\")
				install(TARGETS metis ## this line is also the string pattern to check if the modification had already done
						EXPORT 	SuiteSparse
						RUNTIME DESTINATION bin
						LIBRARY DESTINATION lib${LIB_POSTFIX}
						ARCHIVE DESTINATION lib${LIB_POSTFIX}
						PUBLIC_HEADER DESTINATION include
				)
			"
			)
		endif()
	endif()
	add_subdirectory(metis) ## important part for building metis from its src files
endif(BUILD_METIS)


## install_suitesparse_project(targetName headersList)  
## factorise the way we will install all projects (part of the suitesparse project)
## <targetName> is the target of the current project you build
## <headersList> is the list of all public headers the project use and have to be known by other projects
## 	example of use:
## 		file(GLOB LIBHDRS "Include/*.h")
## 		add_library(<myTarget> ...)
## 		install_suitesparse_project(<myTarget> "${LIBHDRS}")
macro(install_suitesparse_project targetName headersList)
	set_target_properties(${targetName} PROPERTIES PUBLIC_HEADER "${headersList}")
	install(TARGETS	${targetName}
			EXPORT 	SuiteSparse
			RUNTIME DESTINATION bin
			LIBRARY DESTINATION lib${LIB_POSTFIX}
			ARCHIVE DESTINATION lib${LIB_POSTFIX}
			PUBLIC_HEADER DESTINATION include/suitesparse
	)
endmacro()


## check if the SHARED variable has already been defined (by the metis project) and use it for our projects
## BUILD_SHARED_LIBS specific variable allow cmake to know what kind of lib (STATIC or SHARED) it have to build
if(DEFINED SHARED)
	set(BUILD_SHARED_LIBS ${SHARED})
else()
	set(SHARED FALSE CACHE BOOL "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)")
	set(BUILD_SHARED_LIBS OFF)
endif()

## Need to use SuiteSparse_LINKER_LIBS in our subproject in case of SHARED flag is set to ON
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
	
	## install lapack and blas dependencies
	file(GLOB lapack_blas_windows_libs 	"${CMAKE_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/*.lib")
	file(GLOB lapack_blas_windows_dll 	"${CMAKE_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/*.dll")
	if(lapack_blas_windows_dll AND lapack_blas_windows_libs)
		set(SuiteSparse_LAPACK_BLAS_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib${LIB_POSTFIX}/lapack_blas_windows") ## used in UseSuiteSparse*.cmake
		install(FILES 		${lapack_blas_windows_libs} 
							${lapack_blas_windows_dll}
				DESTINATION ${SuiteSparse_LAPACK_BLAS_LIB_DIR}
		)
	endif()
ENDIF(UNIX)
IF(BUILD_METIS)
	SET(SuiteSparse_LINKER_LIBS "${SuiteSparse_LINKER_LIBS};metis")
ENDIF(BUILD_METIS)

add_subdirectory(SuiteSparse)

# Parse config file:
# -------------------------------------------------
SET(THE_SuiteSparse_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse/")
SET(THE_SuiteSparse_LIBS_INCL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse/include")
SET(THE_CMAKE_BINARY_DIR "${CMAKE_BINARY_DIR}")

## For find SuiteSparse from the install dir
install(FILES 		SuiteSparseConfigForInstall.cmake
		DESTINATION	.
		RENAME 		SuiteSparseConfig.cmake ## This one will be the entry point for finding suitesparse from aother project using find_package()
)
configure_file(UseSuiteSparseForInstall.cmake.in UseSuiteSparseForInstall.cmake @ONLY)
install(FILES 		"${CMAKE_BINARY_DIR}/UseSuiteSparseForInstall.cmake"
		DESTINATION	.
		RENAME 		UseSuiteSparse.cmake
)

## do the EXPORT for allowing other project to easily use suitesparse with cmake
install(EXPORT  	SuiteSparse
        DESTINATION cmake
        FILE        SuiteSparse-config.cmake
)

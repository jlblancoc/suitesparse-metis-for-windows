# -----------------------------------------------------------------
# CMake build system for SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013-2014
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# -----------------------------------------------------------------

PROJECT(SuiteSparseProject)

cmake_minimum_required(VERSION 2.8.10)

include(checkGetSuiteSparse.cmake)

SET(LIBRARY_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/lib CACHE PATH "Output directory for libraries" )
SET(EXECUTABLE_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/bin CACHE PATH "Output directory for applications" )

# Override "CMAKE_INSTALL_PREFIX", at least in Windows:
IF(WIN32)
	SET(SUITESPARSE_INSTALL_PREFIX "${${PROJECT_NAME}_BINARY_DIR}/install" CACHE PATH "Prefix prepended to install directories")
	SET(CMAKE_INSTALL_PREFIX "${SUITESPARSE_INSTALL_PREFIX}" CACHE INTERNAL "Prefix prepended to install directories" FORCE)
ENDIF()

## get POSTFIX for lib install dir
if(CMAKE_SIZEOF_VOID_P MATCHES "8")
  set(LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 inst dir placement")
else()
  set(LIB_POSTFIX "" CACHE STRING "suffix for 32/64 inst dir placement")
endif()
mark_as_advanced(LIB_POSTFIX)

# We want libraries to be named "libXXX" and "libXXXd" in all compilers:
# ------------------------------------------------------------------------
set(CMAKE_DEBUG_POSTFIX  "d")
IF(MSVC)
	set(SP_LIB_PREFIX "lib")  # Libs are: "libXXX"
ENDIF(MSVC)

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


## For EXPORT only :
## Previous version of cmake (>2.8.12) doesn't auto take into account external lib (here I mean blas and lapack) we need to link to for our current target we want to export.
## Or at least we need to investigate how to do with previous version.
## This may cause some trouble in case you want to build in static mode and then use it into another custom project.
## You will need to manually link your target into your custom project to the correct dependencies link interfaces.
if("${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}" GREATER 2.8.11) ## (policies introduced both in 2.8.12)
	set(EXPORT_USE_INTERFACE_LINK_LIBRARIES ON CACHE BOOL "")
	mark_as_advanced(EXPORT_USE_INTERFACE_LINK_LIBRARIES)
	if(EXPORT_USE_INTERFACE_LINK_LIBRARIES)
		cmake_policy(SET CMP0023 NEW) ## just for respecting the new target_link_libraries(...) signature procedure
		cmake_policy(SET CMP0022 NEW) ## use INTERFACE_LINK_LIBRARIES property for in-build targets and ignore old properties (IMPORTED_)?LINK_INTERFACE_LIBRARIES(_<CONFIG>)?
		## Here, next version of cmake 2.8.12 auto take into account the link interface dependencies (see generated cmake/SuiteSparse-config*.cmake into your install dir)
	endif()
endif()


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
	
## declare_suitesparse_library(targetName srcsList headersList)
## 	Example of use: See SuiteSparse/*/CMakeLists.txt
macro(declare_suitesparse_library targetName srcsList headersList)

	## following args are optional
	include(CMakeParseArguments)
    cmake_parse_arguments(dsl "" "" "TARGET_PRIVATE_LINK;TARGET_PUBLIC_LINK" ${ARGN} )

	if(NOT dsl_TARGET_PRIVATE_LINK)
		set(dsl_TARGET_PRIVATE_LINK "")
	endif()
	if(NOT dsl_TARGET_PUBLIC_LINK)
		set(dsl_TARGET_PUBLIC_LINK "")
	endif()
	find_package(CUDA)
	IF(${CUDA_FOUND})
		INCLUDE_DIRECTORIES(${CUDA_INCLUDE_DIRS})
		INCLUDE_DIRECTORIES(${SuiteSparse_GPUQREngine_INCLUDE})
		INCLUDE_DIRECTORIES(${SuiteSparse_GPURuntime_INCLUDE})
		CUDA_ADD_LIBRARY(${targetName} ${srcsList} ${headersList})
	ELSE(${CUDA_FOUND})
		ADD_LIBRARY(${targetName} ${srcsList} ${headersList})
	ENDIF(${CUDA_FOUND})
	SET_TARGET_PROPERTIES(${targetName} PROPERTIES 
		OUTPUT_NAME ${SP_LIB_PREFIX}${targetName}
	)
	
	target_link_libraries(${targetName} 
			 ${dsl_TARGET_PUBLIC_LINK} suitesparseconfig ## suitesparseconfig is used for every projects (embedded into cmake build)
		 ${dsl_TARGET_PRIVATE_LINK}	## external required libs
	)

	install_suitesparse_project(${targetName} "${headersList}")
endmacro()

# Example of usage: 
#  REMOVE_MATCHING_FILES_FROM_LIST(".*_LIN.cpp" my_srcs)
MACRO(REMOVE_MATCHING_FILES_FROM_LIST match_expr lst_files)
	SET(lst_files_aux "")
	FOREACH(FIL ${${lst_files}})
		IF(NOT ${FIL} MATCHES "${match_expr}")
			SET(lst_files_aux "${lst_files_aux}" "${FIL}")
		ENDIF(NOT ${FIL} MATCHES "${match_expr}")
	ENDFOREACH(FIL)
	SET(${lst_files} ${lst_files_aux})
ENDMACRO(REMOVE_MATCHING_FILES_FROM_LIST)


## check if the SHARED variable has already been defined (by the metis project) and use it for our projects
## BUILD_SHARED_LIBS specific variable allow cmake to know what kind of lib (STATIC or SHARED) it have to build
if(DEFINED SHARED) 
	set(BUILD_SHARED_LIBS ${SHARED})
else()
	set(SHARED FALSE CACHE BOOL "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)")
	set(BUILD_SHARED_LIBS OFF)
endif()

FIND_PACKAGE(cuda)
IF(${CUDA_FOUND})
ADD_DEFINITIONS(-DGPU_BLAS)
ENDIF(${CUDA_FOUND})

## Need to use SuiteSparse_LINKER_LAPACK_BLAS_LIBS in our subproject in case of SHARED flag is set to ON
SET(SUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS OFF CACHE BOOL "Check if you have custom LAPACK/BLAS libraries (AMD,...)")
IF (SUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS)
	SET(SUITESPARSE_CUSTOM_BLAS_LIB "" CACHE FILE "Path to custom library file for BLAS")
	SET(SUITESPARSE_CUSTOM_LAPACK_LIB "" CACHE FILE "Path to custom library file for LAPACK")
	IF (NOT EXISTS "${SUITESPARSE_CUSTOM_BLAS_LIB}" OR NOT EXISTS "${SUITESPARSE_CUSTOM_LAPACK_LIB}")
		MESSAGE("*Error*: Correctly set SUITESPARSE_CUSTOM_BLAS_LIB and SUITESPARSE_CUSTOM_LAPACK_LIB or uncheck SUITESPARSE_USE_CUSTOM_BLAS_LAPACK_LIBS")
	ELSE()
		SET(SuiteSparse_LINKER_LAPACK_BLAS_LIBS ${SUITESPARSE_CUSTOM_BLAS_LIB} ${SUITESPARSE_CUSTOM_LAPACK_LIB})
	ENDIF()
ELSE()
	IF (UNIX)
		SET(SuiteSparse_LINKER_LAPACK_BLAS_LIBS lapack blas rt)
	ELSE()
		IF(CMAKE_SIZEOF_VOID_P EQUAL 8)  # Size in bytes!
			set(PATH_WORD_SIZE "x64")
		ELSE(CMAKE_SIZEOF_VOID_P EQUAL 8)  # Size in bytes!
			set(PATH_WORD_SIZE "x32")
		ENDIF(CMAKE_SIZEOF_VOID_P EQUAL 8)

		add_library(blas SHARED IMPORTED)
		set_property(TARGET blas PROPERTY IMPORTED_LOCATION ${SuiteSparseProject_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/libblas.dll)
		set_property(TARGET blas PROPERTY IMPORTED_IMPLIB 	${SuiteSparseProject_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/libblas.lib)
		
		add_library(lapack SHARED IMPORTED)
		set_property(TARGET lapack PROPERTY IMPORTED_LOCATION 	${SuiteSparseProject_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/liblapack.dll)
		set_property(TARGET lapack PROPERTY IMPORTED_IMPLIB 	${SuiteSparseProject_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/liblapack.lib)
	 
		SET(SuiteSparse_LINKER_LAPACK_BLAS_LIBS blas lapack)
		
		## install lapack and blas dependencies
		file(GLOB lapack_blas_windows_libs 	"${CMAKE_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/*.lib")
		file(GLOB lapack_blas_windows_dll 	"${CMAKE_SOURCE_DIR}/lapack_windows/${PATH_WORD_SIZE}/*.dll")
		if(lapack_blas_windows_dll AND lapack_blas_windows_libs)
			set(SuiteSparse_LAPACK_BLAS_LIB_DIR "lib${LIB_POSTFIX}/lapack_blas_windows") ## used in UseSuiteSparse*.cmake
			install(FILES 		${lapack_blas_windows_libs} 
								${lapack_blas_windows_dll}
					DESTINATION ${SuiteSparse_LAPACK_BLAS_LIB_DIR}
			)
		endif()
	ENDIF()
ENDIF()

IF(BUILD_METIS)
	set(SuiteSparse_LINKER_METIS_LIBS "metis")
else()
	set(SuiteSparse_LINKER_METIS_LIBS "")
ENDIF()

add_subdirectory(SuiteSparse)

## For find SuiteSparse from the install dir
install(FILES 		SuiteSparseConfigForInstall.cmake
		DESTINATION	.
		RENAME 		SuiteSparseConfig.cmake ## This one will be the entry point for finding suitesparse from aother project using find_package()
)
configure_file(UseSuiteSparseForInstall.cmake.in UseSuiteSparseForInstall.cmake @ONLY)
install(FILES 		"${CMAKE_BINARY_DIR}/UseSuiteSparseForInstall.cmake"
		DESTINATION	.
		RENAME 		UseSuiteSparse${LIB_POSTFIX}.cmake
)

## do the EXPORT for allowing other project to easily use suitesparse with cmake
install(EXPORT  	SuiteSparse
        DESTINATION cmake
        FILE        SuiteSparse-config${LIB_POSTFIX}.cmake
)

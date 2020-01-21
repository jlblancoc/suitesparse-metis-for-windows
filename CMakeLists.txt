# -----------------------------------------------------------------
# CMake build system for SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013-2014
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# -----------------------------------------------------------------

# Hunter stuff must be included before project()
option(HUNTER_ENABLED "Enable Hunter package manager support" OFF)

if(NOT ${CMAKE_VERSION} VERSION_LESS "3.12.0")
  cmake_policy(SET CMP0074 NEW) # Use PKG_ROOT variables.
endif()

include(cmake/HunterGate.cmake)
HunterGate(
    URL "https://github.com/cpp-pm/hunter/archive/v0.23.244.tar.gz"
    SHA1 "2c0f491fd0b80f7b09e3d21adb97237161ef9835"
)
PROJECT(SuiteSparseProject)

cmake_minimum_required(VERSION 3.1)

# https://cmake.org/cmake/help/latest/prop_tgt/CXX_STANDARD.html
string(COMPARE EQUAL "${CMAKE_CXX_STANDARD}" "" no_cmake_cxx_standard_set)
if(no_cmake_cxx_standard_set)
  set(CMAKE_CXX_STANDARD 11)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
  set(CMAKE_CXX_EXTENSIONS OFF)
  message(STATUS "Using default C++ standard ${CMAKE_CXX_STANDARD}")
else()
  message(STATUS "Using user specified C++ standard ${CMAKE_CXX_STANDARD}")
endif()

include(checkGetSuiteSparse.cmake)

if(BUILD_SHARED_LIBS)
	set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif(BUILD_SHARED_LIBS)


SET(LIBRARY_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/lib CACHE PATH "Output directory for libraries" )
SET(EXECUTABLE_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/bin CACHE PATH "Output directory for applications" )

# Override "CMAKE_INSTALL_PREFIX", on Windows if not set:
if(WIN32 AND (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT))
	set(CMAKE_INSTALL_PREFIX "${${PROJECT_NAME}_BINARY_DIR}/install" CACHE PATH "Prefix prepended to install directories" FORCE)
	message(STATUS "Setting default CMAKE_INSTALL_PREFIX to: ${CMAKE_INSTALL_PREFIX}")
else()
    # pass user defined install prefix to SuiteSparse
    message(STATUS "Using user defined CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
endif()

# Fix GKlib path:
IF(NOT WIN32)
  SET(GKLIB_PATH "${${PROJECT_NAME}_SOURCE_DIR}/SuiteSparse/metis-5.1.0/GKlib" CACHE INTERNAL "Path to GKlib (for METIS)" FORCE)
ENDIF()

# allow creating DLLs in Windows without touching the source code:
IF(NOT ${CMAKE_VERSION} VERSION_LESS "3.4.0" AND WIN32)
	set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
ENDIF()

## get CMAKE_INSTALL_BINDIR and CMAKE_INSTALL_LIBDIR
include(GNUInstallDirs)

if(CMAKE_SIZEOF_VOID_P MATCHES "8")
  set(SUITESPARSE_LIB_POSTFIX "64")
else()
  set(SUITESPARSE_LIB_POSTFIX "")
endif()

## get POSTFIX for lib install dir
set(LIB_POSTFIX "${SUITESPARSE_LIB_POSTFIX}" CACHE STRING "suffix for 32/64 inst dir placement")
mark_as_advanced(LIB_POSTFIX)

# We want libraries to be named "libXXX" and "libXXXd" in all compilers:
# ------------------------------------------------------------------------
set(CMAKE_DEBUG_POSTFIX  "d")
IF(MSVC)
	set(SP_LIB_PREFIX "lib")  # Libs are: "libXXX"
ENDIF(MSVC)

## check if we can build metis
SET(BUILD_METIS_DEFAULT ON)
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse/metis-5.1.0/CMakeLists.txt")
	SET(BUILD_METIS_DEFAULT OFF)
endif()

SET(WITH_CUDA OFF CACHE BOOL "Build with CUDA support")

SET(BUILD_METIS ${BUILD_METIS_DEFAULT} CACHE BOOL "Build METIS for partitioning?")
SET(METIS_DIR ${${PROJECT_NAME}_SOURCE_DIR}/SuiteSparse/metis-5.1.0 CACHE PATH "Source directory of METIS")

if(BUILD_METIS)
	## prepare the installation :
	## using metis target here is not possible because this target is added in another branch of the CMake structure
	## TRICK: need to dynamically modify the metis CMakeLists.txt file before it going to parsed...
	## (very ugly/poor for a metis project get from SCM (git/svn/cvs) but it's works ;) and it doesn't matter if metis was get from .zip)
	if(EXISTS "${METIS_DIR}/libmetis/CMakeLists.txt")
		file(READ "${METIS_DIR}/libmetis/CMakeLists.txt" contentFile)
		string(REGEX MATCH "EXPORT 	SuiteSparseTargets" alreadyModified ${contentFile}) ## use a string pattern to check if we have to do the modif
		if(NOT alreadyModified)
			file(APPEND "${METIS_DIR}/libmetis/CMakeLists.txt"
			"
				set_target_properties(metis PROPERTIES PUBLIC_HEADER \"../include/metis.h\")
				install(TARGETS metis ## this line is also the string pattern to check if the modification had already done
						EXPORT 	SuiteSparseTargets
						RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
						LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
						ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
						PUBLIC_HEADER DESTINATION include
				)
			"
			)
		endif()
	endif()
    add_subdirectory(SuiteSparse/metis-5.1.0) ## important part for building metis from its src files
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

	## set position independend code for GCC, Clang static (and shared?) libs
	if (NOT MINGW AND NOT MSVC)
		target_compile_options(${targetName} PRIVATE "-fPIC")
	endif()

	## set include dir for install target
	target_include_directories(${targetName} PUBLIC
		$<INSTALL_INTERFACE:include>
		$<INSTALL_INTERFACE:include/suitesparse>
	)

	set_target_properties(${targetName} PROPERTIES PUBLIC_HEADER "${headersList}")
	install(TARGETS	${targetName}
			EXPORT 	SuiteSparseTargets
			RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
			LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
			ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
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
	if(WITH_CUDA)
		find_package(CUDA)
	endif()
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

if(WITH_CUDA)
	FIND_PACKAGE(cuda)
	IF(${CUDA_FOUND})
		ADD_DEFINITIONS(-DGPU_BLAS)
	ENDIF(${CUDA_FOUND})
endif()

hunter_add_package(LAPACK) # only in effect if HUNTER_ENABLED is set
# prefer LAPACK config file
if (WIN32)
  set(LAPACK_DIR "lapack_windows/x64/" CACHE PATH "LAPACK directory" )
endif()

find_package(LAPACK CONFIG)
if (LAPACK_FOUND AND TARGET blas AND TARGET lapack)
  message(STATUS "found lapack and blas config file. Linking targets lapack and blas")
  message(STATUS "- LAPACK_CONFIG: ${LAPACK_CONFIG}")
  set(SuiteSparse_LINKER_LAPACK_BLAS_LIBS lapack blas)
  # for suitesparse-config file set method used to find LAPACK (and BLAS)
  set(SuiteSparse_LAPACK_used_CONFIG YES)
else()
  # missing config file or targets, try BLAS and LAPACK
  find_package(BLAS)
  find_package(LAPACK)
  if (BLAS_FOUND AND LAPACK_FOUND)
    message(STATUS "found lapack and blas config file. Linking targets lapack and blas")
    message(STATUS "- LAPACK_LIBRARIES: ${LAPACK_LIBRARIES}")
    message(STATUS "- BLAS_LIBRARIES:   ${BLAS_LIBRARIES}")
    set(SuiteSparse_LINKER_LAPACK_BLAS_LIBS ${LAPACK_LIBRARIES} ${BLAS_LIBRARIES})
    # for suitesparse-config file set method used to find LAPACK (and BLAS)
    set(SuiteSparse_LAPACK_used_CONFIG NO)
  else () # LAPACK is not found
    message(FATAL_ERROR "lapack not found")
  endif()
endif()

IF(BUILD_METIS)
	set(SuiteSparse_LINKER_METIS_LIBS "metis")
	## namespaced library target for config
	set(SuiteSparse_EXPORTED_METIS_LIBS "SuiteSparse::metis")
else()
	set(SuiteSparse_LINKER_METIS_LIBS "")
	set(SuiteSparse_EXPORTED_METIS_LIBS "")
ENDIF()

add_subdirectory(SuiteSparse)

macro(get_SuiteSparse_Version)
  set(_SuiteSparse_VERSION_FILE
	  "${CMAKE_SOURCE_DIR}/SuiteSparse/SuiteSparse_config/SuiteSparse_config.h")
  if(NOT EXISTS ${_SuiteSparse_VERSION_FILE})
    message(FATAL_ERROR
      "Could not find file: ${_SuiteSparse_VERSION_FILE} containing version "
      "information for >= v4 SuiteSparse installs.")
  endif()

  file(READ ${_SuiteSparse_VERSION_FILE} SUITESPARSE_CONFIG_CONTENTS)

  string(REGEX MATCH "#define SUITESPARSE_MAIN_VERSION [0-9]+"
    SuiteSparse_VERSION_MAJOR "${SUITESPARSE_CONFIG_CONTENTS}")
  string(REGEX REPLACE "#define SUITESPARSE_MAIN_VERSION ([0-9]+)" "\\1"
    SuiteSparse_VERSION_MAJOR "${SuiteSparse_VERSION_MAJOR}")

  string(REGEX MATCH "#define SUITESPARSE_SUB_VERSION [0-9]+"
    SuiteSparse_VERSION_MINOR "${SUITESPARSE_CONFIG_CONTENTS}")
  string(REGEX REPLACE "#define SUITESPARSE_SUB_VERSION ([0-9]+)" "\\1"
    SuiteSparse_VERSION_MINOR "${SuiteSparse_VERSION_MINOR}")

  string(REGEX MATCH "#define SUITESPARSE_SUBSUB_VERSION [0-9]+"
    SuiteSparse_VERSION_PATCH "${SUITESPARSE_CONFIG_CONTENTS}")
  string(REGEX REPLACE "#define SUITESPARSE_SUBSUB_VERSION ([0-9]+)" "\\1"
    SuiteSparse_VERSION_PATCH "${SuiteSparse_VERSION_PATCH}")

  # set version string
  set(SuiteSparse_VERSION
    "${SuiteSparse_VERSION_MAJOR}.${SuiteSparse_VERSION_MINOR}.${SuiteSparse_VERSION_PATCH}")
endmacro()

# get SuiteSparse version
get_SuiteSparse_Version()

set(ConfigPackageLocation ${CMAKE_INSTALL_LIBDIR}/cmake/suitesparse-${SuiteSparse_VERSION})
## create targets file
export(EXPORT SuiteSparseTargets
	FILE "${CMAKE_CURRENT_BINARY_DIR}/suitesparse/suitesparse-targets.cmake"
	NAMESPACE SuiteSparse::
)
## create config file
configure_file(cmake/SuiteSparse-config-install.cmake.in
	"${CMAKE_CURRENT_BINARY_DIR}/suitesparse/suitesparse-config.cmake"
	@ONLY
)
## do the EXPORT for allowing other project to easily use suitesparse with cmake
install(EXPORT SuiteSparseTargets
	FILE
		SuiteSparse-targets.cmake
	NAMESPACE
		SuiteSparse::
	DESTINATION
		${ConfigPackageLocation}
)
## write config-version file
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
	"${CMAKE_BINARY_DIR}/suitesparse/suitesparse-config-version.cmake"
	VERSION ${SuiteSparse_VERSION}
	COMPATIBILITY SameMajorVersion
)
## install config and config-version file
install(
	FILES
		"${CMAKE_CURRENT_BINARY_DIR}/suitesparse/suitesparse-config.cmake"
		"${CMAKE_CURRENT_BINARY_DIR}/suitesparse/suitesparse-config-version.cmake"
	DESTINATION
		${ConfigPackageLocation}
)

# -----------------------------------------------------------------
# CMake build system for SuiteSparse
#  http://code.google.com/p/suitesparse-metis-for-windows/
# Created by Jose Luis Blanco (University of Almeria) 2013-2014
# Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21
# -----------------------------------------------------------------

# Hunter stuff must be included before project()
option(HUNTER_ENABLED "Enable Hunter package manager support" OFF)
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(WITH_TBB "Enable using TBB" OFF)
option(WITH_OPENBLAS "Build with OpenBLAS instead of generic BLAS/LAPACK" OFF)
option(WITH_MKL "Build with MKL instead of generic BLAS/LAPACK" OFF)

if(NOT ${CMAKE_VERSION} VERSION_LESS "3.12.0")
  cmake_policy(SET CMP0074 NEW) # Use PKG_ROOT variables.
endif()

include(cmake/HunterGate.cmake)
HunterGate(
  URL "https://github.com/cpp-pm/hunter/archive/v0.24.9.tar.gz"
  SHA1 "09b7e533d3da57eec51765aa73041ecd5ec94e60"
)
project(SuiteSparseProject)

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
endif()


set(LIBRARY_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/lib CACHE PATH "Output directory for libraries" )
set(EXECUTABLE_OUTPUT_PATH ${${PROJECT_NAME}_BINARY_DIR}/bin CACHE PATH "Output directory for applications" )

# Override "CMAKE_INSTALL_PREFIX", on Windows if not set:
if(WIN32 AND (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT))
	set(CMAKE_INSTALL_PREFIX "${${PROJECT_NAME}_BINARY_DIR}/install" CACHE PATH "Prefix prepended to install directories" FORCE)
	message(STATUS "Setting default CMAKE_INSTALL_PREFIX to: ${CMAKE_INSTALL_PREFIX}")
else()
    # pass user defined install prefix to SuiteSparse
    message(STATUS "Using user defined CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
endif()

# Fix GKlib path:
if(NOT WIN32)
  set(GKLIB_PATH "${${PROJECT_NAME}_SOURCE_DIR}/SuiteSparse/metis-5.1.0/GKlib" CACHE INTERNAL "Path to GKlib (for METIS)" FORCE)
endif()

# allow creating DLLs in Windows without touching the source code:
if(NOT ${CMAKE_VERSION} VERSION_LESS "3.4.0" AND WIN32)
	set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

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
if(MSVC)
	set(SP_LIB_PREFIX "lib")  # Libs are: "libXXX"
endif(MSVC)

## check if we can build metis
set(BUILD_METIS_DEFAULT ON)
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse/metis-5.1.0/CMakeLists.txt")
	set(BUILD_METIS_DEFAULT OFF)
endif()

set(WITH_CUDA OFF CACHE BOOL "Build with CUDA support")

set(BUILD_METIS ${BUILD_METIS_DEFAULT} CACHE BOOL "Build METIS for partitioning?")
set(METIS_DIR ${${PROJECT_NAME}_SOURCE_DIR}/SuiteSparse/metis-5.1.0 CACHE PATH "Source directory of METIS")

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
  add_subdirectory("${METIS_DIR}" "metis") ## important part for building metis from its src files

  # extract METIS version string from metis.h header
  set(_METIS_VERSION_HEADER ${METIS_DIR}/include/metis.h)
  file(READ ${_METIS_VERSION_HEADER} _METIS_VERSION_CONTENTS)
  string(REGEX REPLACE ".*#define METIS_VER_MAJOR[ \t]+([0-9]+).*" "\\1"
    METIS_VERSION_MAJOR "${_METIS_VERSION_CONTENTS}")
  string(REGEX REPLACE ".*#define METIS_VER_MINOR[ \t]+([0-9]+).*" "\\1"
    METIS_VERSION_MINOR "${_METIS_VERSION_CONTENTS}")
  string(REGEX REPLACE ".*#define METIS_VER_SUBMINOR[ \t]+([0-9]+).*" "\\1"
    METIS_VERSION_PATCH "${_METIS_VERSION_CONTENTS}")
  # combine in one variable later passed to generated cmake config file
  set(SuiteSparse_METIS_VERSION
    ${METIS_VERSION_MAJOR}.${METIS_VERSION_MINOR}.${METIS_VERSION_PATCH})
  message(STATUS "METIS: building with SuiteSparse_METIS_VERSION '${SuiteSparse_METIS_VERSION}'")
  # some sanity checks if we managed to extract METIS version numbers
  if ("${METIS_VERSION_MAJOR}" STREQUAL "")
    message(FATAL_ERROR "METIS: error extracting METIS_VER_MAJOR from metis.h file at '${_METIS_VERSION_HEADER}'")
  endif()
  if ("${METIS_VERSION_MINOR}" STREQUAL "")
    message(FATAL_ERROR "METIS: error extracting METIS_VER_MINOR from metis.h file at '${_METIS_VERSION_HEADER}'")
  endif()
  if ("${METIS_VERSION_PATCH}" STREQUAL "")
    message(FATAL_ERROR "METIS: error extracting METIS_VER_PATCH from metis.h file at '${_METIS_VERSION_HEADER}'")
  endif()

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
	if(${CUDA_FOUND})
		include_directories(${CUDA_INCLUDE_DIRS})
		include_directories(${SuiteSparse_GPUQREngine_INCLUDE})
		include_directories(${SuiteSparse_GPURuntime_INCLUDE})
		CUDA_ADD_LIBRARY(${targetName} ${srcsList} ${headersList})
	else(${CUDA_FOUND})
		add_library(${targetName} ${srcsList} ${headersList})
	endif(${CUDA_FOUND})
	set_target_properties(${targetName} PROPERTIES
		OUTPUT_NAME ${SP_LIB_PREFIX}${targetName}
	)

	target_link_libraries(${targetName}
			 ${dsl_TARGET_PUBLIC_LINK} suitesparseconfig ## suitesparseconfig is used for every projects (embedded into cmake build)
		 ${dsl_TARGET_PRIVATE_LINK}	## external required libs
	)

	if (WITH_TBB)
		target_link_libraries(${targetName} ${dsl_TARGET_PRIVATE_LINK} tbb)
		target_compile_definitions(${targetName} PRIVATE HAVE_TBB)
	endif()

	install_suitesparse_project(${targetName} "${headersList}")
endmacro()

# Example of usage:
#  REMOVE_MATCHING_FILES_FROM_LIST(".*_LIN.cpp" my_srcs)
macro(REMOVE_MATCHING_FILES_FROM_LIST match_expr lst_files)
	set(lst_files_aux "")
	foreach(FIL ${${lst_files}})
		if(NOT ${FIL} MATCHES "${match_expr}")
			set(lst_files_aux "${lst_files_aux}" "${FIL}")
		endif(NOT ${FIL} MATCHES "${match_expr}")
	endforeach(FIL)
	set(${lst_files} ${lst_files_aux})
endmacro(REMOVE_MATCHING_FILES_FROM_LIST)

if(WITH_CUDA)
	find_package(cuda)
	if(${CUDA_FOUND})
		add_definitions(-DGPU_BLAS)
	endif(${CUDA_FOUND})
endif()

if (WITH_OPENBLAS)
  # Starting with OpenBLAS v0.3.21 a f2c-converted copy of LAPACK 3.9.0
  # is included and used if no fortran compiler is available. This
  # means we can compile OpenBLAS to provide BLAS and LAPACK functionality
  # with a regular C++ compiler like MSVC or GCC. This includes compiling
  # everything as a static library. If that library is later used to compile
  # an executable the executable can run without any external dependencies
  # (like fortran runtimes or lapack dlls)
  # When building OpenBLAS be sure to use 'BUILD_WITHOUT_LAPACK=NO' and
  # mabye with 'NOFORTAN=1' to get a pure C++ OpenBLAS library (with the
  # benefits described above)
  hunter_add_package(OpenBLAS)
  find_package(OpenBLAS CONFIG REQUIRED)
  message(STATUS "found OpenBLAS config file. Linking target OpenBLAS::OpenBLAS")
  set(SuiteSparse_LINKER_LAPACK_BLAS_LIBS OpenBLAS::OpenBLAS)
  set(BLA_VENDOR OpenBLAS)
elseif (WITH_MKL)
  hunter_add_package(mkl)
  set(BLA_VENDOR "Intel10_64lp")
  find_package(BLAS REQUIRED)
  find_package(LAPACK REQUIRED)
  set(SuiteSparse_LINKER_LAPACK_BLAS_LIBS ${LAPACK_LIBRARIES} ${BLAS_LIBRARIES})
  # for suitesparse-config file set method used to find LAPACK (and BLAS)
  set(SuiteSparse_LAPACK_used_CONFIG NO)
else()
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
endif()

if(BUILD_METIS)
	set(SuiteSparse_LINKER_METIS_LIBS "metis")
	## namespaced library target for config
	set(SuiteSparse_EXPORTED_METIS_LIBS "SuiteSparse::metis")
else()
	set(SuiteSparse_LINKER_METIS_LIBS "")
	set(SuiteSparse_EXPORTED_METIS_LIBS "")
endif()

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

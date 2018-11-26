PROJECT(SuiteSparse)

# Set optimized building:
IF(CMAKE_COMPILER_IS_GNUCXX AND NOT CMAKE_BUILD_TYPE MATCHES "Debug")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")
	# only optimize for native processer when NOT cross compiling
	if(NOT CMAKE_CROSSCOMPILING)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mtune=native")
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mtune=native")
	endif(NOT CMAKE_CROSSCOMPILING)
ENDIF(CMAKE_COMPILER_IS_GNUCXX AND NOT CMAKE_BUILD_TYPE MATCHES "Debug")

# Global flags:
IF (BUILD_METIS)
	INCLUDE_DIRECTORIES("${METIS_SOURCE_DIR}/include")
ELSE (BUILD_METIS)
	ADD_DEFINITIONS(-DNPARTITION)
ENDIF ( BUILD_METIS)

# Disable COMPLEX numbers: disable it by default, since it causes problems in some platforms.
SET(HAVE_COMPLEX OFF CACHE BOOL "Enables building SuiteSparse with complex numbers (disabled by default to avoid problems in some platforms)")
IF (NOT HAVE_COMPLEX)
	ADD_DEFINITIONS(-DNCOMPLEX)
ENDIF (NOT HAVE_COMPLEX)

# Used even for MSVC, so blas function names have the final "_"
if (MSVC)
	ADD_DEFINITIONS(-D__MINGW32__)
endif(MSVC)


include_directories(".")  # Needed for "SourceWrappers/*.c" files

set(suitesparseconfig_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse_config) # Needed by all subprojects

if(WITH_CUDA)
	set(SUBPROJECTS_TO_ADD
		${SUBPROJECTS_TO_ADD}
		SuiteSparse_GPURuntime
		GPUQREngine	
		)
endif()

set(SUBPROJECTS_TO_ADD
    ${SUBPROJECTS_TO_ADD} 
	SuiteSparse_config
	AMD
	BTF
	CAMD
	CCOLAMD
	COLAMD
	CHOLMOD
	CXSparse
	KLU
	LDL
	UMFPACK
	SPQR
	#CACHE STRING "list of all sub-directories to add to cmake build"
)

foreach(subdir ${SUBPROJECTS_TO_ADD})
	add_subdirectory(${subdir})
endforeach()

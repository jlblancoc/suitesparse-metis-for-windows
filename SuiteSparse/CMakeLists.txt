PROJECT(SuiteSparse)

# Set optimized building:
IF(CMAKE_COMPILER_IS_GNUCXX AND NOT CMAKE_BUILD_TYPE MATCHES "Debug")
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -mtune=native")
	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -mtune=native")
ENDIF(CMAKE_COMPILER_IS_GNUCXX AND NOT CMAKE_BUILD_TYPE MATCHES "Debug")

# Global flags:
IF (BUILD_METIS)
	INCLUDE_DIRECTORIES("${METIS_SOURCE_DIR}/include")
ELSE (BUILD_METIS)
	ADD_DEFINITIONS(-DNPARTITION)
ENDIF ( BUILD_METIS)

# Used even for MSVC, so blas function names have the final "_"
if (MSVC)
	ADD_DEFINITIONS(-D__MINGW32__)
endif(MSVC)


include_directories(".")  # Needed for "SourceWrappers/*.c" files

set(suitesparseconfig_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse_config) # Needed by all subprojects


set(SUBPROJECTS_TO_ADD 
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
	CACHE STRING "list of all sub-directories to add to cmake build"
)
foreach(subdir ${SUBPROJECTS_TO_ADD})
	add_subdirectory(${subdir})
endforeach()

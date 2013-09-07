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

#add_subdirectory(SuiteSparse_config)
#add_subdirectory(AMD)
#add_subdirectory(CAMD)
#add_subdirectory(CCOLAMD)
#add_subdirectory(COLAMD)
#add_subdirectory(CHOLMOD)
#add_subdirectory(UMFPACK)

SET(SUITESPARSE_INCLUDE_DIRS
	${SuiteSparse_SOURCE_DIR}/SuiteSparse_config
	${SuiteSparse_SOURCE_DIR}/AMD/Include
	${SuiteSparse_SOURCE_DIR}/CAMD/Include
	${SuiteSparse_SOURCE_DIR}/COLAMD/Include
	${SuiteSparse_SOURCE_DIR}/CCOLAMD/Include
	${SuiteSparse_SOURCE_DIR}/CHOLMOD/Include
	${SuiteSparse_SOURCE_DIR}/UMFPACK/Include
	${SuiteSparse_SOURCE_DIR}/BTF/Include
	${SuiteSparse_SOURCE_DIR}/KLU/Include
	CACHE INTERNAL "")

include_directories(${SUITESPARSE_INCLUDE_DIRS})

FILE(GLOB LIBHDRS_AMD "AMD/Include/*.h")
FILE(GLOB LIBSRCS_AMD "AMD/SourceWrappers/*.c")

FILE(GLOB LIBHDRS_CAMD "CAMD/Include/*.h")
FILE(GLOB LIBSRCS_CAMD "CAMD/SourceWrappers/*.c")

FILE(GLOB LIBHDRS_COLAMD "COLAMD/Include/*.h")
FILE(GLOB LIBSRCS_COLAMD "COLAMD/SourceWrappers/*.c")

FILE(GLOB LIBHDRS_CCOLAMD "CCOLAMD/Include/*.h")
FILE(GLOB LIBSRCS_CCOLAMD "CCOLAMD/SourceWrappers/*.c")

FILE(GLOB LIBHDRS_CHOLMOD "CHOLMOD/Include/*.h")
FILE(GLOB LIBSRCS_CHOLMOD "CHOLMOD/SourceWrappers/*.c")

FILE(GLOB LIBHDRS_UMFPACK "UMFPACK/Include/*.h")
FILE(GLOB LIBSRCS_UMFPACK "UMFPACK/SourceWrappers/*.c")

FILE(GLOB LIBHDRS_BTF "BTF/Include/*.h")
FILE(GLOB LIBSRCS_BTF "BTF/SourceWrappers/*.c")

FILE(GLOB LIBHDRS_KLU "KLU/Include/*.h")
FILE(GLOB LIBSRCS_KLU "KLU/SourceWrappers/*.c")

ADD_LIBRARY(suitesparse
	# ---
	SuiteSparse_config/SuiteSparse_config.c
	SuiteSparse_config/SuiteSparse_config.h
	# ---
	${LIBHDRS_AMD} ${LIBSRCS_AMD}
	${LIBHDRS_CAMD} ${LIBSRCS_CAMD}
	${LIBHDRS_COLAMD} ${LIBSRCS_COLAMD}
	${LIBHDRS_CCOLAMD} ${LIBSRCS_CCOLAMD}
	${LIBHDRS_CHOLMOD} ${LIBSRCS_CHOLMOD}
	${LIBHDRS_UMFPACK} ${LIBSRCS_UMFPACK}
	${LIBHDRS_BTF} ${LIBSRCS_BTF}
	${LIBHDRS_KLU} ${LIBSRCS_KLU}
	)
	
IF (BUILD_METIS)
	add_dependencies(suitesparse metis)
ENDIF (BUILD_METIS)

add_subdirectory(SPQR)
add_subdirectory(LDL)


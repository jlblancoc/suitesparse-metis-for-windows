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

set(SuiteSparse_config_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse_config)

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

set(SUBPROJECTS_TO_ADD 
	SuiteSparse_config
	AMD
	CAMD
	CCOLAMD
	COLAMD
	CHOLMOD
	UMFPACK
	CACHE STRING "list of all sub-directories to add to cmake build"
)
foreach(subdir ${SUBPROJECTS_TO_ADD})
	add_subdirectory(${subdir})
endforeach()

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

set(SUITESPARSE_HEADERS SuiteSparse_config/SuiteSparse_config.h
	${LIBHDRS_AMD}
	${LIBHDRS_CAMD}
	${LIBHDRS_COLAMD}
	${LIBHDRS_CCOLAMD}
	${LIBHDRS_CHOLMOD}
	${LIBHDRS_UMFPACK}
	${LIBHDRS_BTF}
	${LIBHDRS_KLU}
)
set(SUITESPARSE_SOURCES SuiteSparse_config/SuiteSparse_config.c
	${LIBSRCS_AMD}
	${LIBSRCS_CAMD}
	${LIBSRCS_COLAMD}
	${LIBSRCS_CCOLAMD}
	${LIBSRCS_CHOLMOD}
	${LIBSRCS_UMFPACK}
	${LIBSRCS_BTF}
	${LIBSRCS_KLU}
)

ADD_LIBRARY(suitesparse ${SUITESPARSE_HEADERS} ${SUITESPARSE_SOURCES})

if(BUILD_SHARED_LIBS)
	target_link_libraries(suitesparse SuiteSparse_config CHOLMOD AMD CAMD COLAMD CCOLAMD ${SuiteSparse_LINKER_LIBS} UMFPACK)
endif()

IF (BUILD_METIS)
	add_dependencies(suitesparse metis)
ENDIF (BUILD_METIS)

## prepare install for suitesparse target
install_suitesparse_project(suitesparse "${SUITESPARSE_HEADERS}")

#add_subdirectory(SPQR)
#add_subdirectory(LDL)

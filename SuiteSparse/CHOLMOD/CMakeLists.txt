PROJECT(CHOLMOD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${CAMD_SOURCE_DIR}/Include")
include_directories("${COLAMD_SOURCE_DIR}/Include")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

# Headers:
include_directories("${CHOLMOD_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${CHOLMOD_SOURCE_DIR}/Include/*.h")

FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(CHOLMOD ${LIBHDRS} ${LIBSRCS})
ADD_DEPENDENCIES(CHOLMOD 
	SuiteSparse_config AMD CAMD COLAMD CCOLAMD)

IF (BUILD_METIS)
	ADD_DEPENDENCIES(CHOLMOD metis)
ENDIF (BUILD_METIS)

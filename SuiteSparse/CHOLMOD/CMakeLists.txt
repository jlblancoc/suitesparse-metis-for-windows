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

declare_suitesparse_library(cholmod "${LIBSRCS}" "${LIBHDRS}" )

target_link_libraries(cholmod SuiteSparse_config amd camd colamd ccolamd ${SuiteSparse_LINKER_LIBS})

IF (BUILD_METIS)
	target_link_libraries(cholmod metis)
ENDIF (BUILD_METIS)


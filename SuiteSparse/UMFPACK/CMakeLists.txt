PROJECT(UMFPACK)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${CHOLMOD_SOURCE_DIR}/Include")

# Headers:
include_directories("${UMFPACK_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${UMFPACK_SOURCE_DIR}/Include/*.h")
FILE(GLOB LIBSRCS "${UMFPACK_SOURCE_DIR}/SourceWrappers/*.c")

declare_suitesparse_library(umfpack "${LIBSRCS}" "${LIBHDRS}" )

target_link_libraries(umfpack SuiteSparse_config cholmod amd camd colamd ccolamd ${SuiteSparse_LINKER_LIBS})


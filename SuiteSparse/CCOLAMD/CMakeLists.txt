PROJECT(CCOLAMD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(ccolamd "${LIBSRCS}" "${LIBHDRS}" )


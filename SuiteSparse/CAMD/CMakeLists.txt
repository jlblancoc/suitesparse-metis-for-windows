PROJECT(CAMD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${CAMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(camd "${LIBSRCS}" "${LIBHDRS}" )


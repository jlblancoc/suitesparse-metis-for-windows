project(COLAMD)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${COLAMD_SOURCE_DIR}/Include")

file(GLOB LIBHDRS "Include/*.h")
file(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(colamd "${LIBSRCS}" "${LIBHDRS}" )

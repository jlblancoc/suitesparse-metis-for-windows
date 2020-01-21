project(CCOLAMD)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

file(GLOB LIBHDRS "Include/*.h")
file(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(ccolamd "${LIBSRCS}" "${LIBHDRS}" )


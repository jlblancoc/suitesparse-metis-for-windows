PROJECT(BTF)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${BTF_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(btf "${LIBSRCS}" "${LIBHDRS}" )

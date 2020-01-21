project(BTF)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${BTF_SOURCE_DIR}/Include")

file(GLOB LIBHDRS "Include/*.h")
file(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(btf "${LIBSRCS}" "${LIBHDRS}" )

PROJECT(KLU)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${KLU_SOURCE_DIR}/Include")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${COLAMD_SOURCE_DIR}/Include")
include_directories("${BTF_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(klu "${LIBSRCS}" "${LIBHDRS}" )

target_link_libraries(klu amd colamd btf)

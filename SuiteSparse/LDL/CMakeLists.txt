PROJECT(LDL)

# Deps:
include_directories("${SuiteSparse_config_SOURCE_DIR}")

# Headers:
include_directories("${LDL_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${LDL_SOURCE_DIR}/Include/*.h")
FILE(GLOB LIBSRCS "${LDL_SOURCE_DIR}/SourceWrappers/*.c")

declare_suitesparse_library(ldl "${LIBSRCS}" "${LIBHDRS}" )

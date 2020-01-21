project(LDL)

# Deps:
include_directories("${suitesparseconfig_SOURCE_DIR}")

# Headers:
include_directories("${LDL_SOURCE_DIR}/Include")
file(GLOB LIBHDRS "${LDL_SOURCE_DIR}/Include/*.h")
file(GLOB LIBSRCS "${LDL_SOURCE_DIR}/SourceWrappers/*.c")

declare_suitesparse_library(ldl "${LIBSRCS}" "${LIBHDRS}" )

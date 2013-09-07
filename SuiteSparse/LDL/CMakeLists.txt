PROJECT(LDL)

# Deps:
#include_directories("${SuiteSparse_config_SOURCE_DIR}")

# Headers:
include_directories("${LDL_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${LDL_SOURCE_DIR}/Include/*.h")
FILE(GLOB LIBSRCS "${LDL_SOURCE_DIR}/SourceWrappers/*.c")

ADD_LIBRARY(LDL ${LIBHDRS} ${LIBSRCS})
ADD_DEPENDENCIES(LDL SuiteSparse_config)

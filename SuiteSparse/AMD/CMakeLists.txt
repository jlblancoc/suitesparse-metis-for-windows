PROJECT(AMD)

include_directories("${AMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(AMD ${LIBHDRS} ${LIBSRCS})
ADD_DEPENDENCIES(AMD SuiteSparse_config)


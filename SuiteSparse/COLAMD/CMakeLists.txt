PROJECT(COLAMD)

include_directories("${COLAMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(COLAMD ${LIBHDRS} ${LIBSRCS})
ADD_DEPENDENCIES(COLAMD SuiteSparse_config)



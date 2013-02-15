PROJECT(CAMD)

include_directories("${CAMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(CAMD ${LIBHDRS} ${LIBSRCS})
ADD_DEPENDENCIES(CAMD SuiteSparse_config)


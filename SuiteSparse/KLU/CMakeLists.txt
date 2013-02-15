PROJECT(KLU)

include_directories("${KLU_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(KLU ${LIBHDRS} ${LIBSRCS})
ADD_DEPENDENCIES(KLU SuiteSparse_config)


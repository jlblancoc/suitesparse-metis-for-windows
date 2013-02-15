PROJECT(BTF)

include_directories("${BTF_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(BTF ${LIBHDRS} ${LIBSRCS})
ADD_DEPENDENCIES(BTF SuiteSparse_config)


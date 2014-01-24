PROJECT(COLAMD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${COLAMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(COLAMD ${LIBHDRS} ${LIBSRCS})

if(BUILD_SHARED_LIBS)
	target_link_libraries(COLAMD SuiteSparse_config)
else()
	ADD_DEPENDENCIES(COLAMD SuiteSparse_config)
endif()

install_suitesparse_project(COLAMD "${LIBHDRS}")

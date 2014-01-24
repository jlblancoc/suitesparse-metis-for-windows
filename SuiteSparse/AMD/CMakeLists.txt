PROJECT(AMD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(AMD ${LIBHDRS} ${LIBSRCS})

if(BUILD_SHARED_LIBS)
	target_link_libraries(AMD SuiteSparse_config)
else()
	ADD_DEPENDENCIES(AMD SuiteSparse_config)
endif()

install_suitesparse_project(AMD "${LIBHDRS}")
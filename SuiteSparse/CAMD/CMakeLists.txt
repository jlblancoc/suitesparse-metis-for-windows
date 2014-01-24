PROJECT(CAMD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${CAMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(CAMD ${LIBHDRS} ${LIBSRCS})

if(BUILD_SHARED_LIBS)
	target_link_libraries(CAMD SuiteSparse_config)
else()
	ADD_DEPENDENCIES(CAMD SuiteSparse_config)
endif()

install_suitesparse_project(CAMD "${LIBHDRS}")
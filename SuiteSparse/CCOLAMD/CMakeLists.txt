PROJECT(CCOLAMD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "SourceWrappers/*.c")

ADD_LIBRARY(CCOLAMD ${LIBHDRS} ${LIBSRCS})

if(BUILD_SHARED_LIBS)
	target_link_libraries(CCOLAMD SuiteSparse_config)
else()
	ADD_DEPENDENCIES(CCOLAMD SuiteSparse_config)
endif()

install_suitesparse_project(CCOLAMD "${LIBHDRS}")
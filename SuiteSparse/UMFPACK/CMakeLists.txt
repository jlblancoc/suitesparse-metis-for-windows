PROJECT(UMFPACK)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${CHOLMOD_SOURCE_DIR}/Include")

# Headers:
include_directories("${UMFPACK_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${UMFPACK_SOURCE_DIR}/Include/*.h")
FILE(GLOB LIBSRCS "${UMFPACK_SOURCE_DIR}/SourceWrappers/*.c")

ADD_LIBRARY(UMFPACK ${LIBHDRS} ${LIBSRCS})

if(BUILD_SHARED_LIBS)
	target_link_libraries(UMFPACK SuiteSparse_config CHOLMOD AMD CAMD COLAMD CCOLAMD ${SuiteSparse_LINKER_LIBS})
else()
	ADD_DEPENDENCIES(UMFPACK  SuiteSparse_config CHOLMOD)
endif()

install_suitesparse_project(UMFPACK "${LIBHDRS}")
PROJECT(CHOLMOD)

include_directories("${SuiteSparse_config_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${CAMD_SOURCE_DIR}/Include")
include_directories("${COLAMD_SOURCE_DIR}/Include")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

# Headers:
include_directories("${CHOLMOD_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${CHOLMOD_SOURCE_DIR}/Include/*.h")

FILE(GLOB LIBSRCS "SourceWrappers/*.c")

declare_suitesparse_library(cholmod "${LIBSRCS}" "${LIBHDRS}" )

if(BUILD_SHARED_LIBS)
	target_link_libraries(cholmod SuiteSparse_config amd camd colamd ccolamd ${SuiteSparse_LINKER_LIBS})
else()
	ADD_DEPENDENCIES(cholmod 
		SuiteSparse_config amd camd colamd ccolamd)
endif()

IF (BUILD_METIS)
	if(BUILD_SHARED_LIBS)
		target_link_libraries(cholmod metis)
	else()
		ADD_DEPENDENCIES(cholmod metis)
	endif()
ENDIF (BUILD_METIS)


PROJECT(CHOLMOD)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${CAMD_SOURCE_DIR}/Include")
include_directories("${COLAMD_SOURCE_DIR}/Include")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

# Headers:
include_directories("${CHOLMOD_SOURCE_DIR}/Include")
FILE(GLOB LIBHDRS "${CHOLMOD_SOURCE_DIR}/Include/*.h")

FILE(GLOB LIBSRCS "SourceWrappers/*.c" "GPU/*.cu")

declare_suitesparse_library(cholmod "${LIBSRCS}" "${LIBHDRS}"
	TARGET_PRIVATE_LINK	${SuiteSparse_LINKER_LAPACK_BLAS_LIBS}
	TARGET_PUBLIC_LINK 	${SuiteSparse_LINKER_METIS_LIBS} amd camd colamd ccolamd
)

if(WITH_CUDA)
	target_link_libraries(cholmod ${CUDA_LIBRARIES} ${CUDA_CUBLAS_LIBRARIES})
endif(WITH_CUDA)

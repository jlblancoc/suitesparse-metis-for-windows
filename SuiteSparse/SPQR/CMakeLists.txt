project(SPQR)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${SPQR_SOURCE_DIR}/Include")
include_directories("${CHOLMOD_SOURCE_DIR}/Include")

file(GLOB LIBHDRS "Include/*.h*") # .h & .hpp
set(LIBSRCS 
	Source/spqr_rmap.cpp
	Source/SuiteSparseQR_C.cpp
	Source/SuiteSparseQR_expert.cpp
	Source/spqr_parallel.cpp
	Source/spqr_kernel.cpp
	Source/spqr_analyze.cpp
	Source/spqr_assemble.cpp
	Source/spqr_cpack.cpp
	Source/spqr_csize.cpp
	Source/spqr_fcsize.cpp
	Source/spqr_debug.cpp
	Source/spqr_front.cpp
	Source/spqr_factorize.cpp
	Source/spqr_freenum.cpp
	Source/spqr_freesym.cpp
	Source/spqr_freefac.cpp
	Source/spqr_fsize.cpp
	Source/spqr_maxcolnorm.cpp
	Source/spqr_rconvert.cpp
	Source/spqr_rcount.cpp
	Source/spqr_rhpack.cpp
	Source/spqr_rsolve.cpp
	Source/spqr_stranspose1.cpp
	Source/spqr_stranspose2.cpp
	Source/spqr_hpinv.cpp
	Source/spqr_1fixed.cpp
	Source/spqr_1colamd.cpp
	Source/SuiteSparseQR.cpp
	Source/spqr_1factor.cpp
	Source/spqr_cumsum.cpp
	Source/spqr_shift.cpp
	Source/spqr_happly.cpp
	Source/spqr_panel.cpp
	Source/spqr_happly_work.cpp
	Source/SuiteSparseQR_qmult.cpp
	Source/spqr_trapezoidal.cpp
	Source/spqr_larftb.cpp
	Source/spqr_append.cpp
	Source/spqr_type.cpp
	Source/spqr_tol.cpp
	SPQRGPU/spqrgpu_buildAssemblyMaps.cpp
	SPQRGPU/spqrgpu_computeFrontStaging.cpp
	SPQRGPU/spqrgpu_kernel.cpp
)

declare_suitesparse_library(spqr "${LIBSRCS}" "${LIBHDRS}"
	TARGET_PRIVATE_LINK	${SuiteSparse_LINKER_LAPACK_BLAS_LIBS}
	TARGET_PUBLIC_LINK 	camd ccolamd cholmod
)

if(WITH_CUDA)
	target_link_libraries(spqr GPUQREngine ${CUDA_LIBRARIES} ${CUDA_CUBLAS_LIBRARIES})
endif(WITH_CUDA)

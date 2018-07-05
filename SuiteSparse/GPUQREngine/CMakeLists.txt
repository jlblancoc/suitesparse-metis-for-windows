PROJECT(GPUQREngine)

include_directories("${suitesparseconfig_SOURCE_DIR}")
INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}/Include")
INCLUDE_DIRECTORIES(${SuiteSparse_GPURuntime_INCLUDE})
FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "Source/*.cpp" "Source/*/*.cpp" "Source/*.cu" "Include/*.cu")

#CUDA_ADD_LIBRARY(GPUQREngine ${LIBHDRS} ${LIBSRCS})
declare_suitesparse_library(GPUQREngine "${LIBSRCS}" "${LIBHDRS}")
SET(SuiteSparse_GPUQREngine_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/Include" PARENT_SCOPE)
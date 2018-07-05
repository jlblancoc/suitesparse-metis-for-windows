PROJECT("SuiteSparse_GPURuntime")


FILE(GLOB LIBHDRS "Include/*.hpp")
FILE(GLOB LIBSRCS "Source/*.cpp")
INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}/Include")

SET(SuiteSparse_GPURuntime_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/Include" PARENT_SCOPE)
INCLUDE_DIRECTORIES(${CUDA_INCLUDE_DIRS})
include_directories("${suitesparseconfig_SOURCE_DIR}")
declare_suitesparse_library(SuiteSparse_GPURuntime "${LIBSRCS}" "${LIBHDRS}")

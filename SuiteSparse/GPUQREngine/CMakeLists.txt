PROJECT(GPUQREngine)

include_directories("${suitesparseconfig_SOURCE_DIR}")
INCLUDE_DIRECTORIES("${CMAKE_CURRENT_SOURCE_DIR}/Include")
INCLUDE_DIRECTORIES(${SuiteSparse_GPURuntime_INCLUDE})
FILE(GLOB LIBHDRS "Include/*.h")
FILE(GLOB LIBSRCS "Source/*.cpp" "Source/*.cu" "Include/*.cu" "Source/Scheduler/*.cpp" "Source/LLBundle/*.cpp" "Source/BucketList/*.cpp" "Source/TaskDescriptor/*.cpp")

CUDA_ADD_LIBRARY(GPUQREngine STATIC ${LIBHDRS} ${LIBSRCS})
#declare_suitesparse_library(GPUQREngine "${LIBSRCS}" "${LIBHDRS}")
SET(SuiteSparse_GPUQREngine_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/Include" PARENT_SCOPE)
target_link_libraries(GPUQREngine suitesparseconfig SuiteSparse_GPURuntime)
install_suitesparse_project(GPUQREngine "${LIBHDRS}")

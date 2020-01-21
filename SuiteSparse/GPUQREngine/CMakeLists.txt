project(GPUQREngine)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/Include")
include_directories(${SuiteSparse_GPURuntime_INCLUDE})
file(GLOB LIBHDRS "Include/*.h")
file(GLOB LIBSRCS "Source/*.cpp" "Source/*.cu" "Include/*.cu" "Source/Scheduler/*.cpp" "Source/LLBundle/*.cpp" "Source/BucketList/*.cpp" "Source/TaskDescriptor/*.cpp")

CUDA_ADD_LIBRARY(GPUQREngine STATIC ${LIBHDRS} ${LIBSRCS})
#declare_suitesparse_library(GPUQREngine "${LIBSRCS}" "${LIBHDRS}")
set(SuiteSparse_GPUQREngine_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/Include" PARENT_SCOPE)
target_link_libraries(GPUQREngine suitesparseconfig SuiteSparse_GPURuntime)
install_suitesparse_project(GPUQREngine "${LIBHDRS}")

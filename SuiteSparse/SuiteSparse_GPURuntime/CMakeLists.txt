project("SuiteSparse_GPURuntime")


file(GLOB LIBHDRS "Include/*.hpp")
file(GLOB LIBSRCS "Source/*.cpp")
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/Include")

set(SuiteSparse_GPURuntime_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/Include" PARENT_SCOPE)
find_package(CUDA REQUIRED)
include_directories(${CUDA_INCLUDE_DIRS})
include_directories("${suitesparseconfig_SOURCE_DIR}")
add_library(SuiteSparse_GPURuntime ${LIBHDRS} ${LIBSRCS})
target_link_libraries(SuiteSparse_GPURuntime suitesparseconfig ${CUDA_LIBRARIES})
install_suitesparse_project(SuiteSparse_GPURuntime "${LIBHDRS}")

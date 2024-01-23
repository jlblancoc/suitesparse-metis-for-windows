project(SuiteSparse)

# Set optimized building:
if(CMAKE_COMPILER_IS_GNUCXX AND NOT CMAKE_BUILD_TYPE MATCHES "Debug")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3")

    # only optimize for native processer when NOT cross compiling
    if(NOT CMAKE_CROSSCOMPILING)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mtune=native")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mtune=native")
    endif(NOT CMAKE_CROSSCOMPILING)
endif(CMAKE_COMPILER_IS_GNUCXX AND NOT CMAKE_BUILD_TYPE MATCHES "Debug")

# Global flags:
if(NOT BUILD_METIS)
    add_definitions(-DNPARTITION)
endif()

# Used even for MSVC, so blas function names have the final "_"
if(MSVC)
    add_definitions(-D__MINGW32__)
endif(MSVC)

include_directories(".") # Needed for "SourceWrappers/*.c" files

set(suitesparseconfig_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/SuiteSparse_config) # Needed by all subprojects

if(WITH_CUDA)
    set(SUBPROJECTS_TO_ADD
        ${SUBPROJECTS_TO_ADD}
        SuiteSparse_GPURuntime
        GPUQREngine
    )
endif()

set(SUBPROJECTS_TO_ADD
    ${SUBPROJECTS_TO_ADD}
    SuiteSparse_config
    AMD
    BTF
    CAMD
    CCOLAMD
    COLAMD
    CHOLMOD
    CXSparse
    KLU
    LDL
    UMFPACK
    SPQR
    # CACHE STRING "list of all sub-directories to add to cmake build"
)

foreach(subdir ${SUBPROJECTS_TO_ADD})
    add_subdirectory(${subdir})
endforeach()

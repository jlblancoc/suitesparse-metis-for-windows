project(CHOLMOD)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${AMD_SOURCE_DIR}/Include")
include_directories("${CAMD_SOURCE_DIR}/Include")
include_directories("${COLAMD_SOURCE_DIR}/Include")
include_directories("${CCOLAMD_SOURCE_DIR}/Include")

# Headers:
file(GLOB LIBHDRS "${CHOLMOD_SOURCE_DIR}/Include/*.h")

file(GLOB CHOLMOD_SOURCES
    "Check/cholmod_*.c"
    "Cholesky/cholmod_*.c"
    "Utility/cholmod_*.c"
    "MatrixOps/cholmod_*.c"
    "Modify/cholmod_*.c"
    "Partition/cholmod_*.c"
    "Supernodal/cholmod_*.c"
)

include(CheckTypeSize)
check_type_size("ssize_t" SSIZE_T)

if(NOT HAVE_SSIZE_T)
    # #include <sys/types.h> and ssize_t not defined (typically on Windows)
    add_compile_definitions(NO_SSIZE_T)
endif()

# METIS and the Partition module:
if(BUILD_METIS)
    # make IDXTYPEWIDTH configurable
    file(READ SuiteSparse_metis/include/metis.h metis_header)
    set(METIS_IDXTYPEWIDTH 64 CACHE STRING "Specifies the width of the elementary data type that will hold information about vertices and their adjacency lists.")
    string(REPLACE "#define IDXTYPEWIDTH 64" "#define IDXTYPEWIDTH ${METIS_IDXTYPEWIDTH}" metis_header "${metis_header}")
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/SuiteSparse_metis/include/metis.h" "${metis_header}")
    include_directories("${CMAKE_CURRENT_BINARY_DIR}") # include for modified metis.h
    include_directories("${CMAKE_CURRENT_BINARY_DIR}/SuiteSparse_metis/include")

    # includes to make metis-wrapper work
    include_directories("${CHOLMOD_SOURCE_DIR}")
    include_directories("${CHOLMOD_SOURCE_DIR}/SuiteSparse_metis/GKlib")

    # add metis-wrapper to compiled files
    set(LIBHDRS ${LIBHDRS} "${CHOLMOD_SOURCE_DIR}/Partition/cholmod_metis_wrapper.h")
    file(GLOB CHOLMOD_SOURCES_PARTITION "Partition/cholmod_*.c")
    list(APPEND CHOLMOD_SOURCES ${CHOLMOD_SOURCES_PARTITION})
else()
    add_compile_definitions(NPARTITION)
endif()

include_directories("${CHOLMOD_SOURCE_DIR}/Include")
declare_suitesparse_library(cholmod "${CHOLMOD_SOURCES}" "${LIBHDRS}"
    TARGET_PRIVATE_LINK ${SuiteSparse_LINKER_LAPACK_BLAS_LIBS}
    TARGET_PUBLIC_LINK amd camd colamd ccolamd
)

if(WITH_CUDA)
    target_link_libraries(cholmod ${CUDA_LIBRARIES} ${CUDA_CUBLAS_LIBRARIES})
endif(WITH_CUDA)

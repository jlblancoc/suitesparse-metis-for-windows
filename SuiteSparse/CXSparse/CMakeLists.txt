project(CXSparse)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${CXSparse_SOURCE_DIR}/Include")

file(GLOB LIBHDRS "Include/*.h")

# cs.h is configured by suitesparse-metis-for-windows to never have complex support
# so only add the non-complex files
# Do we have <complex.h> in this compiler?
# exclude functions that work on complex data types
file(GLOB CXSPARSE_SOURCES
    "Source/cs_a*.c"
    "Source/cs_chol*.c"
    "Source/cs_compress.c"
    "Source/cs_counts.c"
    "Source/cs_cumsum.c"
    "Source/cs_[d-z]*.c"
    "Source/cxsparse_version.c"
)
# in case one wants to have complex type support use the following glob,
# remove the NCOMPLEX define below and modify 'cs.h'
#file ( GLOB CXSPARSE_SOURCES "Source/*.c" )

declare_suitesparse_library(cxsparse "${CXSPARSE_SOURCES}" "${LIBHDRS}" )

# we never have complex support
target_compile_definitions(cxsparse PRIVATE NCOMPLEX)

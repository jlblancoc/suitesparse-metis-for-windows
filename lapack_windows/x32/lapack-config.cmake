# Compute locations from <prefix>/lib/cmake/lapack-<v>/<self>.cmake
get_filename_component(_LAPACK_SELF_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)

# Load lapack targets from the install tree if necessary.
set(_LAPACK_TARGET "blas")
if(_LAPACK_TARGET AND NOT TARGET "${_LAPACK_TARGET}")

# Create imported target blas
add_library(blas SHARED IMPORTED)

# Create imported target lapack
add_library(lapack SHARED IMPORTED)

# Compute the installation prefix relative to this file.
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "blas"
set_target_properties(blas PROPERTIES
  IMPORTED_IMPLIB "${_IMPORT_PREFIX}/libblas.lib"
  IMPORTED_LOCATION "${_IMPORT_PREFIX}/libblas.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS blas )
list(APPEND _IMPORT_CHECK_FILES_FOR_blas "${_IMPORT_PREFIX}/libblas.lib" "${_IMPORT_PREFIX}/libblas.dll" )

# Import target "lapack"
set_target_properties(lapack PROPERTIES
  IMPORTED_IMPLIB "${_IMPORT_PREFIX}/liblapack.lib"
  IMPORTED_LOCATION "${_IMPORT_PREFIX}/liblapack.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS lapack )
list(APPEND _IMPORT_CHECK_FILES_FOR_lapack "${_IMPORT_PREFIX}/liblapack.lib" "${_IMPORT_PREFIX}/liblapack.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)

endif()
unset(_LAPACK_TARGET)

# Hint for project building against lapack
set(LAPACK_Fortran_COMPILER_ID "GNU")

# Report the blas and lapack raw or imported libraries.
set(LAPACK_blas_LIBRARIES "blas")
set(LAPACK_lapack_LIBRARIES "lapack")
set(LAPACK_LIBRARIES ${LAPACK_blas_LIBRARIES} ${LAPACK_lapack_LIBRARIES})

unset(_LAPACK_SELF_DIR)

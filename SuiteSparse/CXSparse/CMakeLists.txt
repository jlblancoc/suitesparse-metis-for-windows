project(CXSparse)

include_directories("${suitesparseconfig_SOURCE_DIR}")
include_directories("${CXSparse_SOURCE_DIR}/Include")

file(GLOB LIBHDRS "Include/*.h")
file(GLOB LIBSRCS "SourceWrappers/*.c")

# Do we have <complex.h> in this compiler?
include (CheckIncludeFile)
CHECK_INCLUDE_FILE("complex.h" HAVE_COMPLEX_H)
if(NOT HAVE_COMPLEX_H)
	add_definitions(-DNCOMPLEX)

	# Remove *_ci and *_cl from the sources list:
	REMOVE_MATCHING_FILES_FROM_LIST(".*_ci.*" LIBSRCS)
	REMOVE_MATCHING_FILES_FROM_LIST(".*_cl.*" LIBSRCS)	
	# Remove cs_convert: We don't have any other choice, I'm afraid...
	REMOVE_MATCHING_FILES_FROM_LIST(".*cs_convert.*" LIBSRCS)	
endif(NOT HAVE_COMPLEX_H)

declare_suitesparse_library(cxsparse "${LIBSRCS}" "${LIBHDRS}" )


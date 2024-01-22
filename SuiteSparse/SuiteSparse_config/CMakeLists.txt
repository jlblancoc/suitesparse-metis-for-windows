project(suitesparseconfig)

include_directories("${suitesparseconfig_SOURCE_DIR}")

add_library(suitesparseconfig STATIC
	SuiteSparse_config.c
	SuiteSparse_config.h
	)

target_compile_definitions(suitesparseconfig PUBLIC NTIMER)
install_suitesparse_project(suitesparseconfig "SuiteSparse_config.h")


PROJECT(suitesparseconfig)

include_directories("${suitesparseconfig_SOURCE_DIR}")

ADD_LIBRARY(suitesparseconfig STATIC
	SuiteSparse_config.c
	SuiteSparse_config.h
	)

install_suitesparse_project(suitesparseconfig "SuiteSparse_config.h")


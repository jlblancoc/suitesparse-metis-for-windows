PROJECT(suitesparseconfig)

include_directories("${suitesparseconfig_SOURCE_DIR}")

ADD_LIBRARY(suitesparseconfig 
	SuiteSparse_config.c
	SuiteSparse_config.h
	)

install_suitesparse_project(suitesparseconfig "SuiteSparse_config.h")


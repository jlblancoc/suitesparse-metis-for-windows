PROJECT(SuiteSparse_config)

include_directories("${SuiteSparse_config_SOURCE_DIR}")

ADD_LIBRARY(SuiteSparse_config 
	SuiteSparse_config.c
	SuiteSparse_config.h
	)


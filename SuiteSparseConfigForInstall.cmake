##  SuiteSparseConfigForInstall.cmake.in
##
##  File which define the USE_SuiteSparse cmake variable for another project.
##  When cmake export a project cmake will generate an export file containing all the project's targets imported.
##  Here we just set the cmake variable (USE_SuiteSparse) pointing to the file which do the import SuiteSparse project stuff.
##
##  Usage for project which try to use SuiteSparse :
##  (1) Set your SuiteSparse_DIR to the dir containing this file.
##  (2) Then, in your CMakeLists.txt
##      find_package(SuiteSparse NO_MODULE) ## NO_MODULE is optional (to bypass the FindSuiteSparse.cmake is exist)
##      include(${USE_SuiteSparse}) ## see UseSuiteSparse.cmake for more infos (it does the include_directories)
##	(3) Then, in your target project you can use the SuiteSparse_LIBRARIES
##
## Created by jesnault (jerome.esnault@inria.fr) 2014-01-21
## Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21

get_filename_component(SuiteSparse_IMPORT_PREFIX 	"${CMAKE_CURRENT_LIST_FILE}" PATH)

## check which build system version we have to load (32 or 64 bits)
if(CMAKE_SIZEOF_VOID_P MATCHES "8")
  set(SuiteSparse_LIB_POSTFIX "64")## suffix for 32/64 inst dir placement
else()
  set(SuiteSparse_LIB_POSTFIX "" ) ## suffix for 32/64 inst dir placement
endif()

set(USE_SuiteSparse ${SuiteSparse_IMPORT_PREFIX}/UseSuiteSparse${SuiteSparse_LIB_POSTFIX}.cmake)

if(EXISTS ${USE_SuiteSparse})
	## do nothing, it's OK
else()
	message(SEND_ERROR "correct version of SuiteSparse not found :\nUSE_SuiteSparse=${USE_SuiteSparse}")
	set(SuiteSparse_FOUND OFF)
	set(SUITESPARSE_FOUND OFF)
endif()
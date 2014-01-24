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
set(USE_SuiteSparse ${SuiteSparse_IMPORT_PREFIX}/UseSuiteSparse.cmake)

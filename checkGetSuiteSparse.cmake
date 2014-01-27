## checkGetSuiteSparse.cmake
##
## This will check if SuiteSparse project already downloaded or not
## and try to auto download the last version if needed to the source dir.
##
## The SUITESPARSE_DL_LAST bool cached cmake variable (GUI) :
##    allow to auto download and install the last version of SuiteSparse.
##
## The SUITESPARSE_URL is the download link to use (must be public)
## The SUITESPARSE_ZIP is the destination (after extraction, will be removed)
##
## Created by jesnault (jerome.esnault@inria.fr) 2014-01-21
## Updated by jesnault (jerome.esnault@inria.fr) 2014-01-21

## try first with 7-Zip, and with standard cmake tar command otherwise
macro(SuiteSparse_unzip whichZipFile)
	find_program(7ZIP_CMD NAMES 7z DOC "7-zip executable" 
		PATHS 	"$ENV{PROGRAMFILES}/7-Zip"	"$ENV{PROGRAMFILES(x86)}/7-Zip"
				/usr/bin	/usr/local/bin
	)
	if(OFF)
		message(STATUS "unzip: please, wait until ${7ZIP_CMD} finished...")
		execute_process( 	COMMAND ${7ZIP_CMD} x ${whichZipFile} -y
							WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}	TIMEOUT 120
							RESULT_VARIABLE resVar OUTPUT_VARIABLE outVar ERROR_VARIABLE errVar
						)
		if(${resVar} MATCHES "0")
			message(STATUS "SuiteSparse just unziped in the source dir") ## OK
			set(SUITESPARSE_DL_LAST OFF CACHE BOOL "get the last version of suiteSparse" FORCE)
		else()
			message(WARNING "something wrong with ${7ZIP_CMD} command, redo or try to unzip by yourself...")
			message("unzip: outVar=${outVar}")
			message("unzip: errVar=${errVar}")
		endif()
	else()
		get_filename_component(zipFile ${whichZipFile} NAME)
		message(STATUS "unzip: please, wait until tar xzf ${whichZipFile} finished...")
		execute_process( 	COMMAND ${CMAKE_COMMAND} -E tar xzf ${zipFile}
							WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}	TIMEOUT 120
							RESULT_VARIABLE resVar OUTPUT_VARIABLE outVar ERROR_VARIABLE errVar
						)
		if(${resVar} MATCHES "0")
			message(STATUS "SuiteSparse just unziped in the source dir") ## OK
			set(SUITESPARSE_DL_LAST OFF CACHE BOOL "get the last version of suiteSparse" FORCE)
		else()
			message(WARNING "something wrong with cmake tar command, redo or try to unzip by yourself...")
			message("unzip: outVar=${outVar}")
			message("unzip: errVar=${errVar}")
			message("Or try to get 7zip (http://www.7-zip.org/download.html) to unzip the downloaded dir.")
			set(7ZIP_CMD "" CACHE FILEPATH "7-zip executable")
		endif()
	endif()
endmacro()

## Try to auto download and/or auto unzip the Win3rdParty
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/SuiteSparse/CHOLMOD/Include/cholmod.h" AND NOT SUITESPARSE_DL_LAST)
	message(STATUS "Apparently, SuiteSparse project is not yet download and extract here. Let me try to do it for you...")
	set(SUITESPARSE_DL_LAST ON CACHE BOOL "get the last version of suiteSparse" FORCE)
else()
	set(SUITESPARSE_DL_LAST OFF CACHE BOOL "get the last version of suiteSparse")
endif()

if(SUITESPARSE_DL_LAST)
	
	set(SUITESPARSE_URL "http://www.cise.ufl.edu/research/sparse/SuiteSparse/current/SuiteSparse.tar.gz")
	set(SUITESPARSE_ZIP "${CMAKE_SOURCE_DIR}/SuiteSparse.tar.gz")
	if(SUITESPARSE_URL AND SUITESPARSE_ZIP)
	
		message(STATUS "try downloading...\n  src='${SUITESPARSE_URL}'\n  dst='${SUITESPARSE_ZIP}'\n  inactivity_timeout='15'")
		file(DOWNLOAD "${SUITESPARSE_URL}" "${SUITESPARSE_ZIP}" INACTIVITY_TIMEOUT 15 STATUS status SHOW_PROGRESS)
		list(GET status 0 numResult)
		if(${numResult} MATCHES "0")
			SuiteSparse_unzip("${SUITESPARSE_ZIP}")
		else()
			list(GET status 1 errMsg)
			message(WARNING "download ${SUITESPARSE_URL} to ${SUITESPARSE_ZIP} failed\n:${errMsg}")
			message(STATUS "Try to look inside ${SUITESPARSE_ZIP} if suitesparse zip file exist...")
		endif()
			
	endif()
	if(EXISTS "${SUITESPARSE_ZIP}")
		execute_process(COMMAND "${CMAKE_COMMAND}" -E remove "${SUITESPARSE_ZIP}")
	endif()
	
endif()
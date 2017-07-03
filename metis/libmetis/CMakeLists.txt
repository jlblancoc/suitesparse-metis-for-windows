# Add this directory for internal users.
include_directories(.)
# Find sources.
file(GLOB metis_sources *.c)
# Build libmetis.
add_library(metis ${METIS_LIBRARY_TYPE} ${GKlib_sources} ${metis_sources})
if(UNIX)
  target_link_libraries(metis m)
endif()

if(METIS_INSTALL)
  install(TARGETS metis
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION lib
    ARCHIVE DESTINATION lib)
endif()

## get CMAKE_INSTALL_BINDIR and CMAKE_INSTALL_LIBDIR
include(GNUInstallDirs)

				set_target_properties(metis PROPERTIES PUBLIC_HEADER "../include/metis.h")
				install(TARGETS metis ## this line is also the string pattern to check if the modification had already done
						EXPORT 	SuiteSparseTargets
						RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
						LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
						ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
						PUBLIC_HEADER DESTINATION include
				)


# make IDXTYPEWIDTH configurable
file(READ metis.h metis_header)
set(METIS_IDXTYPEWIDTH 64 CACHE STRING "Specifies the width of the elementary data type that will hold information about vertices and their adjacency lists.")
string(REPLACE "#define IDXTYPEWIDTH 64" "#define IDXTYPEWIDTH ${METIS_IDXTYPEWIDTH}" metis_header "${metis_header}")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/metis.h" "${metis_header}")

if(METIS_INSTALL)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/metis.h DESTINATION include)
endif()

set(point_source_srcs
  point_source_mod.F90
)
add_library(nexus_toolbox_point_sources ${point_source_srcs})
target_link_libraries(nexus_toolbox_point_sources PUBLIC nexus_toolbox_core)

# ESMF dependency
if(NOT DEFINED ESMF_FOUND)
  find_package(ESMF REQUIRED)
endif()
target_link_libraries(nexus_toolbox_point_sources PUBLIC ESMF)
set_target_properties(nexus_toolbox_point_sources PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

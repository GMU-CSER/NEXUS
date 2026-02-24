set(api_srcs
  nexus_toolbox_api_mod.F90
  nexus_toolbox_cap.F90
  subcanopy_interface_mod.F90
)
add_library(nexus_toolbox_api ${api_srcs})
target_link_libraries(nexus_toolbox_api PUBLIC nexus_toolbox_core nexus_toolbox_megan nexus_toolbox_canopy_bioemi)
set_target_properties(nexus_toolbox_api PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

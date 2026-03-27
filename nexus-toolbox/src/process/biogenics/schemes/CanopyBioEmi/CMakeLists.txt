set(canopy_bioemi_srcs
  canopy_app_stubs.F90
  canopy_bioemi_mod.F90
  canopy_bioemi_wrapper_mod.F90
)
add_library(nexus_toolbox_canopy_bioemi ${canopy_bioemi_srcs})
target_link_libraries(nexus_toolbox_canopy_bioemi PUBLIC nexus_toolbox_core)
set_target_properties(nexus_toolbox_canopy_bioemi PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

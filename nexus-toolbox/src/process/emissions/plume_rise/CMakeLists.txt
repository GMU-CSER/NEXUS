set(plume_rise_srcs
  briggs_plume_rise_mod.F90
)
add_library(nexus_toolbox_plume_rise ${plume_rise_srcs})
target_link_libraries(nexus_toolbox_plume_rise PUBLIC nexus_toolbox_core)
set_target_properties(nexus_toolbox_plume_rise PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

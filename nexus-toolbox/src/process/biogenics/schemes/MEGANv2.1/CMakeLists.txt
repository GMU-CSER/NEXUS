set(megan_srcs
  megan_mod.F90
)
add_library(nexus_toolbox_megan ${megan_srcs})
target_link_libraries(nexus_toolbox_megan PUBLIC nexus_toolbox_core)
set_target_properties(nexus_toolbox_megan PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

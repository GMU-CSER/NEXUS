set(core_srcs
  precision_mod.F90
  constants.F90
  error_mod.F90
  VirtualColumn_Mod.F90
  ColumnInterface_Mod.F90
  ProcessInterface_Mod.F90
)
add_library(nexus_toolbox_core ${core_srcs})
target_include_directories(nexus_toolbox_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
# Set module output directory
set_target_properties(nexus_toolbox_core PROPERTIES Fortran_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/include)

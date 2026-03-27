!> \file subcanopy_interface_mod.F90
!! \brief Light interface for interfacing nexus-toolbox with subcanopy processes (e.g., canopy-app)
!!
module subcanopy_interface_mod
   use precision_mod
   use error_mod
   use VirtualColumn_Mod, only: VirtualColumnType

   implicit none
   private

   public :: SubcanopyProcessInterface

   !> \brief Abstract interface for subcanopy processes to follow a "light" pattern
   abstract interface
      subroutine subcanopy_run_interface(column, rc)
         import :: VirtualColumnType, precision_mod
         type(VirtualColumnType), intent(inout) :: column
         integer, intent(out) :: rc
      end subroutine subcanopy_run_interface
   end interface

   !> \brief Base type for light subcanopy wrappers
   type, abstract :: SubcanopyProcessInterface
      character(len=64) :: subcanopy_name = ''
   contains
      procedure(subcanopy_run_interface), deferred :: run_subcanopy
   end type SubcanopyProcessInterface

end module subcanopy_interface_mod

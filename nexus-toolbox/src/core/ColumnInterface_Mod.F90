!> \file ColumnInterface_Mod.F90
!! \brief Column interface for nexus-toolbox
!!
module ColumnInterface_Mod
   use precision_mod, only: fp
   use error_mod, only: CC_SUCCESS, CC_FAILURE
   use VirtualColumn_Mod, only: VirtualColumnType

   implicit none
   private

   public :: ColumnProcessorType

   !> \brief Column processor for managing virtual columns
   type :: ColumnProcessorType
      type(VirtualColumnType), allocatable :: columns(:)
      integer :: n_columns = 0
   contains
      procedure :: init => processor_init
      procedure :: cleanup => processor_cleanup
   end type ColumnProcessorType

contains

   subroutine processor_init(this, max_columns, rc)
      class(ColumnProcessorType), intent(inout) :: this
      integer, intent(in) :: max_columns
      integer, intent(out) :: rc
      allocate(this%columns(max_columns))
      this%n_columns = 0
      rc = CC_SUCCESS
   end subroutine processor_init

   subroutine processor_cleanup(this)
      class(ColumnProcessorType), intent(inout) :: this
      if (allocated(this%columns)) deallocate(this%columns)
      this%n_columns = 0
   end subroutine processor_cleanup

end module ColumnInterface_Mod

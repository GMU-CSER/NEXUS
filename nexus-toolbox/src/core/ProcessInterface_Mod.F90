!> \file ProcessInterface_Mod.F90
!! \brief Abstract base class interface for all atmospheric processes in nexus-toolbox
!!
module ProcessInterface_Mod
   use precision_mod, only: fp
   use error_mod
   use VirtualColumn_Mod, only: VirtualColumnType

   implicit none
   private

   public :: ProcessInterface
   public :: ColumnProcessInterface
   public :: StateManagerType

   !> \brief Dummy StateManagerType for interface compatibility
   type :: StateManagerType
      type(ErrorManagerType), pointer :: error_mgr => null()
   contains
      procedure :: get_error_manager => state_get_error_manager
   end type StateManagerType

   !> \brief Abstract base class for all atmospheric processes
   type, abstract :: ProcessInterface
      character(len=64) :: name = ''         !< Process name
      character(len=64) :: version = ''      !< Version string
      character(len=256) :: description = '' !< Process description
      logical :: is_initialized = .false.    !< Initialization status
      logical :: is_active = .false.         !< Active status
      real(fp) :: dt = 0.0_fp                !< Process timestep

   contains
      ! Required interface methods
      procedure(init_interface), deferred :: init
      procedure(run_interface), deferred :: run
      procedure(finalize_interface), deferred :: finalize

      ! Optional interface methods with default implementations
      procedure :: activate => process_activate
      procedure :: deactivate => process_deactivate
      procedure :: set_timestep => process_set_timestep
      procedure :: get_timestep => process_get_timestep
   end type ProcessInterface

   !> \brief Enhanced process interface specifically for column-based processing
   type, abstract, extends(ProcessInterface) :: ColumnProcessInterface
   contains
      ! Required column processing methods
      procedure(column_run_interface), deferred :: run_column
   end type ColumnProcessInterface

   ! Abstract interfaces
   abstract interface
      subroutine init_interface(this, container, rc)
         import :: ProcessInterface, StateManagerType
         class(ProcessInterface), intent(inout) :: this
         type(StateManagerType), intent(inout) :: container
         integer, intent(out) :: rc
      end subroutine

      subroutine run_interface(this, container, rc)
         import :: ProcessInterface, StateManagerType
         class(ProcessInterface), intent(inout) :: this
         type(StateManagerType), intent(inout) :: container
         integer, intent(out) :: rc
      end subroutine

      subroutine finalize_interface(this, rc)
         import :: ProcessInterface
         class(ProcessInterface), intent(inout) :: this
         integer, intent(out) :: rc
      end subroutine

      subroutine column_run_interface(this, column, container, rc)
         import :: ColumnProcessInterface, VirtualColumnType, StateManagerType
         class(ColumnProcessInterface), intent(inout) :: this
         type(VirtualColumnType), intent(inout) :: column
         type(StateManagerType), intent(inout) :: container
         integer, intent(out) :: rc
      end subroutine
   end interface

contains

   function state_get_error_manager(this) result(ptr)
      class(StateManagerType), intent(in) :: this
      type(ErrorManagerType), pointer :: ptr
      ptr => this%error_mgr
   end function state_get_error_manager

   subroutine process_activate(this)
      class(ProcessInterface), intent(inout) :: this
      this%is_active = .true.
      this%is_initialized = .true.
   end subroutine process_activate

   subroutine process_deactivate(this)
      class(ProcessInterface), intent(inout) :: this
      this%is_active = .false.
   end subroutine process_deactivate

   subroutine process_set_timestep(this, dt)
      class(ProcessInterface), intent(inout) :: this
      real(fp), intent(in) :: dt
      this%dt = dt
   end subroutine process_set_timestep

   function process_get_timestep(this) result(dt)
      class(ProcessInterface), intent(in) :: this
      real(fp) :: dt
      dt = this%dt
   end function process_get_timestep

end module ProcessInterface_Mod

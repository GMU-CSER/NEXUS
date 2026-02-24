!> \file canopy_bioemi_wrapper_mod.F90
!! \brief Wrapper for canopy-app biogenic emissions
!!
module canopy_bioemi_wrapper_mod
   use precision_mod
   use error_mod
   use VirtualColumn_Mod, only: VirtualColumnType
   use ProcessInterface_Mod, only: ColumnProcessInterface, StateManagerType
   use subcanopy_interface_mod

   implicit none
   private

   public :: CanopyBioEmiProcess

   type, extends(ColumnProcessInterface) :: CanopyBioEmiProcess
      ! Additional metadata if needed
   contains
      procedure :: init => canopy_bioemi_init
      procedure :: run => canopy_bioemi_run
      procedure :: finalize => canopy_bioemi_finalize
      procedure :: run_column => canopy_bioemi_run_column
   end type CanopyBioEmiProcess

contains

   subroutine canopy_bioemi_init(this, container, rc)
      class(CanopyBioEmiProcess), intent(inout) :: this
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc
      this%name = 'CanopyBioEmi'
      this%version = '1.0'
      this%description = 'Biogenic emissions from canopy-app'
      this%is_initialized = .true.
      this%is_active = .true.
      rc = CC_SUCCESS
   end subroutine canopy_bioemi_init

   subroutine canopy_bioemi_run(this, container, rc)
      class(CanopyBioEmiProcess), intent(inout) :: this
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc
      rc = CC_SUCCESS
   end subroutine canopy_bioemi_run

   subroutine canopy_bioemi_finalize(this, rc)
      class(CanopyBioEmiProcess), intent(inout) :: this
      integer, intent(out) :: rc
      rc = CC_SUCCESS
   end subroutine canopy_bioemi_finalize

   subroutine canopy_bioemi_run_column(this, column, container, rc)
      class(CanopyBioEmiProcess), intent(inout) :: this
      type(VirtualColumnType), intent(inout) :: column
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc

      ! This is the "light interface" call
      ! In a real scenario, this would call CANOPY_BIO from canopy-app
      print *, "CanopyBioEmi: Running subcanopy biogenic emissions..."

      ! Example of setting some output based on canopy-app logic
      if (column%nspec_emis >= 1) then
         column%emis_data(1, 1) = 2.0e-9_fp ! Dummy value representing canopy-app output
      endif

      rc = CC_SUCCESS
   end subroutine canopy_bioemi_run_column

end module canopy_bioemi_wrapper_mod

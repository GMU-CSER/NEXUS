!> \file nexus_toolbox_api_mod.F90
!! \brief High-level API for nexus-toolbox
!!
module nexus_toolbox_api_mod
   use precision_mod
   use error_mod
   use ProcessInterface_Mod, only: ProcessInterface, ColumnProcessInterface, StateManagerType
   use megan_mod, only: MeganProcess
   use canopy_bioemi_wrapper_mod, only: CanopyBioEmiProcess
   use point_source_mod, only: PointSourceBatchType

   implicit none
   private

   public :: nexus_toolbox_init
   public :: nexus_toolbox_run
   public :: nexus_toolbox_finalize

   type(MeganProcess), save, target :: megan
   type(CanopyBioEmiProcess), save, target :: canopy_bioemi
   type(PointSourceBatchType), save, target :: point_sources

contains

   subroutine nexus_toolbox_init(container, rc)
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc

      print *, "nexus-toolbox: Initializing..."
      call megan%init(container, rc)
      if (rc /= CC_SUCCESS) return

      call canopy_bioemi%init(container, rc)
      if (rc /= CC_SUCCESS) return

      print *, "nexus-toolbox: Initialized."
   end subroutine nexus_toolbox_init

   subroutine nexus_toolbox_run(container, rc)
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc

      rc = CC_SUCCESS
      if (megan%is_active) then
         call megan%run(container, rc)
      endif

      if (canopy_bioemi%is_active) then
         call canopy_bioemi%run(container, rc)
      endif
   end subroutine nexus_toolbox_run

   subroutine nexus_toolbox_finalize(rc)
      integer, intent(out) :: rc

      print *, "nexus-toolbox: Finalizing..."
      call megan%finalize(rc)
      call canopy_bioemi%finalize(rc)
      print *, "nexus-toolbox: Finalized."
   end subroutine nexus_toolbox_finalize

end module nexus_toolbox_api_mod

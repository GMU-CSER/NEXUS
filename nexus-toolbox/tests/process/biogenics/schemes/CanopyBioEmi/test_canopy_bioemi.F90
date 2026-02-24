!> \file test_canopy_bioemi.F90
!! \brief Unit test for CanopyBioEmi biogenic emissions scheme
!!
program test_canopy_bioemi
   use precision_mod
   use error_mod
   use VirtualColumn_Mod
   use ProcessInterface_Mod
   use canopy_bioemi_wrapper_mod

   implicit none

   type(CanopyBioEmiProcess) :: proc
   type(VirtualColumnType) :: column
   type(StateManagerType) :: container
   integer :: rc
   real(fp) :: actual_emis

   print *, "Running unit test for CanopyBioEmi..."

   ! Initialize process
   call proc%init(container, rc)
   if (rc /= CC_SUCCESS) then
      print *, "FAILED: CanopyBioEmi initialization"
      stop 1
   endif

   ! Initialize virtual column
   call column%init(1, 1, 1, 1, 1, 0.0_fp, 0.0_fp, 1.0_fp, rc)
   if (rc /= CC_SUCCESS) then
      print *, "FAILED: Column initialization"
      stop 1
   endif

   ! Run the process on the column
   call proc%run_column(column, container, rc)
   if (rc /= CC_SUCCESS) then
      print *, "FAILED: CanopyBioEmi run_column"
      stop 1
   endif

   ! Check results
   actual_emis = column%emis_data(1, 1)
   print *, "Actual emission from CanopyBioEmi: ", actual_emis

   if (actual_emis > 0.0_fp) then
      print *, "PASSED: CanopyBioEmi generated emissions"
   else
      print *, "FAILED: CanopyBioEmi generated zero emissions"
      stop 1
   endif

   ! Cleanup
   call column%cleanup()
   call proc%finalize(rc)

   print *, "Unit test test_canopy_bioemi PASSED"

end program test_canopy_bioemi

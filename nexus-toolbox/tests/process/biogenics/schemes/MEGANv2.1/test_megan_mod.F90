!> \file test_megan_mod.F90
!! \brief Unit test for MEGANv2.1 biogenic emissions scheme
!!
program test_megan_mod
   use precision_mod
   use error_mod
   use VirtualColumn_Mod
   use ProcessInterface_Mod
   use megan_mod

   implicit none

   type(MeganProcess) :: megan
   type(VirtualColumnType) :: column
   type(StateManagerType) :: container
   integer :: rc
   real(fp) :: expected_emis, actual_emis

   print *, "Running unit test for MEGANv2.1..."

   ! Initialize process
   call megan%init(container, rc)
   if (rc /= CC_SUCCESS) then
      print *, "FAILED: MEGAN initialization"
      stop 1
   endif

   ! Initialize virtual column
   ! nlev=1, nspec_chem=1, nspec_emis=1
   call column%init(1, 1, 1, 1, 1, 0.0_fp, 0.0_fp, 1.0_fp, rc)
   if (rc /= CC_SUCCESS) then
      print *, "FAILED: Column initialization"
      stop 1
   endif

   ! Allocate and set meteorological inputs
   allocate(column%met%TS, column%met%SWGDN, column%met%LAI)
   column%met%TS = 300.0_fp
   column%met%SWGDN = 500.0_fp
   column%met%LAI = 5.0_fp

   ! Run the process on the column
   call megan%run_column(column, container, rc)
   if (rc /= CC_SUCCESS) then
      print *, "FAILED: MEGAN run_column"
      stop 1
   endif

   ! Check results
   actual_emis = column%emis_data(1, 1)
   print *, "Actual emission (isoprene): ", actual_emis

   if (actual_emis > 0.0_fp) then
      print *, "PASSED: MEGAN generated emissions"
   else
      print *, "FAILED: MEGAN generated zero emissions"
      stop 1
   endif

   ! Cleanup
   deallocate(column%met%TS, column%met%SWGDN, column%met%LAI)
   call column%cleanup()
   call megan%finalize(rc)

   print *, "Unit test test_megan_mod PASSED"

end program test_megan_mod

!> \file test_briggs_plume_rise.F90
!! \brief Unit test for Briggs 1969 plume rise scheme
!!
program test_briggs_plume_rise
   use precision_mod
   use briggs_plume_rise_mod

   implicit none

   real(fp) :: dh

   print *, "Running unit test for Briggs 1969 plume rise..."

   ! Test 1: Neutral condition, small buoyancy
   call calculate_plume_rise_briggs(100.0_fp, 2.0_fp, 10.0_fp, 400.0_fp, 300.0_fp, &
      5.0_fp, 0.0_fp, .false., dh)
   print *, "Test 1 Rise: ", dh
   if (dh > 0.0_fp) then
      print *, "Test 1 PASSED"
   else
      print *, "Test 1 FAILED"
      stop 1
   endif

   ! Test 2: Stable condition
   call calculate_plume_rise_briggs(100.0_fp, 2.0_fp, 10.0_fp, 400.0_fp, 300.0_fp, &
      2.0_fp, 0.001_fp, .true., dh)
   print *, "Test 2 Rise: ", dh
   if (dh > 0.0_fp) then
      print *, "Test 2 PASSED"
   else
      print *, "Test 2 FAILED"
      stop 1
   endif

   print *, "Unit test test_briggs_plume_rise PASSED"

end program test_briggs_plume_rise

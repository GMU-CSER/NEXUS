!> \file briggs_plume_rise_mod.F90
!! \brief Implementation of Briggs 1969 plume rise scheme
!!
module briggs_plume_rise_mod
   use precision_mod, only: fp
   use constants, only: g0, PI

   implicit none
   private

   public :: calculate_plume_rise_briggs

contains

   !> \brief Calculate plume rise using Briggs 1969 scheme
   !! \param[in] stack_height Height of the stack [m]
   !! \param[in] stack_diameter Diameter of the stack [m]
   !! \param[in] exit_velocity Velocity of the exit gas [m/s]
   !! \param[in] exit_temp Temperature of the exit gas [K]
   !! \param[in] ambient_temp Ambient air temperature [K]
   !! \param[in] wind_speed Wind speed at stack height [m/s]
   !! \param[in] stability_param Stability parameter (s) for stable conditions [s^-2]
   !! \param[in] is_stable Logical indicating if conditions are stable
   !! \param[out] plume_rise Calculated plume rise (delta h) [m]
   subroutine calculate_plume_rise_briggs(stack_height, stack_diameter, exit_velocity, &
      exit_temp, ambient_temp, wind_speed, stability_param, is_stable, plume_rise)

      real(fp), intent(in) :: stack_height, stack_diameter, exit_velocity
      real(fp), intent(in) :: exit_temp, ambient_temp, wind_speed
      real(fp), intent(in) :: stability_param
      logical, intent(in) :: is_stable
      real(fp), intent(out) :: plume_rise

      real(fp) :: F, buoyancy_flux
      real(fp) :: u_eff

      ! Avoid division by zero
      u_eff = max(wind_speed, 0.1_fp)

      ! Calculate buoyancy flux F [m^4/s^3]
      ! F = g * w_s * r_s^2 * (T_s - T_a) / T_s
      ! Using diameter: F = g * w_s * (d_s/2)^2 * (T_s - T_a) / T_s
      buoyancy_flux = g0 * exit_velocity * (stack_diameter**2 / 4.0_fp) * &
         (exit_temp - ambient_temp) / exit_temp

      if (buoyancy_flux <= 0.0_fp) then
         plume_rise = 0.0_fp
         return
      endif

      if (is_stable) then
         ! Stable conditions
         if (u_eff > 1.0_fp) then
            ! Bent-over plume in stable air
            plume_rise = 2.6_fp * (buoyancy_flux / (u_eff * max(stability_param, 1.0e-6_fp)))**(1.0_fp/3.0_fp)
         else
            ! Calm stable air
            plume_rise = 5.0_fp * (buoyancy_flux**(1.0_fp/4.0_fp)) / (max(stability_param, 1.0e-6_fp)**(3.0_fp/8.0_fp))
         endif
      else
         ! Neutral or Unstable conditions
         ! Final rise (standard Briggs formula for neutral/unstable)
         if (buoyancy_flux < 55.0_fp) then
            plume_rise = 21.42_fp * (buoyancy_flux**0.75_fp) / u_eff
         else
            plume_rise = 38.71_fp * (buoyancy_flux**0.60_fp) / u_eff
         endif
      endif

      ! Limit plume rise to something reasonable
      plume_rise = min(plume_rise, 2000.0_fp)

   end subroutine calculate_plume_rise_briggs

end module briggs_plume_rise_mod

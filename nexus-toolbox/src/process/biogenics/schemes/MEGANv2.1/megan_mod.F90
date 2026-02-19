!> \file megan_mod.F90
!! \brief Implementation of MEGANv2.1 biogenic emissions scheme
!!
module megan_mod
   use precision_mod, only: fp
   use error_mod, only: CC_SUCCESS, CC_FAILURE
   use constants, only: PI
   use VirtualColumn_Mod, only: VirtualColumnType, VirtualMetType
   use ProcessInterface_Mod, only: ColumnProcessInterface, StateManagerType

   implicit none
   private

   public :: MeganProcess

   !> \brief MEGANv2.1 process implementation
   type, extends(ColumnProcessInterface) :: MeganProcess
   contains
      procedure :: init => megan_init
      procedure :: run => megan_run
      procedure :: finalize => megan_finalize
      procedure :: run_column => megan_run_column
   end type MeganProcess

   ! Standard reference temperature [K]
   real(fp), parameter :: T_STANDARD = 303.0_fp
   ! W/m2 -> umol/m2/s
   real(fp), parameter :: WM2_TO_UMOLM2S = 4.766_fp

contains

   subroutine megan_init(this, container, rc)
      class(MeganProcess), intent(inout) :: this
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc

      this%name = 'MEGANv2.1'
      this%version = '2.1'
      this%description = 'Model of Emissions of Gases and Aerosols from Nature version 2.1'
      this%is_initialized = .true.
      this%is_active = .true.
      rc = CC_SUCCESS
   end subroutine megan_init

   subroutine megan_run(this, container, rc)
      class(MeganProcess), intent(inout) :: this
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc
      rc = CC_SUCCESS
   end subroutine megan_run

   subroutine megan_finalize(this, rc)
      class(MeganProcess), intent(inout) :: this
      integer, intent(out) :: rc
      rc = CC_SUCCESS
   end subroutine megan_finalize

   subroutine megan_run_column(this, column, container, rc)
      class(MeganProcess), intent(inout) :: this
      type(VirtualColumnType), intent(inout) :: column
      type(StateManagerType), intent(inout) :: container
      integer, intent(out) :: rc

      type(VirtualMetType), pointer :: met
      real(fp) :: gamma_P, gamma_T, gamma_LAI, gamma_age, gamma_SM, gamma_CO2
      real(fp) :: emis_isop
      real(fp) :: ts, swgdn, lai, aef
      real(fp) :: pt_15, pt_24, pac_daily, phi, bbb, aaa, sinbeta

      rc = CC_SUCCESS
      met => column%get_met()

      ! Extract meteorological variables from column
      ts = met%TS
      swgdn = met%SWGDN
      if (associated(met%LAI)) then
         lai = met%LAI
      else
         lai = 5.0_fp
      endif

      ! Historical temperatures (placeholders for this example)
      pt_15 = 297.0_fp
      pt_24 = 288.15_fp

      ! Temperature activity factor for Isoprene (Light Dependent)
      gamma_T = get_gamma_t_ld(ts, pt_15, pt_24)

      ! Light activity factor (Simplified PCEEA)
      if (swgdn > 0.0_fp) then
         pac_daily = 400.0_fp * WM2_TO_UMOLM2S
         sinbeta = 0.866_fp ! Fixed 60 deg for example
         phi = (swgdn * WM2_TO_UMOLM2S) / (sinbeta * 3000.0_fp)
         bbb = 1.0_fp + 0.0005_fp * (pac_daily - 400.0_fp)
         aaa = (2.46_fp * bbb * phi) - (0.9_fp * phi**2)
         gamma_P = sinbeta * aaa
      else
         gamma_P = 0.0_fp
      endif

      ! LAI activity factor
      gamma_LAI = 0.49_fp * lai / sqrt(1.0_fp + 0.2_fp * lai**2)

      ! Age, Soil Moisture, CO2 factors (fixed at 1.0 for example)
      gamma_age = 1.0_fp
      gamma_SM = 1.0_fp
      gamma_CO2 = 1.0_fp

      ! Base emission factor for Isoprene (example: 1.0e-9 kg/m2/s)
      aef = 1.0e-9_fp

      ! Normalization factor (approx 1.0)
      emis_isop = aef * gamma_age * gamma_SM * gamma_LAI * gamma_P * gamma_T * gamma_CO2

      ! Store result in column emission data (assume species 1 is isoprene)
      if (column%nspec_emis >= 1) then
         column%emis_data(1, 1) = emis_isop
      endif

   end subroutine megan_run_column

   function get_gamma_t_ld(t, pt_15, pt_24) result(gamma_t_ld)
      real(fp), intent(in) :: t, pt_15, pt_24
      real(fp) :: gamma_t_ld
      real(fp) :: e_opt, t_opt, x, ct1, ct2, r

      ct1 = 95.0_fp
      ct2 = 200.0_fp
      r = 8.3144598e-3_fp

      e_opt = 2.0_fp * exp(0.08_fp * (pt_15 - 297.0_fp))
      t_opt = 313.0_fp + 0.6_fp * (pt_15 - 297.0_fp)
      x = (1.0_fp/t_opt - 1.0_fp/t) / r

      gamma_t_ld = e_opt * ct2 * exp(ct1 * x) / (ct2 - ct1 * (1.0_fp - exp(ct2 * x)))
      gamma_t_ld = max(gamma_t_ld, 0.0_fp)
   end function get_gamma_t_ld

end module megan_mod

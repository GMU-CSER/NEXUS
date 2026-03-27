!> \file VirtualColumn_Mod.F90
!! \brief Virtual column data container for nexus-toolbox
!!
module VirtualColumn_Mod
   use precision_mod, only: fp
   use error_mod, only: CC_SUCCESS, CC_FAILURE

   implicit none
   private

   public :: VirtualColumnType, VirtualMetType

   !> \brief Virtual meteorological data container with direct pointers
   type :: VirtualMetType
      real(fp), pointer :: T(:) => null()
      real(fp), pointer :: P(:) => null()
      real(fp), pointer :: QV(:) => null()
      real(fp), pointer :: U(:) => null()
      real(fp), pointer :: V(:) => null()
      real(fp), pointer :: PBLH => null()
      real(fp), pointer :: SWGDN => null()
      real(fp), pointer :: TS => null()
      real(fp), pointer :: USTAR => null()
      real(fp), pointer :: FROCEAN => null()
      real(fp), pointer :: SST => null()
      real(fp), pointer :: LAI => null()
      real(fp), pointer :: GWETROOT => null()
      real(fp), pointer :: SUNCOS => null()
      real(fp), pointer :: PARDR => null()
      real(fp), pointer :: PARDF => null()
   contains
      procedure :: cleanup => virtual_met_cleanup
   end type VirtualMetType

   !> \brief Virtual column data container for process-level column virtualization
   type :: VirtualColumnType
      type(VirtualMetType) :: met

      real(fp), allocatable :: chem_data(:,:)
      real(fp), allocatable :: emis_data(:,:)

      integer :: grid_i = 0
      integer :: grid_j = 0
      real(fp) :: lat = 0.0_fp
      real(fp) :: lon = 0.0_fp
      real(fp) :: area = 0.0_fp

      integer :: nlev = 0
      integer :: nspec_chem = 0
      integer :: nspec_emis = 0

      logical :: is_valid = .false.

   contains
      procedure :: init => virtual_column_init
      procedure :: get_met => virtual_column_get_met
      procedure :: cleanup => virtual_column_cleanup
   end type VirtualColumnType

contains

   subroutine virtual_met_cleanup(this)
      class(VirtualMetType), intent(inout) :: this
      nullify(this%T, this%P, this%QV, this%U, this%V, this%PBLH, this%SWGDN, this%TS, this%USTAR, &
              this%FROCEAN, this%SST, this%LAI, this%GWETROOT, this%SUNCOS, this%PARDR, this%PARDF)
   end subroutine virtual_met_cleanup

   subroutine virtual_column_init(this, nlev, nspec_chem, nspec_emis, grid_i, grid_j, lat, lon, area, rc)
      class(VirtualColumnType), intent(inout) :: this
      integer, intent(in) :: nlev, nspec_chem, nspec_emis
      integer, intent(in) :: grid_i, grid_j
      real(fp), intent(in) :: lat, lon, area
      integer, intent(out) :: rc

      this%nlev = nlev
      this%nspec_chem = nspec_chem
      this%nspec_emis = nspec_emis
      this%grid_i = grid_i
      this%grid_j = grid_j
      this%lat = lat
      this%lon = lon
      this%area = area

      if (nlev > 0 .and. nspec_chem > 0) allocate(this%chem_data(nlev, nspec_chem))
      if (nlev > 0 .and. nspec_emis > 0) allocate(this%emis_data(nlev, nspec_emis))

      this%is_valid = .true.
      rc = CC_SUCCESS
   end subroutine virtual_column_init

   function virtual_column_get_met(this) result(met_ptr)
      class(VirtualColumnType), intent(in), target :: this
      type(VirtualMetType), pointer :: met_ptr
      met_ptr => this%met
   end function virtual_column_get_met

   subroutine virtual_column_cleanup(this)
      class(VirtualColumnType), intent(inout) :: this
      call this%met%cleanup()
      if (allocated(this%chem_data)) deallocate(this%chem_data)
      if (allocated(this%emis_data)) deallocate(this%emis_data)
      this%is_valid = .false.
   end subroutine virtual_column_cleanup

end module VirtualColumn_Mod

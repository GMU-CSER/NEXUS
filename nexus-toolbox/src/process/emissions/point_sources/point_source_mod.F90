!> \file point_source_mod.F90
!! \brief Point source processing using ESMF LocStream
!!
module point_source_mod
   use ESMF
   use precision_mod, only: fp
   use error_mod, only: CC_SUCCESS, CC_FAILURE

   implicit none
   private

   public :: PointSourceBatchType

   !> \brief Container for a batch of point sources
   type :: PointSourceBatchType
      integer :: n_points = 0
      real(fp), allocatable :: lats(:)
      real(fp), allocatable :: lons(:)
      real(fp), allocatable :: emissions(:) ! kg/s

      type(ESMF_LocStream) :: loc_stream
      type(ESMF_Field) :: loc_field
      type(ESMF_RouteHandle) :: route_handle

   contains
      procedure :: init => point_source_init
      procedure :: create_loc_stream => point_source_create_loc_stream
      procedure :: map_to_grid => point_source_map_to_grid
      procedure :: cleanup => point_source_cleanup
   end type PointSourceBatchType

contains

   !> \brief Initialize the point source batch
   subroutine point_source_init(this, n_points, rc)
      class(PointSourceBatchType), intent(inout) :: this
      integer, intent(in) :: n_points
      integer, intent(out) :: rc

      this%n_points = n_points
      allocate(this%lats(n_points), this%lons(n_points), this%emissions(n_points), stat=rc)
      if (rc /= 0) then
         rc = CC_FAILURE
         return
      endif

      this%lats = 0.0_fp
      this%lons = 0.0_fp
      this%emissions = 0.0_fp
      rc = CC_SUCCESS
   end subroutine point_source_init

   !> \brief Create ESMF LocStream from point data
   subroutine point_source_create_loc_stream(this, rc)
      class(PointSourceBatchType), intent(inout) :: this
      integer, intent(out) :: rc

      integer :: local_rc
      real(fp), pointer :: ptr_lats(:), ptr_lons(:)

      ! Create LocStream
      this%loc_stream = ESMF_LocStreamCreate(localCount=this%n_points, rc=local_rc)
      if (local_rc /= ESMF_SUCCESS) then
         rc = CC_FAILURE
         return
      endif

      ! Add coordinates to LocStream
#ifdef USE_REAL8
      call ESMF_LocStreamAddKey(this%loc_stream, keyName="Latitude", &
         keyKind=ESMF_TYPEKIND_R8, rc=local_rc)
      call ESMF_LocStreamAddKey(this%loc_stream, keyName="Longitude", &
         keyKind=ESMF_TYPEKIND_R8, rc=local_rc)
#else
      call ESMF_LocStreamAddKey(this%loc_stream, keyName="Latitude", &
         keyKind=ESMF_TYPEKIND_R4, rc=local_rc)
      call ESMF_LocStreamAddKey(this%loc_stream, keyName="Longitude", &
         keyKind=ESMF_TYPEKIND_R4, rc=local_rc)
#endif

      ! Get pointers and fill coordinates
      call ESMF_LocStreamGetKey(this%loc_stream, keyName="Latitude", &
         farrayPtr=ptr_lats, rc=local_rc)
      call ESMF_LocStreamGetKey(this%loc_stream, keyName="Longitude", &
         farrayPtr=ptr_lons, rc=local_rc)

      ptr_lats = this%lats
      ptr_lons = this%lons

      ! Create Field on LocStream
#ifdef USE_REAL8
      this%loc_field = ESMF_FieldCreate(this%loc_stream, &
         typekind=ESMF_TYPEKIND_R8, name="point_emissions", rc=local_rc)
#else
      this%loc_field = ESMF_FieldCreate(this%loc_stream, &
         typekind=ESMF_TYPEKIND_R4, name="point_emissions", rc=local_rc)
#endif

      rc = CC_SUCCESS
   end subroutine point_source_create_loc_stream

   !> \brief Map point emissions to a gridded field
   !! \param[inout] gridded_field ESMF Field defined on a Grid
   subroutine point_source_map_to_grid(this, gridded_field, rc)
      class(PointSourceBatchType), intent(inout) :: this
      type(ESMF_Field), intent(inout) :: gridded_field
      integer, intent(out) :: rc

      integer :: local_rc
      real(fp), pointer :: ptr_emissions(:)

      ! Fill the source field with current emission values
      call ESMF_FieldGet(this%loc_field, farrayPtr=ptr_emissions, rc=local_rc)
      ptr_emissions = this%emissions

      ! Initialize RouteHandle if not already done
      if (.not. ESMF_RouteHandleIsCreated(this%route_handle)) then
         call ESMF_FieldRegridStore(this%loc_field, gridded_field, &
            regridmethod=ESMF_REGRIDMETHOD_BILINEAR, &
            unmappedaction=ESMF_UNMAPPEDACTION_IGNORE, &
            routehandle=this%route_handle, rc=local_rc)
      endif

      ! Perform the regridding (transfer from points to grid)
      call ESMF_FieldRegrid(this%loc_field, gridded_field, &
         routehandle=this%route_handle, rc=local_rc)

      if (local_rc == ESMF_SUCCESS) then
         rc = CC_SUCCESS
      else
         rc = CC_FAILURE
      endif
   end subroutine point_source_map_to_grid

   !> \brief Clean up ESMF objects
   subroutine point_source_cleanup(this)
      class(PointSourceBatchType), intent(inout) :: this
      integer :: rc

      if (allocated(this%lats)) deallocate(this%lats)
      if (allocated(this%lons)) deallocate(this%lons)
      if (allocated(this%emissions)) deallocate(this%emissions)

      call ESMF_FieldDestroy(this%loc_field, rc=rc)
      if (ESMF_RouteHandleIsCreated(this%route_handle)) then
         call ESMF_FieldRegridRelease(this%route_handle, rc=rc)
      endif
      call ESMF_LocStreamDestroy(this%loc_stream, rc=rc)
   end subroutine point_source_cleanup

end module point_source_mod

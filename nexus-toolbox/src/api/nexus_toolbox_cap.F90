!> \file nexus_toolbox_cap.F90
!! \brief NUOPC cap for nexus-toolbox
!!
module nexus_toolbox_cap
  use ESMF
  use NUOPC
  use NUOPC_Model, modelSS => SetServices

  implicit none
  private

  public :: SetServices

contains

  !> \brief NUOPC SetServices entry point
  subroutine SetServices(model, rc)
    type(ESMF_GridComp)  :: model
    integer, intent(out) :: rc

    rc = ESMF_SUCCESS

    ! Derive from NUOPC_Model
    call NUOPC_CompDerive(model, modelSS, rc=rc)
    if (rc /= ESMF_SUCCESS) return

    ! Specialize model
    call NUOPC_CompSpecialize(model, specLabel=label_Advertise, &
      specRoutine=Advertise, rc=rc)
    if (rc /= ESMF_SUCCESS) return

    call NUOPC_CompSpecialize(model, specLabel=label_RealizeProvided, &
      specRoutine=Realize, rc=rc)
    if (rc /= ESMF_SUCCESS) return

    call NUOPC_CompSpecialize(model, specLabel=label_Advance, &
      specRoutine=Advance, rc=rc)
    if (rc /= ESMF_SUCCESS) return

  end subroutine SetServices

  !> \brief NUOPC Advertise phase
  subroutine Advertise(model, rc)
    type(ESMF_GridComp)  :: model
    integer, intent(out) :: rc
    rc = ESMF_SUCCESS
    ! Advertise fields here
  end subroutine Advertise

  !> \brief NUOPC Realize phase
  subroutine Realize(model, rc)
    type(ESMF_GridComp)  :: model
    integer, intent(out) :: rc
    rc = ESMF_SUCCESS
    ! Realize fields here
  end subroutine Realize

  !> \brief NUOPC Advance phase (Time-stepping)
  subroutine Advance(model, rc)
    type(ESMF_GridComp)  :: model
    integer, intent(out) :: rc
    rc = ESMF_SUCCESS
    ! Advance model state here
  end subroutine Advance

end module nexus_toolbox_cap

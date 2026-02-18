!> \file error_mod.F90
!! \brief Error handling system for nexus-toolbox
!!
module error_mod
   use precision_mod, only: fp
   implicit none
   private

   public :: CC_SUCCESS, CC_FAILURE
   public :: CC_Error, CC_Warning
   public :: CC_CheckVar
   public :: ErrorManagerType
   public :: ErrorInfoType
   public :: ErrorContextType

   ! Standard Return Codes
   INTEGER, PUBLIC, PARAMETER :: CC_SUCCESS =  0
   INTEGER, PUBLIC, PARAMETER :: CC_FAILURE = -1

   ! Error Codes
   INTEGER, PUBLIC, PARAMETER :: ERROR_NONE = 0
   INTEGER, PUBLIC, PARAMETER :: ERROR_INVALID_INPUT = 1001
   INTEGER, PUBLIC, PARAMETER :: ERROR_BOUNDS_CHECK = 1010
   INTEGER, PUBLIC, PARAMETER :: ERROR_MEMORY_ALLOCATION = 1007

   type :: ErrorInfoType
      integer :: error_code = ERROR_NONE
      character(len=255) :: message = ''
   end type ErrorInfoType

   type :: ErrorContextType
      character(len=100) :: routine_name = ''
      character(len=255) :: description = ''
   end type ErrorContextType

   type :: ErrorManagerType
      integer :: total_errors = 0
   contains
      procedure :: report_error => error_manager_report_error
   end type ErrorManagerType

contains

   SUBROUTINE CC_Error( ErrMsg, RC, ThisLoc, Instr )
      CHARACTER(LEN=*), INTENT(IN)            :: ErrMsg
      CHARACTER(LEN=*), INTENT(IN), OPTIONAL  :: ThisLoc
      CHARACTER(LEN=*), INTENT(IN), OPTIONAL  :: Instr
      INTEGER,          INTENT(INOUT)            :: RC

      WRITE( *, '(a)' ) 'NEXUS ERROR: ' // TRIM( ErrMsg )
      IF ( PRESENT( ThisLoc ) ) WRITE( *, '(a)' ) 'LOCATION: ' // TRIM( ThisLoc )
      IF ( PRESENT( Instr ) ) WRITE( *, '(a)' ) 'INFO: ' // TRIM( Instr )
      RC = CC_FAILURE
   END SUBROUTINE CC_Error

   SUBROUTINE CC_Warning( WarnMsg, RC, ThisLoc, Instr )
      CHARACTER(LEN=*), INTENT(IN   )            :: WarnMsg
      CHARACTER(LEN=*), INTENT(IN   ), OPTIONAL  :: ThisLoc
      CHARACTER(LEN=*), INTENT(IN   ), OPTIONAL  :: Instr
      INTEGER,          INTENT(INOUT)            :: RC

      WRITE( *, '(a)' ) 'NEXUS WARNING: ' // TRIM( WarnMsg )
      RC = CC_SUCCESS
   END SUBROUTINE CC_Warning

   SUBROUTINE CC_CheckVar( Variable, Operation, RC )
      CHARACTER(LEN=*), INTENT(IN)    :: Variable
      INTEGER,          INTENT(IN)    :: Operation
      INTEGER,          INTENT(INOUT) :: RC

      IF ( RC /= CC_SUCCESS ) THEN
         CALL CC_Error( 'Variable error: ' // TRIM(Variable), RC )
      ENDIF
   END SUBROUTINE CC_CheckVar

   subroutine error_manager_report_error(this, error_code, message, rc, location, suggestion)
      class(ErrorManagerType), intent(inout) :: this
      integer, intent(in) :: error_code
      character(len=*), intent(in) :: message
      integer, intent(inout) :: rc
      character(len=*), intent(in), optional :: location, suggestion

      call CC_Error(message, rc, location, suggestion)
      this%total_errors = this%total_errors + 1
   end subroutine error_manager_report_error

end module error_mod

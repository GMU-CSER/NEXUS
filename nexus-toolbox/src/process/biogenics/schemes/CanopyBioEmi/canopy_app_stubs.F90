module canopy_const_mod
   integer, parameter :: rk = 8
   real(rk), parameter :: rgasuniv = 8.3144598
end module canopy_const_mod

module canopy_utils_mod
   use canopy_const_mod
   implicit none
contains
   function interp_linear1_internal(x, y, xi) result(yi)
      real(rk), intent(in) :: x(:), y(:), xi
      real(rk) :: yi
      yi = 0.0
   end function
   function GET_GAMMA_CO2(opt, set) result(res)
      integer :: opt
      real(rk) :: set, res
      res = 1.0
   end function
   function GET_GAMMA_LEAFAGE(opt, past, curr, step, temp, an, ag, am, ao) result(res)
      integer :: opt
      real(rk) :: past, curr, step, temp, an, ag, am, ao, res
      res = 1.0
   end function
   function GET_GAMMA_SOIM(opt, s1, s2, s3, s4, d1, d2, d3, d4, wilt, ra, rb) result(res)
      integer :: opt
      real(rk) :: s1, s2, s3, s4, d1, d2, d3, d4, wilt, ra, rb, res
      res = 1.0
   end function
   function GET_GAMMA_AQ(opt, ref, set, c, t, dt) result(res)
      integer :: opt
      real(rk) :: ref, set, c, t, dt, res
      res = 1.0
   end function
   function GET_GAMMA_HT(opt, max_t, c, t, dt) result(res)
      integer :: opt
      real(rk) :: max_t, c, t, dt, res
      res = 1.0
   end function
   function GET_GAMMA_LT(opt, min_t, c, t, dt) result(res)
      integer :: opt
      real(rk) :: min_t, c, t, dt, res
      res = 1.0
   end function
   function GET_GAMMA_HW(opt, max_ws, c, t, dt) result(res)
      integer :: opt
      real(rk) :: max_ws, c, t, dt, res
      res = 1.0
   end function
   function GET_CANLOSS_BIO(opt, life, ustar, fch) result(res)
      integer :: opt
      real(rk) :: life, ustar, fch, res
      res = 1.0
   end function
end module canopy_utils_mod

module canopy_bioparm_mod
   use canopy_const_mod
   implicit none
contains
   subroutine canopy_biop(ind, lu, vtype, ef, ldf, beta, ct1, ceo, anew, agro, amat, aold, ra, rb, caq, taq, dtaq, cht, tht, dtht, clt, tlt, dtlt, chw, thw, dthw)
      integer :: ind, lu, vtype
      real(rk) :: ef, ldf, beta, ct1, ceo, anew, agro, amat, aold, ra, rb, caq, taq, dtaq, cht, tht, dtht, clt, tlt, dtlt, chw, thw, dthw
      ef = 1.0; ldf = 0.5; beta = 0.1; ct1 = 95.0; ceo = 2.0
      anew = 1.0; agro = 1.0; amat = 1.0; aold = 1.0
      ra = 1.0; rb = 1.0; caq = 1.0; taq = 1.0; dtaq = 1.0
      cht = 1.0; tht = 1.0; dtht = 1.0; clt = 1.0; tlt = 1.0; dtlt = 1.0
      chw = 1.0; thw = 1.0; dthw = 1.0
   end subroutine
end module canopy_bioparm_mod

module canopy_tleaf_mod
end module canopy_tleaf_mod

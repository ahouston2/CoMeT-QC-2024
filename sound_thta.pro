function sound_thta, t,p,qv,temp=temp

;===========================================================================
; If temp flag is not set, t defined as temperature and result is potential
;  temperature
; If temp flag is set, t defined as potential temperature and result is
;  temperature
; t: K
; p: Pa
; qv: kg/kg
;===========================================================================

Cpd = 1004.0
Cpv = 1870.
p0  = 1e5
Rd = 287.
Rv = Cpd-Rd

expnt = (Rd + qv*Rv)/(cpd + qv*cpv)
if ( keyword_set(temp)) then result = t*(p/p0)^expnt
if (~keyword_set(temp)) then result = t*(p0/p)^expnt

return, result
end

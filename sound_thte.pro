function sound_thte, tmpk, pres, rh

; tmpk: temperature in K
; pres: pressure in Pa
; rh:   RH in %

rd = 287.
cp = 1004.

kpa = rd/cp

thta = sound_thta(tmpk, pres, 0.)
es   = sound_satvappres(tmpk,'arm')
e    = 0.01*es*rh                                              ; Pa
qv   = 0.622*e/pres                                            ; kg/kg
tlcl = 55.0+(2840.0/(3.5*alog(tmpk)-alog(0.01*e)-4.805))       ; K
tm   = thta*(tmpk/thta)^(kpa*qv)                               ; K

return, tm*exp( ((3376.0/tlcl)-2.54)*qv*(1.0+0.81*qv) )
end
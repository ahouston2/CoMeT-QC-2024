;===========================================================================================
; Correction to CoMeT pressure owing to dependence of pressure port on flow speed.
;  p: hPa
;  wsraw: m/s
;  type: 'gill', 'alum'
;===========================================================================================

function comet_pressure_corr, p, wsraw, type

if (type eq 'gill') then begin
  a3 = 5e-7
  a2 = -0.001
  a1 = -6e-5
endif else begin
  a3 = 3.5e-5
  a2 = -0.0005
  a1 = 0.0045
endelse

return,  p + a3*wsraw^3 + a2*wsraw^2 + a1*wsraw

end
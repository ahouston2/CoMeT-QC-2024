function sound_thtv, thta, qv

; Qv in g/kg

Cpd = 1004.0
Cpv = 1870.
Lv  = 2.5e6
p0  = 100000.
eps = 0.622

return, thta*(1.+0.61*0.001*qv)
end

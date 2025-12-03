function sound_mixr, p, e

;=================================================
; p: Pascals
; e: Pascals
; Mixing ratio returned as g/kg
;=================================================
eps = 0.622

return, 1000.*eps*e/(p-e)

end

function sound_satvappres, t, method, theta=theta, p=p, type=type

;=================================================
; In this new version, 
;   * method is included as a required argument (before, "bolton" was an optional argument).
;   * t is either theta or temperature (both in Kelvin).  The theta flag is included to specifiy which.
;   * p (in Pascals) is optional because it's only required if theta flag is set.
;   * type is now an optional keyword parameter: i or l (ice or liquid)
; Output is unchanged: units are Pa
;=================================================

case method of
  'bolton': begin
    a = 611.2
    b = 17.67
    c = 29.65
  end
  'amr': begin    ; August-Roch-Magnus (Lawrence 2005)
    a = 610.94
    b = 17.625
    c = 273.15-243.04
  end
  else: begin
    a = 610.78
    if (~ keyword_set(type)) then type = 'l' 
    if (type eq 'i') then begin
      b = 21.875
      c = 7.66
    endif else begin
      b = 17.269 
      c = 35.86
    endelse
  end
endcase

if (keyword_set(theta)) then begin
  t = sound_thta(t,p,0.,/temp)  
endif

return, a*exp(b*(t-273.15)/(t-c))

end

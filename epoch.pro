function epoch, yr, mo, dy, hr, mn, ss, seedyr=seedyr

if (~keyword_set(seedyr)) then seedyr = 1970.

days = [31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31]

; Calculate the number of seconds elapsed for input year
;
secsmnhr = 60d0 * mn
secshrdy = 3600d0 * hr
secsdymo = 86400d0 * (dy-1)
secsdyyr = 0d0
if (mo gt 1) then secsdyyr = 86400d0 * total(days(0:mo-2))
if (mo gt 2) then secsdyyr = secsdyyr + 86400.*leapyr(fix(yr))

; Calculate the number of seconds elapsed for all previous years
;
secsyryr = ((yr-seedyr) * 31536000d0) 
if (yr gt seedyr) then begin
  years = fix(seedyr)+indgen(yr-seedyr)
  secsyryr = secsyryr + (86400d0*total(leapyr(years)))
endif

return, secsmnhr+secshrdy+secsdymo+secsdyyr+secsyryr+ss

end

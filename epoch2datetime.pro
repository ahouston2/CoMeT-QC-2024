pro epoch2datetime, epochtime, yr, mo, dy, hr, mn, ss, seedyr=seedyr

if (~keyword_set(seedyr)) then seedyr = 1970

days = [31.,28.,31.,30.,31.,30.,31.,31.,30.,31.,30.,31]

n = n_elements(epochtime)
if (n gt 1) then begin
  yr = intarr(n)
  mo = intarr(n)
  dy = intarr(n)
  hr = intarr(n)
  mn = intarr(n)
  ss = fltarr(n)
endif else begin
  yr = 0
  mo = 0
  dy = 0
  hr = 0
  mn = 0
  ss = 0.
endelse

for i=0,n-1 do begin
  et = 0d
  yr[i] = seedyr

  while (epochtime[i]-et ge 0) do begin
    secsyr = 31536000d0 + (86400d0*leapyr(yr[i]))
    et = et+secsyr
    yr[i] ++
  endwhile

  et = et-secsyr
  yr[i] --

  mo[i] = 1
  while (epochtime[i]-et ge 0) do begin
    secsmo = 86400d0 * days(mo[i]-1) 
    if (mo[i] eq 2) then secsmo = secsmo + 86400d0*leapyr(yr[i])
    et = et+secsmo
    mo[i] ++
  endwhile

  et = et-secsmo
  mo[i] --

  dy[i] = 1
  while (epochtime[i]-et ge 0) do begin
    et = et + 86400d0
    dy[i] ++
  endwhile

  et = et - 86400d0
  dy[i] --

  hr[i] = 0
  while (epochtime[i]-et ge 0) do begin
    et = et + 3600d0
    hr[i] ++
  endwhile

  et = et - 3600d0
  hr[i] --

  mn[i] = 0
  while (epochtime[i]-et ge 0) do begin
    et = et + 60d0
    mn[i] ++
  endwhile

  et = et - 60d0
  mn[i] --

  ss[i] = epochtime[i] - et
endfor
  
end

;===================================================================================================================
; hwidth: the halfwidth for calculating the mean and median
; std_f: Number of standard deviations above which to remove data.
;===================================================================================================================

function spikefilter_new, a, na, hwidth=hwidth, std_f=std_f, verbose=verbose

if (~keyword_set(hwidth)) then hwidth=10
if (~keyword_set(std_f)) then std_f = 7
std_f0 = 1

;===
; Create filtered array just to ensure that the mean and median used for the actual filtering don't include the spikes.  
;  This filtered arrays isn't the final filtered array
;===
anew = a
abad = a
n=0
;for i=hwidth,na-(hwidth+1) do begin
;  i0=i-hwidth
;  i1=i+hwidth
;  atmp = [a[i0:i-1],a[i+1:i1]]
for i=0,na-1 do begin
  i0=i-hwidth > 0
  i1=i+hwidth < na-1
  if (i eq 0) then begin
    atmp = [a[i+1:i1]]
  endif else if (i eq na-1) then begin
    atmp = [a[i0:i-1]]
  endif else begin
    atmp = [a[i0:i-1],a[i+1:i1]]
  endelse
  mna = mean(atmp)
  mda = median(atmp)
  std = stddev(atmp)
  if (abs(a[i]-mda) gt std_f0*std) then begin ; Median is used to minimize the impact of adjacent spikes
    abad[i] = !values.f_nan
    n ++
  endif
endfor

if (n gt 0) then begin
  m = 0
;  for i=hwidth,na-(hwidth+1) do begin
;    i0=i-hwidth
;    i1=i+hwidth
;    atmp = [abad[i0:i-1],abad[i+1:i1]]
  for i=0,na-1 do begin
    i0=i-hwidth > 0
    i1=i+hwidth < na-1
    if (i eq 0) then begin
      atmp = [abad[i+1:i1]]
    endif else if (i eq na-1) then begin
      atmp = [abad[i0:i-1]]
    endif else begin
      atmp = [abad[i0:i-1],abad[i+1:i1]]
    endelse

    mna = mean(atmp,/nan)
    mda = median(atmp)
    std = stddev(atmp,/nan)
    if (abs(a[i]-mda) gt std_f*std) then begin
      anew[i] = mna
      m ++
    endif
  endfor
endif

if (keyword_Set(verbose)) then print, ' <>', m, ' data spikes removed'

return, anew

end

function fill_temp, temp, array

on_ioerror, bad

for i=0,n_elements(array)-1 do begin
  sz = size(temp.(i))  
  case sz[1] of 
    2: temp.(i) = fix(array[i])
    4: temp.(i) = float(array[i])
    5: temp.(i) = double(array[i])
    7: temp.(i) = array[i]
  endcase 
endfor

return, temp
bad:
  print, ' <!!!!!!> ', !error_state.msg, ' STOPPING'
  stop
end

;================================================================================================
; Only needed for CoMeT1 for which raw data aren't synced.
;   data: the synced data that are passed back to the qc code
;   raw: Sturcture of raw data
;   time_full: This will differ for each raw data stream so just time, not all "full" data, passed in
;   i_raw: Index for the raw data
;   i_full: Index for full data.  Since the synced data has the same size as the full data, i_full = i_data
;   tags: The tags in the data structure have the same name as the relevant tags in the raw data so 
;    only need to pass in one set of tag names
;================================================================================================
function sync_scenarios, raw, data, time_full, i_raw, i_full, tags

  bad = 0
  ntags = n_elements(tags)
  tRi = intarr(ntags)
  tDi = intarr(ntags)
  for j=0,n_elements(tags)-1 do begin
    tRi[j] = where(tag_names(raw)  eq tags[j])
    tDi[j] = where(tag_names(data) eq tags[j])
  endfor
  
  if (raw.epoch_time[i_raw] eq time_full[i_full]) then begin
    for j=0,n_elements(tags)-1 do data[i_full].(tDi[j]) = raw.(tRi[j])[i_raw]
    i_raw ++
  endif else begin

; This is an unlikely scenario because it means that there's full data without matching raw data.  In this scenario,
;  i_raw isn't advanced and the expectation is that the full data will "catch up" in later iterations.  
;  HOWEVER, there are times in the Fluxgate data where the flux computer time saved in the full file is an old time 
;  (the previous record).  This is checked below.
    if (raw.epoch_time[i_raw] gt time_full[i_full]) then begin
; full -> [i-1=1, i=1, i+1=3] and raw -> [i-1=1, i=2, i+1=3]
      if (time_full[i_full]   eq raw.epoch_time[i_raw-1] and  $
          time_full[i_full+1] eq raw.epoch_time[i_raw+1]) then begin
        for j=0,n_elements(tags)-1 do data[i_full].(tDi[j]) = raw.(tRi[j])[i_raw]
        i_raw ++
; full -> [i-1=1, i=1, i+1=2] and raw -> [i-1=1, i=2, i+1=3]
      endif else if (time_full[i_full]   eq raw.epoch_time[i_raw-1] and  $
                     time_full[i_full+1] ne raw.epoch_time[i_raw+1]) then begin
        for j=0,n_elements(tags)-1 do data[i_full].(tDi[j]) = raw.(tRi[j])[i_raw]
      endif else begin
        for j=0,n_elements(tags)-1 do data[i_full].(tDi[j]) = !values.f_nan
        bad = 1
      endelse
 
; In this scenario, full data have "skipped ahead" and so there's raw data without matching full data.  This condition is checked in
;  the qc code already so there's no need to flag it here.  In this situation a match to the full data at this time needs to be found
;  in future raw data.
    endif else begin
      pos = where(raw.epoch_time eq time_full[i_full], cnt)
      if (cnt gt 0) then begin
        i_raw = pos[0]
        for j=0,n_elements(tags)-1 do data[i_full].(tDi[j]) = raw.(tRi[j])[i_raw]
        i_raw ++
      endif else begin
        for j=0,n_elements(tags)-1 do data[i_full].(tDi[j]) = !values.f_nan
        bad = 1
      endelse
    endelse
  endelse
  
  return, bad
end


function strip, rec, elems, comet

  nelem = n_elements(elems)
  for j=0,nelem-1 do begin
    if (comet ne '1') then begin
      if (j eq 9) then begin
        srch0 = string(j+1,format='(i2.2)')
        srch1 = "  20"
      endif else if (j eq 10) then begin
        srch0 = "20"
        srch1 = string(j+1,format='("  ",i2.2)')
      endif else if (j gt 10) then begin              ; For j=11 and beyond the tag in the raw file matches the index in the array
        srch0 = string(j  ,format='(i2.2)')
        srch1 = string(j+1,format='("  ",i2.2)')
      endif else begin
        srch0 = string(j+1,format='(i2.2)')
        srch1 = string(j+2,format='("  ",i2.2)')
      endelse
    endif else begin
      srch0 = string(j+1,format='(i2.2)')
      srch1 = string(j+2,format='("  ",i2.2)')
    endelse

    i0 = rec.indexof(srch0)
    i1 = rec.indexof(srch1)

    if (j eq nelem-1) then begin
      chunk = rec.substring(i0+2)
    endif else begin
      chunk = rec.substring(i0+2,i1)
    endelse
;===
; Clean up the chunk
;===
    chunk = chunk.compress()        ; There could be extra white space between the sign of the value and the value
    if (chunk eq '+') then chunk = '-999'     ; This is a missing value.
    if (chunk.substring(0,2) eq '+$G') then chunk = chunk.substring(1)    ; Trim the + sign from the GPS strings

    rec = rec.substring(i1+2)     ; Trim the rec to reduce the risk of not finding the correct starting string.
    elems[j] = chunk
  endfor

end

;================================================================================================
; Reads data from raw files.  REMEMBER: the raw time is NOT the GPS time.  To get this, 
;  you need to translate the GPRMC data.  
; Version 2: 
;   Now works with CoMeT-1
;   Required passing in CoMeT designation
;   If for 2, 3, or alpha file passed in is CoMeT[]_raw_[yymmdd]_[hhmm].txt
;   if for 1, file passed in is CoMeT1_gpsraw_[yymmdd]_[hhmm].txt
; Version 3: 
;   The previous version doesn't work for CoMeT-1 THV file and the CoMeT-2/3 raw files if the signs of the params are negative.  
;    It assumes the delimeter is a "+" but it could be a "+" or a "-".  This version uses the double space as the delimeter.
;================================================================================================

function read_comet_raw, file, comet, fileformat

on_ioerror, bad

template = {temp_f: 0.,  $
    temp_s: 0.,  $      ; C
    rh_s: 0.,  $        ; %
    WndSpd: 0.,  $      ; m/s
    WndDir: 0.,  $
    dewpt:  0.,  $      ; C
    rh_f: 0.,  $        ; %
    pres: 0.,  $        ; hPa
    compt1: 0d,  $
    paneltemp: 0.,  $
    battvolt: 0.,  $
    wndspdraw: 0.,  $   ; m/s
    wnddirraw: 0.,  $
    fluxdir: 0.,  $
    gprmc: '',  $
    gpgga: '',  $
    utcoff: 0,  $
    wnddiroff: 0.,  $
    compt2: 0d}
template1 = create_struct('hhmm', '', 'ss', '', template)
template2 = create_struct('time', '', template)
  
if (comet ne '1') then begin
  nhead = 4
  nlines = file_lines(file)
  nrec = (nlines-nhead)/2

  elems = strarr(n_tags(template1))
    
  data = replicate(template2, nrec)
  
  openr, lun, file,/get_lun

  rec1 = ''
  rec2 = ''
  for i=1,nhead do readf, lun, rec1

  for i=0L,nrec-1 do begin
    readf, lun, rec1  &  readf, lun, rec2
    rec = rec1+rec2
    null = strip(rec, elems, comet)
    
    data_rec = fill_temp(template1,elems)      ; Creates another structure (data_rec)

    data[i].time = data_rec.hhmm.substring(0,3)+data_rec.ss
    for j=1,n_tags(template2)-1 do data[i].(j) = data_rec.(j+1)      ; j+1 because template1 is larger than template2.  data_rec defined using template1 and data defined using template2
  endfor
 
  free_lun, lun
endif else begin
  file_gps = file
  file_flx = file.Replace('gpsraw','fluxraw')
  file_prs = file.Replace('gpsraw','pressureraw')
  file_thv = file.Replace('gpsraw','thvraw')
  
  lines_flx = file_lines(file_flx)-1
  lines_prs = file_lines(file_prs)-1
  lines_thv = file_lines(file_thv)-1
  
  gps = read_comet1_ascii_gps(file_gps)

  if (n_elements(gps.gprmc) + n_elements(gps.gpgga) + n_elements(gps.pgrme) ne 3L*n_elements(gps.gprmc)) then begin
    print, ' <----> Number of elements in the three gps messages are different:'
    print, ' <----> GPRMC: ', n_elements(gps.gprmc)
    print, ' <----> GPGGA: ', n_elements(gps.gpgga)
    print, ' <----> PRGME: ', n_elements(gps.pgrme)
    stop
  endif

; The PGRME epoch time is COMPUTER_TIME_GPS in the full data
  t = dblarr(n_elements(gps.pgrme))
  for i=0L,n_elements(gps.pgrme)-1 do begin
    rec = strsplit(gps.pgrme[i],',',/extract,/preserve_null)
    t[i] = double(rec[7])
  endfor
  
  gps = create_struct(gps, 'epoch_time', t)

  rec = ''
  
;===
; Read fluxgate compass data
;===
  flx = {fluxdir: fltarr(lines_flx), epoch_time: dblarr(lines_flx)}
  flx_str = strarr(lines_flx)
  openr, lun, file_flx, /get_lun
  readf, lun, rec   ; Header
  readf, lun, flx_str
  free_lun, lun
  for i=0L,lines_flx-1 do begin
    s = strsplit(flx_str[i],',',/extract,/preserve_null)
    if (s[0] eq '') then begin
      flx.fluxdir[i] = !values.f_nan
    endif else begin
      flx.fluxdir[i] = float(s[0])
    endelse
    flx.epoch_time[i] = double(s[1])
  endfor

;===
; Read pressure data.  Epoch computer time for pressure in the full data is truncated (not rounded) to the tenths digit so the same
;  needs to be done here.
;===
  prs = {pres: fltarr(lines_prs), epoch_time: dblarr(lines_prs)}
  prs_str = strarr(lines_prs)
  openr, lun, file_prs, /get_lun
  readf, lun, rec   ; Header
  readf, lun, prs_str
  free_lun, lun
  for i=0L,lines_prs-1 do begin
    s = strsplit(prs_str[i],',',/extract,/preserve_null)
    if (s[0] eq '') then begin
      prs.pres[i] = !values.f_nan
    endif else begin
      prs.pres[i] = float(s[0])
    endelse
    prs.epoch_time[i] = double(s[1].substring(0,s[1].indexof('.')+1))
  endfor

;===
; Read thv data
;===
  thv = {time: strarr(lines_thv),  $      ;hhmmss.s
    temp_f: fltarr(lines_thv),  $
    temp_s: fltarr(lines_thv),  $      ; C
    rh_s: fltarr(lines_thv),  $        ; %
    wndspdraw: fltarr(lines_thv),  $   ; m/s
    wnddirraw: fltarr(lines_thv),  $
    epoch_time: dblarr(lines_thv)} 

  openr, lun, file_thv,/get_lun

  readf, lun, rec   ; header

  for i=0L,lines_thv-1 do begin
    readf, lun, rec
    nelem = 20
    elems = strarr(nelem)

    null = strip(rec, elems, comet)

    thv.time[i]       = elems[1].substring(0,3)+elems[2]
    thv.temp_f[i]     = float(elems[4])
    thv.temp_s[i]     = float(elems[5])
    thv.rh_s[i]       = float(elems[6])
    thv.wndspdraw[i]  = float(elems[8])
    thv.wnddirraw[i]  = float(elems[9])
    thv.epoch_time[i] = double(elems[19])
  endfor
  free_lun, lun
 
;===
; Sync the raw data
;  This version of syncing uses the full data, which has the epoch times corresponding to the reccord from each raw file.  This 
;   won't work if the raw data are to be used to fill in missing full data.  For this reason, derived state variables are not
;   calculated here.
;=== 
  print, ' <----> Syncing CoMeT-1 data'
  file_full = file.Replace('gpsraw','full')
  read_comet_ascii, file_full, fileformat, full, name_std, name_long, units, source, /quiet
  n = n_elements(full)
  
  data = replicate(template2, n)      ; Data will be the size of the full data
  
  i_thv = 0L  &  bad_thv = 0L
  i_gps = 0L  &  bad_gps = 0L
  i_flx = 0L  &  bad_flx = 0L
  i_prs = 0L  &  bad_prs = 0L

  for i=0L,n-1 do begin
    bad = sync_scenarios(thv, data, full.computer_time_thv      , i_thv, i, ['TIME', 'TEMP_F', 'TEMP_S', 'RH_S', 'WNDSPDRAW', 'WNDDIRRAW'])
    bad_thv = bad_thv + bad
  endfor

  for i=0L,n-1 do begin
    bad = sync_scenarios(prs, data, full.computer_time_pressure, i_prs, i, ['PRES'])
    bad_prs = bad_prs + bad
  endfor

  for i=0L,n-1 do begin
    bad = sync_scenarios(flx, data, full.computer_time_fluxgate, i_flx, i, ['FLUXDIR'])
    bad_flx = bad_flx + bad
  endfor
  
  for i=0L,n-1 do begin
    bad = sync_scenarios(gps, data, full.computer_time_gps     , i_gps, i, ['GPRMC', 'GPGGA'])
    bad_gps = bad_gps + bad
  endfor

  print, ' <------> NaN records created syncing THV data: ', bad_thv
  print, ' <------> NaN records created syncing PRS data: ', bad_prs
  print, ' <------> NaN records created syncing FLX data: ', bad_flx
  print, ' <------> NaN records created syncing GPS data: ', bad_gps  
endelse

return, data
bad:
  print, ' <!!!!!!> ', !error_state.msg, ' STOPPING'
  stop
end

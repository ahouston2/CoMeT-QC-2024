;================================================================================================
; Version 3:
;  * Combining all data into a single structure (ealier versions had separate arrays for some stuff.
;  * Reworking naming conventions
;================================================================================================

pro read_comet_ascii, file, fileformat,  $
 data,  $
 standard_name,  $
 long_name,  $
 units,  $
 instruments,  $
 quiet=quiet
 
if (~ keyword_set(quiet)) then begin
  print, ' <> Processing CoMeT:  ', fileformat.comet
  print, ' <> Version:           ', fileformat.version
  print, ' <> QC status:         ', fileformat.qc
endif

;===
; Retrieve format information based on fileformat structure.  frmt_elem should equal the number of elements in each 
;  record of the data file.
;===
frmt = comet_get_format(fileformat)
frmt_elem = n_elements(frmt.(0))
frmttags = tag_names(frmt)

;===
; Collect data into data structure
;===
;nrec = file_lines(file)-frmt.headerlines[0]
;for j=0,frmt_elem-1 do begin
;  if (frmt.type[j] eq 'string') then arr = strarr(nrec)
;  if (frmt.type[j] eq 'float')  then arr = fltarr(nrec)
;  if (frmt.type[j] eq 'long')   then arr = lonarr(nrec)
;  if (frmt.type[j] eq 'double') then arr = dblarr(nrec)

;  if (j eq 0) then begin
;    data = create_struct(frmt.parameter_name[j], arr)
;  endif else begin
;    data = create_struct(data, frmt.parameter_name[j], arr)
;  endelse
;endfor

;===
; Concatentate instrument names
;===
instruments = strarr(frmt_elem)
instrtags = where(frmttags.contains('INSTRUMENT'),cnt)
for j=0,frmt_elem-1 do begin
  for k=0,cnt-1 do begin
    if (frmt.(instrtags[k])[j] ne '') then begin
      if (k eq 0) then begin
        instruments[j] = frmt.(instrtags[k])[j]
      endif else begin
        instruments[j] = instruments[j]+', '+frmt.(instrtags[k])[j]
      endelse
    endif
  endfor
endfor

;===
; Open the file and start reading data. read_csv organizes the data as a structure of arrays instead of an array of structures.
;  The latter is how I've always organzied the data so a conversion must occur.
;===
if (~keyword_set(quiet)) then print, " <> Reading data from ",file
data_in = read_csv(file, n_table_header=frmt.headerlines[0], types=frmt.type, count=nrec)

; Creates a template structure that's used to create the array of structures
for j=0,frmt_elem-1 do begin
  if (j eq 0) then begin
    template = create_struct(          frmt.parameter_name[j],data_in.(j)[0])
  endif else begin
    template = create_struct(template, frmt.parameter_name[j],data_in.(j)[0])
  endelse
endfor

;===
; Add epoch and u, v to the arrays and data structure
;===
template = create_struct(template,           "epoch_time", 0d,                    "u", 0.,         "v", 0.)
standard_name =         [frmt.standard_name, "time",                              "eastward_wind", "northward_wind"]
long_name     =         [frmt.long_name,     "Epoch time",                        "u",             "v"]
units         =         [frmt.units,         "seconds since 1970-01-01 00:00:00", "m/s",           "m/s"]

pos = where(standard_name eq "TIME_STRING")  &  pos = pos[0]
inst_time = instruments[pos]
pos = where(standard_name eq "WIND_SPEED")  &  pos = pos[0]
inst_u = instruments[pos]
inst_v = instruments[pos]

instruments   =         [instruments,        inst_time,                           inst_u,          inst_v]

;===
; Fill the data structure and apply standard corrections.
;===
data = replicate(template, nrec)
for i=0,nrec-1 do begin
  for j=0,frmt_elem-1 do begin
    data[i].(j) = data_in.(j)[i] 
    if (frmt.mult_fact[j] ne 1.) then data[i].(j) = data[i].(j) * frmt.mult_fact[j]
    if (frmt.add_fact[j]  ne 0.) then data[i].(j) = data[i].(j) + frmt.add_fact[j]
  endfor
endfor

;===
; Calculate epoch time, u, and v and add them to the data structure
;===
etime = dblarr(nrec)
for i=0,nrec-1 do begin
  if (fileformat.comet eq '1' and fileformat.qc eq 'qcd' and (fileformat.version eq '2016' or fileformat.version eq '2017')) then begin
    yr = fix(strmid(data[i].date,0,4))
    mo = fix(strmid(data[i].date,4,2))
    dy = fix(strmid(data[i].date,6,2))
  endif else begin
    yr = fix(strmid(data[i].date,4,2))+2000
    mo = fix(strmid(data[i].date,2,2))
    dy = fix(strmid(data[i].date,0,2))
  endelse
  hr = fix(strmid  (data[i].time,0,2))
  mn = fix(strmid  (data[i].time,2,2))
  ss = float(strmid(data[i].time,4))

  data[i].epoch_time  = epoch(yr,mo,dy,hr,mn,ss)

  data[i].u = -data[i].wind_speed*sin(!pi*data[i].wind_direction/180.)
endfor

end

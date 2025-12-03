;================================================================================================
; Reads GPS data from raw gps file.  
; GPRMC
; GPGGA
; PGRME  
;================================================================================================

function read_comet1_ascii_gps, file

nlines = file_lines(file)
gprmc = strarr(nlines)
gpgga = strarr(nlines)
pgrme = strarr(nlines)

openr, lun, file,/get_lun

rec = ''
igprmc = 0L
igpgga = 0L
ipgrme = 0L
for j=0l,nlines-1 do begin
  readf, lun, rec
  if (rec.contains('$GPRMC')) then begin
    gprmc[igprmc] = rec
    igprmc ++
  endif else if (rec.contains('$GPGGA')) then begin
    gpgga[igpgga] = rec
    igpgga ++
  endif else if (rec.contains('$PGRME')) then begin
    pgrme[ipgrme] = rec
    ipgrme ++
  endif
endfor
free_lun, lun

gps = {gprmc: gprmc[0:igprmc-1],  $
       gpgga: gpgga[0:igpgga-1],  $
       pgrme: pgrme[0:ipgrme-1]} 

return, gps
end

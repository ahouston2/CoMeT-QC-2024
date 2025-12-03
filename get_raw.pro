;===================================
; Get raw data.
; For CoMeTs 2, 3, and alpha, the raw data are already synced in the raw data file.  The raw data file might have a different number of
;  records than the full file (full file may have missing data, etc.) but any use of the raw data is by comparing epoch time to
;  times in the gps strings so there's no assumption that the records in full and raw are matched.
; For CoMeT 1, raw data are distributed across multiple files.  Syncing has to be done in the code stack here.
;===================================
function get_raw, comet, fileformat, file, gprmc, gpgga

  if (comet ne '1') then begin
    file_raw = file.Replace('full', 'raw')
    data_raw = read_comet_raw(file_raw,comet,fileformat)
    n = n_elements(data_raw)
  endif else begin
    file_raw = file.Replace('full', 'gpsraw')
    file_raw = file_raw.Replace('CoMeT1_gpsraw', 'IMeT1_gpsraw')
    data_raw = read_comet_raw(file_raw,comet,fileformat)
  endelse

  gprmc_str = data_raw[*].gprmc
  gpgga_str = data_raw[*].gpgga

  ;===
  ; Create the gprmc and gpgga structures
  ;===
  gprmc = create_gps_struct(gprmc_str,'gprmc')        ; Will automatically be the same size as data_raw array
  gpgga = create_gps_struct(gpgga_str,'gpgga')

  return, data_raw
end
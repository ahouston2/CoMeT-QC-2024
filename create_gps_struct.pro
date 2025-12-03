;===================================
; Create gps structure
;
; Type: 'gprmc' or 'gpgga'
;===================================

function create_gps_struct, gps_str, type

  for j=0,n_elements(gps_str)-1 do begin
    if (j eq 0) then begin
      if (type eq 'gprmc') then temp = read_gprmc(gps_str[j])
      if (type eq 'gpgga') then temp = read_gpgga(gps_str[j])
      gps = replicate(temp,n_elements(gps_str))
    endif else begin
      if (type eq 'gprmc') then gps[j] = read_gprmc(gps_str[j])
      if (type eq 'gpgga') then gps[j] = read_gpgga(gps_str[j])
    endelse
  endfor

  return, gps
end


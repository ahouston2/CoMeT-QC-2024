;=======================================================================================================================
; veh_track: [degrees] From GPS (direction towards which vehicle is moving -- to the east would be 90 deg)
; veh_spd: [knots]
; anem_dir: [degrees] Raw direction
; anem_spd: [m/s] Raw speed
; anem_dir_off: [degrees] Offset to get vehicle-relative anemometer direction
; wind_spd: [m/s] Derived wind speed
; wind_dir: [degrees] Derived wind direction
; u: [m/s]
; v: [m/s]
;=======================================================================================================================

function get_comet_wind_from_raw, veh_track, veh_spd, anem_dir, anem_spd, anem_dir_off, wind_spd, wind_dir, u, v

;===
; Convert heading to radians (using meteorological coordinates).
; track is the direction towards which the vehicle is moving (to the east would be 90).
;===
  head = veh_track - 180.
  if (head lt 0) then head = head + 360
  head = head * !dtor

;===
; Calculate vehicle translation.  This the flipped version of u and v (positve would be towards the west/south)
;===
  trans = veh_spd*0.514444*[sin(head),cos(head)]

;===
; Calculate apparent wind.  This is the raw wind direction relative to the met coordinate system, taking into account the
;  GPS heading, and then flipped to get headwind
;===
  winddir_app = anem_dir - anem_dir_off + veh_track - 180.
  if (winddir_app lt 0) then winddir_app = winddir_app + 360.
  winddir_app = winddir_app * !dtor
  app = anem_spd * [sin(winddir_app),cos(winddir_app)]

;===
; The difference
;===
  diff = trans - app

  if (diff[0] ge 0) then wind_dir = 90.  - !radeg * atan(diff[1],diff[0])
  if (diff[0] lt 0) then wind_dir = 450. - !radeg * atan(diff[1],diff[0])
  if (wind_dir gt 360.) then wind_dir = wind_dir - 360.

  wind_spd = sqrt(diff[0]^2 + diff[1]^2)
  u = -diff[0]
  v = -diff[1]
  
 end
  
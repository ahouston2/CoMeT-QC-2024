pro comet_ascii_2_cfnetcdf_torus_v2, batch=batch,  $
 data=data, global=global, file_in=file_in, file_out=file_out, fileformat=fileformat, errstring=errstring, errval=errval

;on_ioerror, bad

;=============================================================================================================
; April 2024 updates
;   * This is verion torus_v2
;   * Uses the CoMeT_data_format spreadsheet to find data formatting information.
;   * The variable names in the cdf file are hardcoded and won't match the parameter_name in the spreadsheet.
;     This is because the names used in the 2019 data are different.  FUTURE VERSIONS OF THIS ROUTINE need to
;     use the parameter_name from the spreadsheet.
;   * The variable attributes are compiled from the spreadsheet within the read_comet_ascii routine.  Some of
;     these will be slightly different from the version created by Kristen in the previous 2019 cdf files.
;   * Some of the global attributes will be different between the data created with this routine and the ones
;     created by Kristen for 2019.   
;   * If batch is set then need the rest of the agruments ESPECIALLY data.  
; 
; data: Structure with the same format as what comes out of read_comet_ascii
; global: Structure (see below)
; fileformat: Structure (see below)
; file_in and file_out: Should have paths
; errstring: Same size as data array.
; errval: The fill value for missing data
; 
; It's assumed that water vapor mixing ratio in the data structure is in g/kg and it's converted here to g/g
;=============================================================================================================

if (~ keyword_set(batch)) then begin
  global = {title: '2016-06-20 Combined Mesonet and Tracker (CoMeT-1) synchronized data file',  $
            source: 'Combined Mesonet and Tracker #1 (CoMeT1)',  $
            institution: 'University of Nebraska-Lincoln',  $
            comment: 'PI Contact Info: Adam Houston (ahouston2@unl.edu)'}

  path = "C:\Users\ahouston2\OneDrive - University of Nebraska-Lincoln\Field Data\TORUS\20190528\CoMeT-1\QC'd data\"
  path = "C:\Users\ahouston2\OneDrive - University of Nebraska-Lincoln\Field Data\MAHTE_2016\20160620\IMeT\"
  file_in = path+'MobileMesonetlog_062016_1630_Corrected.csv'
  file_out = path+'20160620_1630_CoMeT1.nc'
  fileformat = {comet: 1,  $
                version: '2016',  $
                qc: 'raw'}
  read_comet_ascii, file_in, fileformat, data, etime, name_std, name_long, units, source
endif

nm = n_elements(data)

ncid   = NCDF_CREATE(file_out,/CLOBBER,/NETCDF4_FORMAT)
timedimid = NCDF_DIMDEF(ncid,'time_dim',nm)

pos = where(tag_names(data[0]) eq 'EPOCH_TIME')  &  time = data.(pos[0])
 timeid = NCDF_VARDEF(ncid, 'time', [timedimid], /double)
 NCDF_ATTPUT, ncid, timeid, '_FillValue', errval, /double
 NCDF_ATTPUT, ncid, timeid, 'source', 'Garmin GPS', /char
 NCDF_ATTPUT, ncid, timeid, 'standard_name', 'time', /char
 NCDF_ATTPUT, ncid, timeid, 'long_name', 'Seconds since 00:00:00, 01-01-1970', /char
 NCDF_ATTPUT, ncid, timeid, 'units', 'seconds', /char

pos = where(tag_names(data[0]) eq 'ALTITUDE')  &  alt = data.(pos[0])
 altid = NCDF_VARDEF(ncid, 'alt', [timedimid], /float)
 NCDF_ATTPUT, ncid, altid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, altid, 'source', 'Garmin GPS', /char
 NCDF_ATTPUT, ncid, altid, 'standard_name', 'altitude', /char
 NCDF_ATTPUT, ncid, altid, 'long_name', 'Height above mean sea level', /char
 NCDF_ATTPUT, ncid, altid, 'units', 'meters', /char

pos = where(tag_names(data[0]) eq 'LATITUDE')  &  lat = data.(pos[0])
 latid = NCDF_VARDEF(ncid, 'lat', [timedimid], /float)
 NCDF_ATTPUT, ncid, latid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, latid, 'source', 'Garmin GPS', /char
 NCDF_ATTPUT, ncid, latid, 'standard_name', 'latitude', /char
 NCDF_ATTPUT, ncid, latid, 'long_name', 'Latitude', /char
 NCDF_ATTPUT, ncid, latid, 'units', 'degrees_north', /char

pos = where(tag_names(data[0]) eq 'LONGITUDE')  &  lon = data.(pos[0])
 lonid = NCDF_VARDEF(ncid, 'lon', [timedimid], /float)
 NCDF_ATTPUT, ncid, lonid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, lonid, 'source', 'Garmin GPS', /char
 NCDF_ATTPUT, ncid, lonid, 'standard_name', 'longitude', /char
 NCDF_ATTPUT, ncid, lonid, 'long_name', 'Longitude', /char
 NCDF_ATTPUT, ncid, lonid, 'units', 'degrees_east', /char

pos = where(tag_names(data[0]) eq 'TEMPERATURE_FAST')  &  tfast = data.(pos[0]) + 273.15
 tfid = NCDF_VARDEF(ncid, 'fast_temp', [timedimid], /float)
 NCDF_ATTPUT, ncid, tfid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, tfid, 'source', 'Campbell Scientific 10922-L Thermistor', /char
 NCDF_ATTPUT, ncid, tfid, 'standard_name', 'air_temperature', /char
 NCDF_ATTPUT, ncid, tfid, 'long_name', 'Air Temperature (Fast Response)', /char
 NCDF_ATTPUT, ncid, tfid, 'units', 'Kelvin', /char

pos = where(tag_names(data[0]) eq 'TEMPERATURE_SLOW')  &  tslow = data.(pos[0]) + 273.15
 tsid = NCDF_VARDEF(ncid, 'slow_temp', [timedimid], /float)
 NCDF_ATTPUT, ncid, tsid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, tsid, 'source', 'Vaisala HMP155A-L-PT', /char
 NCDF_ATTPUT, ncid, tsid, 'standard_name', 'air_temperature', /char
 NCDF_ATTPUT, ncid, tsid, 'long_name', 'Air Temperature (Slow Response)', /char
 NCDF_ATTPUT, ncid, tsid, 'units', 'Kelvin', /char

pos = where(tag_names(data[0]) eq 'PRESSURE')  &  pres = 100.*data.(pos[0])
 pid = NCDF_VARDEF(ncid, 'pressure', [timedimid], /float)
 NCDF_ATTPUT, ncid, pid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, pid, 'source', 'Vaisala PTB210 Barometer', /char
 NCDF_ATTPUT, ncid, pid, 'standard_name', 'air_pressure', /char
 NCDF_ATTPUT, ncid, pid, 'long_name', 'Air Pressure', /char
 NCDF_ATTPUT, ncid, pid, 'units', 'Pascals', /char

pos = where(tag_names(data[0]) eq 'RH_SLOW')  &  rh = data.(pos[0])
 rhsid = NCDF_VARDEF(ncid, 'logger_RH', [timedimid], /float)
 NCDF_ATTPUT, ncid, rhsid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, rhsid, 'source', 'Vaisala HMP155A-L-PT', /char
 NCDF_ATTPUT, ncid, rhsid, 'standard_name', 'relative_humidity', /char
 NCDF_ATTPUT, ncid, rhsid, 'long_name', 'Logger Relative Humidity', /char
 NCDF_ATTPUT, ncid, rhsid, 'units', 'percent', /char

pos = where(tag_names(data[0]) eq 'RH_FAST')  &  rh_corr = data.(pos[0])
 rhfid = NCDF_VARDEF(ncid, 'calc_corr_RH', [timedimid], /float)
 NCDF_ATTPUT, ncid, rhfid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, rhfid, 'standard_name', 'relative_humidity', /char
 NCDF_ATTPUT, ncid, rhfid, 'long_name', 'Calculated Corrected Relative Humidity (using Fast Temperature)', /char
 NCDF_ATTPUT, ncid, rhfid, 'units', 'percent', /char

pos = where(tag_names(data[0]) eq 'WIND_SPEED')  &  windspd = data.(pos[0])
 wsid = NCDF_VARDEF(ncid, 'wind_speed', [timedimid], /float)
 NCDF_ATTPUT, ncid, wsid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, wsid, 'standard_name', 'wind_speed', /char
 NCDF_ATTPUT, ncid, wsid, 'long_name', 'Calculated Wind Speed', /char
 NCDF_ATTPUT, ncid, wsid, 'units', 'meters per second', /char

pos = where(tag_names(data[0]) eq 'WIND_DIRECTION')  &  winddir = data.(pos[0])
 wdid = NCDF_VARDEF(ncid, 'wind_dir', [timedimid], /float)
 NCDF_ATTPUT, ncid, wdid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, wdid, 'standard_name', 'wind_from_direction', /char
 NCDF_ATTPUT, ncid, wdid, 'long_name', 'Calculated Wind From Direction', /char
 NCDF_ATTPUT, ncid, wdid, 'units', 'degrees', /char

pos = where(tag_names(data[0]) eq 'VEHICLE_HEADING')  &  vehdir = data.(pos[0])
 vehid = NCDF_VARDEF(ncid, 'vehicle_dir', [timedimid], /float)
 NCDF_ATTPUT, ncid, vehid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, vehid, 'source', 'Garmin GPS', /char 
 NCDF_ATTPUT, ncid, vehid, 'long_name', 'Mesonet Vehicle Heading', /char
 NCDF_ATTPUT, ncid, vehid, 'units', 'degrees', /char

pos = where(tag_names(data[0]) eq 'DEWPOINT')  &  td = data.(pos[0])
 tdid = NCDF_VARDEF(ncid, 'dewpoint', [timedimid], /float)
 NCDF_ATTPUT, ncid, tdid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, tdid, 'standard_name', 'dew_point_temperature', /char
 NCDF_ATTPUT, ncid, tdid, 'long_name', 'Calculated Dew Point Temperature', /char
 NCDF_ATTPUT, ncid, tdid, 'units', 'Kelvin', /char

pos = where(tag_names(data[0]) eq 'WATER_VAPOR_MIXING_RATIO')  &  qv = 0.001*data.(pos[0])
 qvid = NCDF_VARDEF(ncid, 'mixing_ratio', [timedimid], /float)
 NCDF_ATTPUT, ncid, qvid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, qvid, 'standard_name', 'humidity_mixing_ratio', /char
 NCDF_ATTPUT, ncid, qvid, 'long_name', 'Calculated Mixing Ratio', /char
 NCDF_ATTPUT, ncid, qvid, 'units', '1', /char

pos = where(tag_names(data[0]) eq 'THETA')  &  thta = data.(pos[0])
 thid = NCDF_VARDEF(ncid, 'theta', [timedimid], /float)
 NCDF_ATTPUT, ncid, thid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, thid, 'standard_name', 'air_potential_temperature', /char
 NCDF_ATTPUT, ncid, thid, 'long_name', 'Calculated Potential Temperature (Theta)', /char
 NCDF_ATTPUT, ncid, thid, 'units', 'Kelvin', /char

pos = where(tag_names(data[0]) eq 'THETA_V')  &  thtav = data.(pos[0])
 thvid = NCDF_VARDEF(ncid, 'theta_v', [timedimid], /float)
 NCDF_ATTPUT, ncid, thvid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, thvid, 'standard_name', 'virtual_potential_temperature', /char
 NCDF_ATTPUT, ncid, thvid, 'long_name', 'Calculated Virtual Potential Temperature (Theta_V)', /char
 NCDF_ATTPUT, ncid, thvid, 'units', 'Kelvin', /char

pos = where(tag_names(data[0]) eq 'THETA_E')  &  thtae = data.(pos[0])
 theid = NCDF_VARDEF(ncid, 'theta_e', [timedimid], /float)
 NCDF_ATTPUT, ncid, theid, '_FillValue', errval, /float
 NCDF_ATTPUT, ncid, theid, 'standard_name', 'equivalent_potential_temperature', /char
 NCDF_ATTPUT, ncid, theid, 'long_name', 'Calculated Equivalent Potential Temperature (Theta_E)', /char
 NCDF_ATTPUT, ncid, theid, 'units', 'Kelvin', /char

 if (fileformat.qc eq 'qcd') then begin
  pos = where(tag_names(data[0]) eq 'ERRSTRING')
  errid = NCDF_VARDEF(ncid, 'error_flag', [timedimid], /string)
  NCDF_ATTPUT, ncid, errid, 'long_name', 'Error string', /char
 endif
 
NCDF_ATTPUT, ncid, 'title', global.title, /global, /char
NCDF_ATTPUT, ncid, 'institution', global.institution, /global, /char
NCDF_ATTPUT, ncid, 'source', global.source, /global, /char
NCDF_ATTPUT, ncid, 'comment', global.comment, /global, /char
NCDF_CONTROL, ncid, /ENDEF

NCDF_VARPUT, ncid, timeid, time
NCDF_VARPUT, ncid, altid,  alt
NCDF_VARPUT, ncid, latid,  lat
NCDF_VARPUT, ncid, lonid,  lon
NCDF_VARPUT, ncid, tfid,   tfast
NCDF_VARPUT, ncid, tsid,   tslow
NCDF_VARPUT, ncid, pid,    pres
NCDF_VARPUT, ncid, rhsid,  rh
NCDF_VARPUT, ncid, rhfid,  rh_corr
NCDF_VARPUT, ncid, wsid,   windspd
NCDF_VARPUT, ncid, wdid,   winddir
NCDF_VARPUT, ncid, vehid,  vehdir
NCDF_VARPUT, ncid, tdid,   td
NCDF_VARPUT, ncid, qvid,   qv
NCDF_VARPUT, ncid, thid,   thta
NCDF_VARPUT, ncid, thvid,  thtav
NCDF_VARPUT, ncid, theid,  thtae
if (fileformat.qc eq 'qcd') then NCDF_VARPUT, ncid, errid,  errstring
  
NCDF_CLOSE, ncid

;bad:
;  print, ' <!!!!!!> ', !error_state.msg, ' STOPPING'
;  stop

end

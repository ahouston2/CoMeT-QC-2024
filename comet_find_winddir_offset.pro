;=============================================================================================================
; Wind dirrection offset is not stored in the raw THV file for CoMeT1 but in gpsraw
;=============================================================================================================
pro comet_find_winddir_offset, noplot=noplot, data_raw=data_raw, gprmc=gprmc

spdthresh = 40.
off0 = -20.
off1 = 270.
doff = 1.
noff = 1 + (off1-off0)/doff
off = off0 + doff*findgen(noff)

if (~keyword_set(data_raw)) then begin
  rawfile = "C:\Users\ahouston2\OneDrive - University of Nebraska\Field Data\MITTEN-CI\20240707\CoMeT-alpha\Original data\CoMeTalpha_raw_20240707_1135.txt"
;  rawfile = "C:\Users\ahouston2\OneDrive - University of Nebraska-Lincoln\Field Data\LAPSE-RATE\20180719\CoMeT-1\Original data\IMeT1_gpsraw_20180719_1105.txt"]

  fileformat = {comet: '2',  $
    version: '2024',  $
    qc: 'orig'}

  data_raw = get_raw(fileformat.comet, fileformat, rawfile, gprmc, gpgga)
  print, ' <--> Checking wind_dir_offset for file ',rawfile
endif

meanspd = fltarr(noff)

nrec = n_elements(gprmc)

movpos = where(gprmc.spd gt spdthresh,movcnt)    ; where the vehicle is moving more than 40 kts

print, ' <----> ',movcnt,' of',nrec,' points in the window have vehicle speeds greater than',spdthresh,' kts'

if (movcnt eq 0) then begin
  print, ' <!!!!> Cannot calculate offset'
endif else begin
  spd = fltarr(movcnt)

;===
; Get all data when vehicle is moving (fast)
;===
  for i=0L,noff-1 do begin
    for j=0L,movcnt-1 do begin
      null = get_comet_wind_from_raw(gprmc[movpos[j]].track, gprmc[movpos[j]].spd, data_raw[movpos[j]].wnddirraw, data_raw[movpos[j]].wndspdraw, off[i], wind_spd, wind_dir, u_tmp, v_tmp)
      spd[j] = wind_spd
    endfor
    meanspd[i] = mean(spd)
  endfor

  mnmean = min(meanspd, mnmeanpos)

  print, ' <--> Minimum mean speed of', mnmean,' at off of', off[mnmeanpos]
  print, ' <--> Original offset used', data_raw[0].wnddiroff

  if (~ keyword_set(noplot)) then begin

    ump = plot(off,meanspd,  $
      title='Mean Wind Speed',  $
      xtitle='Offset Angle (degrees)',  $
      ytitle='Speed (m/s)',  $
      layout=[2,1,1], dimensions=[1200,600])

    spdnew = fltarr(nrec)
    dirnew = fltarr(nrec)
    unew = fltarr(nrec)
    vnew = fltarr(nrec)
    jday = dblarr(nrec)
    for j=0,nrec-1 do begin
      null = get_comet_wind_from_raw(gprmc[j].track, gprmc[j].spd, data_raw[j].wnddirraw, data_raw[j].wndspdraw, off[mnmeanpos], wind_spd, wind_dir, u_tmp, v_tmp)
      spdnew[j] = wind_spd
      dirnew[j] = wind_dir
      unew[j] = u_tmp
      vnew[j] = v_tmp
      epoch2datetime, gprmc[j].time, yr,mo,dy,hr,mn,ss
      jday[j] = julday(mo,dy,yr,hr,mn,ss)
    endfor

    up = plot(jday,data_raw.wndspd,title='Original (black), New (red) Wind Speed',  $
      xtickformat = '(C(CHI2.2,":",CMI2.2,":",CSI2.2))',  $
      xtitle='Time',  $
      ytitle='Speed (m/s)',  $
      layout=[2,1,2],/current)
    unewp  = plot(jday,spdnew   ,color='r',/over)
  endif
endelse

end

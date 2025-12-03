pro comet_mergeqcd_createncdf_2024

;read catalog
;Sort by date (just get the uniq indices)
;Sort the subarray by comet (just get the uniq indices)
;Build file names
;Find the matching qc'd files
;Build the new err_str_filename matching the error strings in all of the actual file names with the error strings in the catalog (ensures correct ordering)


catalog = 'C:\Users\ahouston2\OneDrive - University of Nebraska\Field Data\comet_qc_2024.csv'
dir_template = 'C:\Users\ahouston2\OneDrive - University of Nebraska\Field Data\[project]\[YYYYMMDD]\CoMeT-[*]\[type]\'


errval = -999.

; This order matters because it needs to match the catalog order.
choice = {project: 'all',  $
  year: 'all',  $
  month: 'all',  $
  day: 'all',  $
  time: 'all',  $
  site: 'all',  $
  comet: 'all'}

ntags = n_tags(choice)

ans = ''
read, ans,       prompt=' -> Enter the project or "all": '  &  choice.project = ans
if (choice.project ne 'all') then begin
  if (choice.project eq 'MITTEN-CI') then begin
    read, ans,   prompt=' -> Enter the day or "all":     '  &  choice.day = ans
    if (choice.day ne 'all') then begin
      read, ans, prompt=' -> Enter the time or "all":    '  &  choice.time = ans
    endif
    read, ans,   prompt=' -> Enter the CoMeT or "all":   '  &  choice.comet = ans
  endif else if (choice.project eq 'SCALES') then begin
    read, ans,   prompt=' -> Enter the day or "all":     '  &  choice.day = ans
    if (choice.day ne 'all') then begin
      read, ans, prompt=' -> Enter the site or "all":    '  &  choice.site = ans
    endif
  endif
endif

;======================================================
; Read in the catalog
;======================================================
stuff = read_csv(catalog, count=catcnt, header=catheader)
catdata = tag_rename(stuff,catheader)
catdata_orig = catdata

pos = where(strpos(catheader,'FLAG') ge 0,cnt)

for k=0,cnt-1 do begin
  f = catheader[pos[k]].substring(5)
  if (k eq 0) then begin
    flags = create_struct(       f,catdata.(pos[k]))
  endif else begin
    flags = create_struct(flags, f,catdata.(pos[k]))
  endelse
endfor

flag_names = tag_names(flags)
nflags = n_elements(flag_names)

catdata = create_struct(catdata, 'date_str', string(catdata.year,format='(i4.4)') + string(catdata.month,format='(i2.2)') + string(catdata.day,format='(i2.2)'),  $
  'time_str', string(catdata.time,format='(i4.4)'))

;===
; Find the files to process based on the user-input
;===
n = n_elements(catdata.project)
check = bytarr(n)
good  = bytarr(n) 
for i=0,ntags-1 do begin
  check[*] = 0
  if (choice.(i) ne 'all') then begin
    pos = where(catdata.(i) eq choice.(i),cnt)
    if (cnt gt 0) then check[pos] = 1
  endif else begin
    check[*] = 1
  endelse
  good = good + check
endfor

goodpos = where(good eq ntags,nf)

dir = strarr(nf)
file = strarr(nf)

;===
; Collect all of the files for merging
;===
for i=0,nf-1 do begin
  catpos = goodpos[i]
  comet = catdata.comet[catpos]
  if (typename(catdata.comet) eq 'INT') then begin
    comet_str = string(catdata.comet[catpos], format='(i1)')
  endif else begin
    comet_str = catdata.comet[catpos]
  endelse

  dir[i] = dir_template.replace('[project]',catdata.project[catpos])

;===
; There is a scenario where the the start time of the file is after 0Z (so the date has advanced) but the LT date
;  is the day before.  This deals with this possibility (it will work even if month or year change when backing
;  up to the previous day)
;===
  if (fix(catdata.time_str[catpos]) lt 600) then begin
    yr = catdata.date_str[catpos].substring(0,3)
    mo = catdata.date_str[catpos].substring(4,5)
    dy = catdata.date_str[catpos].substring(6,7)
    ep = epoch(yr,mo,dy,0,0,0)
    epoch2datetime, ep-3600, yr, mo, dy, hr, mn, ss
    newdate = string(yr,format='(i4.4)') + string(mo,format='(i2.2)') + string(dy,format='(i2.2)')
    dir[i] = dir[i].replace('[YYYYMMDD]',newdate)
  endif else begin
    dir[i] = dir[i].replace('[YYYYMMDD]',catdata.date_str[catpos])
  endelse
  dir[i] = dir[i].replace('[*]',comet_str)
  dir[i] = dir[i].replace('[type]',"QC'd data")
  if (catdata.project[catpos] eq 'SCALES') then begin
    dir[i] = dir[i].replace('CoMeT',catdata.site[catpos]+'\CoMeT')
  endif

;===
; Collect active flags into an array
;===
  firstflag = 0
  for fidx=0,nflags-1 do begin
    if (flags.(fidx)[catpos] ne 'no') then begin
      if (firstflag eq 0) then begin
        firstflag = 1
        flag_active = [flag_names[fidx]]
      endif else begin
        flag_active = [flag_active, flag_names[fidx]]
      endelse
    endif
  endfor

  err_str_filename = flag_active.join('_')
  err_str_filename = err_str_filename.tolower()

  file[i] = dir[i] + 'CoMeT'+comet_str+'_full_'+catdata.date_str[catpos]+'_'+catdata.time_str[catpos]+'_L2_'+err_str_filename+'.txt'
endfor

fileformat = {comet: comet,  $
  version: '2024',  $
  qc: 'qcd'}

srt = sort(dir)
dir_srt = dir[srt]
file_srt = file[srt]
goodpos_srt = goodpos[srt]

;===
; Use the directory names to identify blocks
;===
uni = uniq(dir_srt)
nu = n_elements(uni)

i0 = 0
for j=0,nu-1 do begin
  thedir = dir_srt[uni[j]]
  i1 = uni[j]       ; Remember that uniq dumps the index of the last position in the matched series

;===  
; For some reason sorting on directories sometimes messes up the order of the files so that they're no longer
;  sequential in time.  The following ensures that the files in the block are in the correct order
;===  
  fs = file_srt[i0:i1]
  gs = goodpos_srt[i0:i1]
  n_block = 1+i1-i0
  
  s = sort(fs)
  fs_srt = fs[s]
  gs_srt = gs[s]
   
  catpos0 = gs_srt[0]
  
  fileformat.comet = catdata.comet[catpos0]
  if (typename(catdata.comet) eq 'INT') then begin
    comet_str = string(catdata.comet[catpos0], format='(i1)')
  endif else begin
    comet_str = catdata.comet[catpos0]
  endelse

  print, ''
;===
; Build the merged data set and find the active flags across all files in the set.  Remember that dir and file are already a subset of catdata
;===
  flag_chk = bytarr(nflags)
  for i=0,n_block-1 do begin
    cp = gs_srt[i]
    print, ' <> Processing ', fs_srt[i]
    read_comet_ascii, fs_srt[i], fileformat, data, name_std, name_long, units, source, /quiet
    
    if (i eq 0) then begin
      data_all = data
    endif else begin
      data_all = [data_all,data]
    endelse
    
;===
; Loop through all flags and see which are set for this file and then collect them into err_str_filename
;===
    for fidx=0,nflags-1 do if (flags.(fidx)[cp] ne 'no') then flag_chk[fidx] = 1
  endfor 

  pos = where(flag_chk)
  flag_active = flag_names[pos]
  err_str_filename = flag_active.join('_')
  err_str_filename = err_str_filename.tolower()
  
  
;===
; Convert to NetCDF
; ===
  date_str = catdata.date_str[catpos0].substring(0,3) + '-' + catdata.date_str[catpos0].substring(4,5) + '-' + catdata.date_str[catpos0].substring(6,7)
  global = {title: date_str+' Combined Mesonet and Tracker synchronized data file',  $
    source: 'Combined Mesonet and Tracker '+comet_str+' (CoMeT-'+comet_str+')',  $
    institution: 'University of Nebraska-Lincoln',  $
    comment: 'PI Contact Info: Adam Houston (ahouston2@unl.edu)'}
  if (comet_str eq 'alpha') then begin
    global.institution = 'Central Michigan University'
    global.comment = 'PI Contact Info: Jason Keeler (keele1j@cmich.edu)'
  endif
  file_out = 'UNL.CoMeT'+comet_str+'.'+catdata.date_str[catpos0]+'.'+catdata.time_str[catpos0]+'.L2_2024.'+err_str_filename.replace('_','.')+'.nc'
  print, ' <--> Creating NetCDF file: ', file_out
  comet_ascii_2_cfnetcdf_torus_v2, /batch, data=data_all, global=global, file_out=thedir + file_out,  $
   fileformat=fileformat, errstring=data_all.error_string, errval=errval

  i0 = i1+1
endfor


stop
end





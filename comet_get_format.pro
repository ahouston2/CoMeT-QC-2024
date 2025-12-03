;================================================================================================
; Reads the CoMeT_data_format spreadsheet to get file format information.  
; Uses the fileformat structure:
;   fileformat = {comet: '1',  $
;                 version: '2016',  $
;                 qc: 'raw'}
; frmt is a structure of arrays with each array corresponding to the headers in the spreadsheet
; 
; In 2025 the CoMeT designation column in CoMeT_data_format.csv was changed to be a string.  the 
;  fileformat structure may be defined such that comet is an integer.  This required a conversion
;  in this version. 
;================================================================================================

function comet_get_format, fileformat

file = 'C:\Users\ahouston2\OneDrive - University of Nebraska\Field Data\CoMeT_data_format.csv'
stuff = read_csv(file,header=header)
f = tag_rename(stuff,header)

if (typename(fileformat.comet) eq 'INT') then begin
  comet_str = string(fileformat.comet,format='(i1)') 
endif else begin
  comet_str = fileformat.comet
endelse

pos = where(f.comet eq comet_str and  $
            f.version eq fileformat.version  and  $
            f.qclevel eq fileformat.qc,cnt)

if (cnt eq 0) then begin
  print, ' !> No records found in the data format file matching the specified configuration'
  stop
endif

for i=0,n_tags(f)-1 do begin
  if (i eq 0) then begin
    frmt = create_struct(      header[i],f.(i)[pos])
  endif else begin
    frmt = create_struct(frmt, header[i],f.(i)[pos])
  endelse
endfor

return, frmt

end

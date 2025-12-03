function tag_rename, struct, newnames

  if (n_tags(struct) ne n_elements(newnames)) then begin
    print, ' !> Structure has a different size than newnames vector.  Stopping'
    stop
  endif
  
  for i=0,n_elements(newnames)-1 do begin
    if (i eq 0) then begin
      newstruct = create_struct(newnames[i],struct.(i))
    endif else begin
      newstruct = create_struct(newstruct,newnames[i],struct.(i))
    endelse
  endfor
  
  return, newstruct
  
end
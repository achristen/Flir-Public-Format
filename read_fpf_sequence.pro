;+
; name:
;   read_fpf_sequence.pro
;
; purpose:
;   reads multiple FLIR Public Format files from FLIR thermal cameras
;   stored in the same directory and creates a sequence
;
; calling sequence:
;   fpf = read_fpf_sequence(path)
;
; input
;   path : path to the directory that contains the .fpf files of the
;          sequence.
;
; keywords
;   step : if set to a value y > 1, only every y-th image will be read
;          default: all files in the directory will be read
;
; output:
;   fpf         : structure with the following tags:
;                 img[x,y,t], x is x dimension of fpf file,
;                             y is y dimension of fpf file,
;                             t is the number of time steps
;                 julian[t]   julian date corresponding to each
;                             time step
;                 filename[t] name of the original fpf file in
;                             sequence
; example:
;   path = '/Users/Shared/200809141500/'
;   fpf = read_fpf_sequence(path, step=15) ; read every 15 sec
;   plot, fpf.img[150,150,*], /ynozero ; plot pixel at x=150, y=150
;
; revision history:
;   14-May-09  : andreas.christen@ubc.ca
;-

function read_fpf_sequence, path, step=step

  if not keyword_set(step) then step = 1

  all_files = file_search(path+path_sep(),'*.FPF',/fold_case)

  ; add sort by time

  basename=strmid(file_basename(strupcase(all_files[0])),0,11)

  nf = n_elements(all_files)

  ;calculate storage in memory
  first_file = read_fpf(all_files[0],crop=crop)
  x_size = n_elements(first_file.data[*,0])
  y_size = n_elements(first_file.data[0,*])

  memory_req = 4L * first_file.IMAGE_X_SIZE * first_file.IMAGE_Y_SIZE * floor(nf / step)
  message, 'Memory requirement : '+strcompress(string(double(memory_req)/1000000, format='(f10.2)'),/remove_all)+' MB', /informational

  ; in a forst loop get timing information and sort ALL files

  recoding_time = {date_month:0B,date_day:0B,date_year:0,date_hour:0B,date_minute:0B,date_second:0B,date_millisecond:0}
  recoding_time = replicate(recoding_time,nf)
  
  for f=0, nf-1 do begin
    fpf = read_fpf(all_files[f], /header_only)
    recoding_time[f].date_month = fpf.date_month
    recoding_time[f].date_day = fpf.date_day
    recoding_time[f].date_year = fpf.date_year
    recoding_time[f].date_hour = fpf.date_hour
    recoding_time[f].date_minute = fpf.date_minute
    recoding_time[f].date_second = fpf.date_second
    recoding_time[f].date_millisecond = double(fpf.date_millisecond)
  endfor

  julday_all = julday(recoding_time.date_month,recoding_time.date_day,recoding_time.date_year,recoding_time.date_hour, recoding_time.date_minute, recoding_time.date_second)
  julian_minimum = min(julday_all)
  stored_julian_start = julian_minimum

  seconds_since_start = long(round(double(julday_all - julian_minimum) * 60D * 60D * 24D))
  milliseconds_since_start = seconds_since_start*1000L + long(round(recoding_time.date_millisecond))

  sorted = sort(milliseconds_since_start)
  selected_filenames = all_files[sorted]
  stored_filenames = selected_filenames

  ; in a second step read every x-th file

  subset = fltarr(x_size,y_size,floor(nf/step))
  subset[*] = !values.f_nan
  julian = dblarr(nf/step)
  start_time = systime(/julian)

  for i=0L, floor(nf/step)-1 do begin
    fpf_img = read_fpf(selected_filenames[i*step], crop=crop)
    subset[*,*,i] = fpf_img.data[*,*]
    julian[i]  = julday(fpf_img.date_month,fpf_img.date_day,fpf_img.date_year,fpf_img.date_hour,fpf_img.date_minute,fpf_img.date_second+(double(fpf_img.date_millisecond)/1000))
    if i eq 100 then begin ; if more than 100 files in sequence - provide estimation of time until completed
      end_of_loop = systime(/julian)
      message, 'Estimated time for completion : '+strcompress(string(double(end_of_loop-start_time)*double(floor(nf/step))*60D*24/100, format='(f10.2)'),/remove_all)+' Minutes', /informational
    endif
  endfor

  end_time = systime(/julian)
  duration_in_sec = (end_time-start_time)*86400
  message, 'Completed. Calculation in sec :'+strcompress(fix(duration_in_sec)), /informational

  data = {img:subset,julian:julian,filenames:file_basename(selected_filenames)}

  return, data

end
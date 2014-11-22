;+
; name:
;   read_fpf.pro
;
; purpose:
;   reads FLIR Public Format files from FLIR thermal cameras
;
; calling sequence:
;   fpf = read_fpf(file)
;   
; keywords
;   header_only : if set only header of fpf file is read, but not data.
;   subset:       array [4]. If set, only part of the image is read into 
;                 memory, where [x0,y0,x1,y1] is the subset to be retained.
;
; output:
;   fpf         : structure with all tags and data from .fpf file.
;
; example:
;   file = '/Users/Shared/F0809141500_1.FPF'
;   fpf = read_fpf(file)
;   tvscl, rotate(fpf.data,7)
;   
; revision history:
;   14-May-09  : andreas.christen@ubc.ca
;-

function read_fpf, file, header_only=header_only, crop=crop
  
  ;----------------------------
  ; set-up header of fpf file
  ;----------------------------
  
  fpf_image      = {fpf_id:bytarr(32), $
                    version:long(-9999), $
                    pixel_offset:long(-9999), $
                    image_type:fix(-9999),$
                    pixel_format:fix(-9999),$
                    x_size:fix(-9999),$
                    y_size:fix(-9999),$
                    trig_count:long(-9999),$
                    frame_count:long(-9999),$
                    spare_long:lonarr(16)}
                    
  fpf_camera     = {camera_name:bytarr(32), $
                    camera_partn:bytarr(32), $
                    camera_sn:bytarr(32), $
                    camera_range_t_min:float(-9999), $
                    camera_range_t_max:float(-9999), $
                    camera_lens_name:bytarr(32), $
                    camera_lens_partn:bytarr(32), $
                    camera_lens_sn:bytarr(32), $
                    filter_name:bytarr(32), $
                    filter_part_n:bytarr(32), $
                    filter_part_sn:bytarr(32), $
                    spare_long:lonarr(16)}
  
  fpf_object     = {emissivity:float(-9999), $
                    object_distance:float(-9999), $
                    amb_temp:float(-9999), $       
                    atm_temp:float(-9999), $ 
                    rel_hum:float(-9999), $       
                    compu_tao:float(-9999), $ 
                    estim_tao:float(-9999), $ 
                    ref_temp:float(-9999), $ 
                    ext_opt_temp:float(-9999), $ 
                    ext_opt_trans:float(-9999), $
                    spare_long:lonarr(16)} 
                    
  fpf_date_time  = {year:long(-9999), $
                    month:long(-9999), $
                    day:long(-9999), $       
                    hour:long(-9999), $ 
                    minute:long(-9999), $       
                    second:long(-9999), $ 
                    millisecond:long(-9999), $ 
                    spare_long:lonarr(16)} 
                    
  fpf_scaling    = {t_min_cam:float(-9999), $
                    t_max_cam:float(-9999), $
                    t_min_calc:float(-9999), $     
                    t_max_calc:float(-9999), $ 
                    t_min_scale:float(-9999), $       
                    t_max_scale:float(-9999), $ 
                    spare_long:lonarr(16*3)} 
                          
  ;----------------------------
  ; read file
  ;----------------------------                        
                                                            
  openr, lun, file, /get_lun, /swap_if_big_endian
  
  readu, lun, fpf_image
  readu, lun, fpf_camera
  readu, lun, fpf_object
  readu, lun, fpf_date_time
  readu, lun, fpf_scaling
  if not keyword_set(header_only) then begin
   point_lun, lun, 0
   dummy = bytarr(fpf_image.pixel_offset)
   fpf_data = fltarr(fpf_image.x_size,fpf_image.y_size)
   readu, lun, dummy
   readu, lun, fpf_data
  endif
  close, lun, /force
  free_lun, lun
  
  ;----------------------------
  ; concatenate in a single structure
  ;----------------------------  
  
  fpf = {image_fpf_id:string(fpf_image.fpf_id),$
         image_version:fpf_image.version,$
         image_pixel_offset:fpf_image.pixel_offset, $
         image_type:fpf_image.image_type,$
         image_pixel_format:fpf_image.pixel_format,$
         image_x_size:fpf_image.x_size,$
         image_y_size:fpf_image.y_size,$
         image_trig_count:fpf_image.trig_count,$
         image_frame_count:fpf_image.frame_count,$
         camera_name:string(fpf_camera.camera_name), $
         camera_partn:string(fpf_camera.camera_partn), $
         camera_sn:string(fpf_camera.camera_sn), $
         camera_range_t_min:string(fpf_camera.camera_range_t_min), $
         camera_range_t_max:string(fpf_camera.camera_range_t_max), $
         camera_lens_name:string(fpf_camera.camera_lens_name), $
         camera_lens_partn:string(fpf_camera.camera_lens_partn), $
         camera_lens_sn:string(fpf_camera.camera_lens_sn), $
         camera_filter_name:string(fpf_camera.filter_name), $
         camera_filter_part_n:string(fpf_camera.filter_part_n), $
         camera_filter_part_sn:string(fpf_camera.filter_part_sn), $
         object_emissivity:fpf_object.emissivity, $
         object_distance:fpf_object.object_distance, $
         object_amb_temp:fpf_object.amb_temp, $       
         object_atm_temp:fpf_object.atm_temp, $ 
         object_rel_hum:fpf_object.rel_hum, $       
         object_compu_tao:fpf_object.compu_tao, $ 
         object_estim_tao:fpf_object.estim_tao, $ 
         object_ref_temp:fpf_object.ref_temp, $ 
         object_ext_opt_temp:fpf_object.ext_opt_temp, $ 
         object_ext_opt_trans:fpf_object.ext_opt_trans,$
         date_year:fpf_date_time.year, $
         date_month:fpf_date_time.month, $
         date_day:fpf_date_time.day, $       
         date_hour:fpf_date_time.hour, $ 
         date_minute:fpf_date_time.minute, $       
         date_second:fpf_date_time.second, $ 
         date_millisecond:fpf_date_time.millisecond, $ 
         scaling_t_min_cam:fpf_scaling.t_min_cam, $
         scaling_t_max_cam:fpf_scaling.t_max_cam, $
         scaling_t_min_calc:fpf_scaling.t_min_calc, $     
         scaling_t_max_calc:fpf_scaling.t_max_calc, $ 
         scaling_t_min_scale:fpf_scaling.t_min_scale, $       
         scaling_t_max_scale:fpf_scaling.t_max_scale}
                    
         if not keyword_set(header_only) then begin
           if keyword_set(crop) then begin
            fpf = create_struct('data',fpf_data[crop[0]:crop[2],crop[1]:crop[3]],fpf)
           endif else begin
            fpf = create_struct('data',fpf_data,fpf)
           endelse
         endif  
         return, fpf

end













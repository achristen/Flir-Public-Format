;+
; name:
;   sequence_statistics.pro
;
; purpose:
;   calculates from a time series of (thermal) images various statistics
;   
;   For definitions of terms refer to:
;   Christen, Andreas, Fred Meier, and Dieter Scherer. 2012. 'High-Frequency 
;   Fluctuations of Surface Temperatures in an Urban Environment'
;   Theoretical and Applied Climatology, 108 (1-2). 
;   doi:10.1007/s00704-011-0521-x.
;
; calling sequence:
;   sequence_statistics, data, m_total, m_trend, m_pattern, t_fluctuation, sdev_img 
;   
; inputs:
;   data = 3-d array of a time series of images with [x,y,t]  
;  
; outputs:
;   m_total       : float. the spatial-temporal average of the entire series (one value)
;   m_trend       : array[t]. for each image, the average (time series of image averages)
;   m_pattern     : array[x,y]. the average value for each pixel (an image)
;   t_fluctuation : array[x,y,t]. the deviation of each pixel in each image from m_pattern
;   sdev_img[x,y] : is a single image [x,y] that shows for each pixel the 
;                   standard deviation of its time series
;                     
; example:
;   directory = '/Users/Shared/FPF/'
;   fpf = read_fpf_sequence(directory)
;   sequence_statistics, fpf
;   
; revision history:
;   14-May-09  : andreas.christen@ubc.ca
;-

pro sequence_statistics, data, m_total, m_trend, m_pattern, t_fluctuation, t_total, sdev_img 

   nx = n_elements(data[*,0,0])
   ny = n_elements(data[0,*,0])
   nt = n_elements(data[0,0,*])
     

   ; m_trend = <T>(t) spatial average T of an image at time (t)
   ; ******************************************************************
   
   m_trend = fltarr(nt)
   for t=0L, nt-1 do begin
     m_trend[t] = mean(data[*,*,t]) 
   endfor
   
   ;            _
   ; m_total = <T>(t) spatial-temporal average of an image 
   ; ******************************************************************
     
   m_total = mean(m_trend)
   
   ;              _ 
   ; m_pattern =  T (x,y) temporal average of each pixel in an image
   ; *******************************************************************
   
   m_pattern = fltarr(nx,ny)
   for x=0L, nx-1 do begin
    for y=0L, ny-1 do begin
     m_pattern[x,y] = mean(data[x,y,*])
    endfor 
   endfor
   
   ;                                           _ 
   ; t_fluctuation =  T' (x,y,t) = T (x,y,t) - T (x,y)
   ; *******************************************************************
   
   t_fluctuation = fltarr(nx,ny,nt)
   sdev_img = fltarr(nx,ny)
   for x=0L, nx-1 do begin
    for y=0L, ny-1 do begin
     t_fluctuation[x,y,*] = data[x,y,*] - m_pattern[x,y]
     sdev_img[x,y] = stddev(data[x,y,*])
    endfor 
   endfor
   
   ;                                     _ 
   ; t_total =  T' (x,y,t) = T (x,y,t) - T (x,y) - m_trend
   ; *******************************************************************
   
   t_total = fltarr(nx,ny,nt)
   for x=0L, nx-1 do begin
    for y=0L, ny-1 do begin
     t_total[x,y,*] = data[x,y,*] - m_pattern[x,y] - (m_trend[*] - m_total)
    endfor 
   endfor
  
end
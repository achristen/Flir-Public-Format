IDL Importer for Flir-Public-Format 
==================

Routines in the commercial Interactive Data Language (IDL) to import single files and time series (sequence of single files) from the output of Flir Thermal Cameras.

read_fpf.pro
----------------

purpose: reads FLIR Public Format files from FLIR thermal cameras

options
*   header_only : if set only header of fpf file is read, but not data.
*   subset: array [4]. If set, only part of the image is read into memory, where [x0,y0,x1,y1] is the subset to be retained.

output: structure with all tags and data from .fpf file.

revision history: 14-May-09


read_fpf_sequence.pro
----------------

purpose: reads multiple FLIR Public Format files from FLIR thermal cameras stored in the same directory and creates a sequence

option
*   step : if set to a value y > 1, only every yth image will be read
          default: all files will be read

output: structure with the following tags:

* img[x,y,t]: x is x dimension of fpf file, y is y dimension of fpf file, t is the number of time steps
* julian[t]: julian date corresponding to each time step            
* milliseconds[t]: millisecond fraction within each second of each time step            

revision history: 14-May-09

General comments
----------------

Has been tested under UNIX and Mac OSX

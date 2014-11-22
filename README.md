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


General comments
----------------

Has been tested under UNIX and Mac OSX

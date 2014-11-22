IDL Importer for Flir-Public-Format 
==================

Keywords: Time-Sequential Thermography, Thermal Camera, Thermal Remote Sensing

Routines for the commercial Interactive Data Language (IDL) to import single files or entire time series (sequence of single files) of thermal camera data stored in Flir-Public-Format (Flir Thermal Cameras).

read_fpf.pro
----------------

Reads a single image in FLIR Public Format (i.e. file from FLIR thermal camera) into a structure containing radiative temperatures and header information.

options
*   header_only : if set only header of fpf file is read, but not data.
*   subset: array [4]. If set, only part of the image is read into memory, where [x0,y0,x1,y1] is the subset to be retained.

read_fpf_sequence.pro
----------------

Reads multiple FLIR Public Format files stored in the same directory based on their relative time information into a time-sequential array [x,y,t], where x is width dimension of fpf file, y is hight dimension of fpf file and t is the number of time steps.

sequence_statistics.pro
----------------

Calculates spatial and temporal statistics of a time series as outlined in:

Christen, Andreas, Fred Meier, and Dieter Scherer. 2012. 'High-Frequency Fluctuations of Surface Temperatures in an Urban Environment' Theoretical and Applied Climatology, 108 (1-2). doi:10.1007/s00704-011-0521-x.

Example data
----------------
example.fpf - example file for testing of the routine
example.jpg - false color representation of the example file

General comments
----------------
Has been developped under Mac OSX - Big Endian / little endian may cause problem under Windows.

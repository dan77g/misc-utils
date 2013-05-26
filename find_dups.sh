#!/bin/sh

# Handy little script which finds duplicate files elsewhere on the filesystem
# arg is directory where the files are that you want to find duplicates for

find "$1" -type f | while read FILE; 
do 
  file=`basename "${FILE}"`; 
  echo $file; 
  echo "==================";
  locate -r "/${file}"$;
  echo "";
 done

#!/bin/sh 

if [ $# -ne 1 ] ; then
	echo "Give name of suffix of file(s) to be renamed."
	exit 1
fi

suff=$1

for file in *.${suff}
do
	# take from ls listing - example: -rwxr-xr-x 1 dan dan    950608 2010-02-18 17:25 31012010109.jpg
	mod_date=`ls -l $file | awk '{print $6}'`
	mod_time=`ls -l $file | awk '{print $7}'`
	md_day=`echo $mod_date | cut -c 9-10`
	md_month=`echo $mod_date | cut -c 6-7`
	md_year=`echo $mod_date | cut -c 1-4`
	
	# this will only work with my Nokia N96 - example 31012010109.jpg
	fn_day=`echo $file | cut -c 1-2`
	fn_month=`echo $file | cut -c 3-4`
	fn_year=`echo $file | cut -c 5-8`
	fn_seq=`echo $file | cut -c 9-11`

	# if the mod timestamp has changed since pic creation, we want to use the filename as the timestamp, and forget the time, but use the seq
	# otherwise we use the mod timestamp, and use the seq as well
	if [ $mod_date != "${fn_year}-${fn_month}-${fn_day}" ] ; then
		echo "Renaming $file to ${fn_year}-${fn_month}-${fn_day}_${fn_seq}.${suff}  .... "
		mv $file  "${fn_year}-${fn_month}-${fn_day}_${fn_seq}.${suff}" 
	else
		echo "Renaming $file to ${mod_date}_${mod_time}_${fn_seq}.${suff}  .... "
		mv $file "${mod_date}_${mod_time}_${fn_seq}.${suff}"
	fi
done

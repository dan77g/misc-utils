#!/bin/bash

## madripper.sh -- Multi-Angle DVD Ripper
## danryu - 2018.05.14
## Script to rip and transcode all angles of all chapters of a DVD
# Requirements:
# - lsdvd
# - handbrake-cli

dvdname="WSKO_DVD1of2"

inputfile=$1
#preset="CLI Default"
preset="H.265 MKV 480p30 _192_allAudio"

# Get total title count
titcount=$(lsdvd -n ${inputfile}| grep Title | tail -1 | awk '{print $2}' | tr -d ,)

for title in `seq 1 ${titcount}`;
do
	# get total number of angles for this title
	angcount=$(lsdvd -n ${inputfile} -t ${title} | grep Angles | cut -d ' ' -f 4)

	# rip and transcode for each angle
	for angle in `seq 1 ${angcount}`;
	do 
		echo ">>>>>>>>>>>>>>>>>   Ripping title ${title}, angle ${angle}"
		HandBrakeCLI -i ${inputfile} -o ${dvdname}_${title}_angle${angle}.mp4 -t ${title} --preset-import-gui -Z "${preset}"  --angle ${angle}
	done
done


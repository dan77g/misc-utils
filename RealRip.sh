#!/bin/bash

#  $1 -- rtsp URL
#  $2 -- Name of Prog

date=`date +%Y%m%d`
mkfifo stream.wav
mplayer -vc null -vo null -ao pcm:fast:file=stream.wav $1 &
lame -h --abr 80 stream.wav $2_$date.mp3
rm stream.wav


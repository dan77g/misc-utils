#!/bin/sh
ffmpeg -y -threads 8 -i $1 -s 640x352 -aspect 16:9 -r 24 -b 360k -bt 416k -vcodec libx264 -pass 1 -vpre fastfirstpass -an $1_pre-SD-HQ-512kbps.flv 
ffmpeg -y -threads 8 -i $1 -s 640x352 -aspect 16:9 -r 24 -b 360k -bt 416k -vcodec libx264 -pass 2 -vpre hq -acodec libmp3lame -ac 2 -ar 44100 -ab 64k $1_pre-SD-HQ-512kbps.flv
ffmpeg -i $1 -ss 3.5 -s 480x272 -vframes 1 -an -f image2 $1_preview.jpg
flvmeta $1_pre-SD-HQ-512kbps.flv $1_SD-HQ-512kbps.flv

# ffmpeg -i tetete -s 640x352 -aspect 640:352 -r 30000/1001 -vcodec flv -pass 1 -b 360k -bt 416k -f flv -acodec libmp3lame -ac 2 -ar 44100 -ab 64k duff.flv && ffmpeg -y -i tetete -s 640x352 -aspect 640:352 -r 30000/1001 -vcodec flv -pass 1 -b 360k -bt 416k -f flv -acodec libmp3lame -ac 2 -ar 44100 -ab 64k duff.flv
